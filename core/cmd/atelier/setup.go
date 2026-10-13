package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"os/user"
	"path/filepath"
	"strings"
	"syscall"

	"github.com/spf13/cobra"
	"golang.org/x/term"

	"github.com/jeremytondo/atelier/core/internal/command"
	"github.com/jeremytondo/atelier/core/internal/integrations/github"
	"github.com/jeremytondo/atelier/core/internal/integrations/mise"
	"github.com/jeremytondo/atelier/core/internal/setup"
)

const zsh = "/usr/bin/zsh"

type setupFlags struct {
	dotfiles   string
	tokenStdin bool
	// login is set by the bootstrap when the login hook started it: this
	// process replaced the login shell.
	login bool
}

func newSetupCmd() *cobra.Command {
	var flags setupFlags
	cmd := &cobra.Command{
		Use:   "setup [--dotfiles OWNER/REPO] [--token-stdin]",
		Short: "Set up this machine for its user (Linux)",
		Long: `Sets up this machine for its user: a GitHub login, then the owner's dotfiles,
which bring the tools and everything else. On Atelier for Linux, the
atelier-setup bootstrap installs mise, gh and atelier, then runs this.

Without --dotfiles, setup asks for the repository. With --token-stdin, setup
asks nothing, so it needs --dotfiles too:

  gh auth token | ssh <host> atelier-setup --token-stdin --dotfiles OWNER/REPO

Each step is skipped when its result is already there, so a run that failed or
was interrupted can simply run again.`,
		Args: cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			return runSetup(cmd, flags)
		},
	}
	cmd.Flags().StringVar(&flags.dotfiles, "dotfiles", "", "the GitHub `OWNER/REPO` to adopt the dotfiles from")
	cmd.Flags().BoolVar(&flags.tokenStdin, "token-stdin", false, "log in with a gh token read from standard input, rather than by scanning a QR code")
	cmd.Flags().BoolVar(&flags.login, "login", false, "started by the login hook, in place of the login shell")
	_ = cmd.Flags().MarkHidden("login")
	return cmd
}

func runSetup(cmd *cobra.Command, flags setupFlags) error {
	ctx := cmd.Context()
	stdin, stdout, stderr := cmd.InOrStdin(), cmd.OutOrStdout(), cmd.ErrOrStderr()

	if os.Getuid() == 0 {
		return errors.New("run atelier setup as your own user, not root")
	}
	me, err := user.Current()
	if err != nil {
		return err
	}
	home, err := os.UserHomeDir()
	if err != nil {
		return err
	}

	// A run that hasn't finished. From the login hook, end in a plain login
	// shell rather than closing the session.
	giveUp := func(code int) error {
		if !flags.login {
			return exitError{code}
		}
		fmt.Fprintln(stderr, "Setup starts again at your next login, or run atelier-setup.")
		shell, err := setup.LoginShell(ctx, me.Username)
		if err != nil || shell == "" {
			shell = "/bin/bash"
		}
		if err := execLoginShell(shell, "ATELIER_SETUP_SKIP=1"); err != nil {
			fmt.Fprintln(stderr, "atelier setup:", err)
		}
		return exitError{code}
	}
	interrupts := make(chan os.Signal, 1)
	signal.Notify(interrupts, os.Interrupt)
	defer signal.Stop(interrupts)
	go func() {
		if _, ok := <-interrupts; !ok {
			return
		}
		fmt.Fprintln(stderr)
		fmt.Fprintln(stderr, "Setup interrupted.")
		_ = giveUp(130)
		os.Exit(130)
	}()

	// Tokens come only from --token-stdin, never from the environment.
	for _, name := range []string{"GH_TOKEN", "GITHUB_TOKEN", "GH_ENTERPRISE_TOKEN", "GITHUB_ENTERPRISE_TOKEN"} {
		os.Unsetenv(name)
	}
	local := filepath.Join(home, ".local")
	os.Setenv("PATH", filepath.Join(local, "bin")+":"+filepath.Join(local, "share", "mise", "shims")+":"+os.Getenv("PATH"))

	input := bufio.NewReader(stdin)
	streams := command.Streams{Stdin: stdin, Stdout: stdout, Stderr: stderr}
	token := ""
	if flags.tokenStdin {
		line, _ := input.ReadString('\n')
		token = strings.Join(strings.Fields(line), "")
		// Nothing later reads the token's pipe, or waits on it for input.
		streams.Stdin = nil
	}
	interactive := !flags.tokenStdin && isTerminal(stdin)

	// Setup says so when it needs mise and there's none.
	misePath, _ := mise.Find(home)
	host, _ := os.Hostname()
	err = setup.Run(ctx, setup.Options{
		Dotfiles:    flags.dotfiles,
		TokenStdin:  flags.tokenStdin,
		Token:       token,
		Interactive: interactive,
		User:        me.Username,
		Home:        home,
		Shell:       zsh,
		LingerDir:   "/var/lib/systemd/linger",
		MisePath:    misePath,
		GitHub:      github.DeviceFlow{BaseURL: "https://github.com"},
		Streams:     streams,
	}, &terminalUI{in: input, out: stdout, interactive: interactive, host: host})
	var step *setup.StepError
	switch {
	case err == nil:
	case errors.Is(err, setup.ErrNeedDotfiles):
		fmt.Fprintln(stderr, "atelier setup: name the dotfiles repository with --dotfiles OWNER/REPO")
		return exitError{2}
	case errors.Is(err, setup.ErrInProgress):
		fmt.Fprintf(stderr, "Setup is already in progress for %s.\n", me.Username)
		return giveUp(1)
	case errors.As(err, &step):
		fmt.Fprintf(stderr, "atelier setup: failed: %s: %v\n", step.Step, step.Err)
		return giveUp(1)
	default:
		fmt.Fprintln(stderr, "atelier setup:", err)
		return giveUp(1)
	}

	fmt.Fprintln(stdout, "Setup is done.")
	if flags.login || interactive && isTerminal(stdout) {
		if err := execLoginShell(zsh); err != nil {
			return err
		}
	}
	return nil
}

// execLoginShell replaces this process with a login shell, which releases the
// setup lock.
func execLoginShell(shell string, env ...string) error {
	path, err := exec.LookPath(shell)
	if err != nil {
		return err
	}
	return syscall.Exec(path, []string{path, "-l"}, append(os.Environ(), env...))
}

func isTerminal(stream any) bool {
	file, ok := stream.(*os.File)
	return ok && term.IsTerminal(int(file.Fd()))
}

// terminalUI shows setup's progress, prompts and device codes on a terminal.
type terminalUI struct {
	in          *bufio.Reader
	out         io.Writer
	interactive bool
	host        string
}

func (u *terminalUI) Step(name string)       { fmt.Fprintln(u.out, "==> "+name) }
func (u *terminalUI) Already(message string) { fmt.Fprintln(u.out, "    "+message) }
func (u *terminalUI) Say(message string)     { fmt.Fprintln(u.out, message) }

func (u *terminalUI) Ask(prompt string) (string, error) {
	if !u.interactive {
		return "", errors.New("no terminal to ask on")
	}
	fmt.Fprint(u.out, prompt)
	line, err := u.in.ReadString('\n')
	if err != nil && line == "" {
		return "", err
	}
	return strings.TrimSpace(line), nil
}

func (u *terminalUI) ShowCode(code github.Code) {
	fmt.Fprintln(u.out)
	fmt.Fprintf(u.out, "Log in to GitHub to finish setting up %s.\n", u.host)
	fmt.Fprintf(u.out, "Scan this code with your phone, or open %s\n", code.URI())
	fmt.Fprintln(u.out)
	qr := exec.Command("qrencode", "-t", "ansiutf8", "-m", "2", code.URI())
	qr.Stdout, qr.Stderr = u.out, io.Discard
	if qr.Run() == nil {
		fmt.Fprintln(u.out)
	}
	fmt.Fprintln(u.out, "Then enter this code:")
	fmt.Fprintln(u.out)
	fmt.Fprint(u.out, big(code.UserCode))
	fmt.Fprintln(u.out)
	fmt.Fprintf(u.out, "  %s\n", code.UserCode)
	fmt.Fprintln(u.out)
	fmt.Fprintf(u.out, "Waiting for approval. The code expires in %d minutes.\n", code.ExpiresIn/60)
}

// font draws letters five rows high, for a code read off the screen.
var font = map[rune]string{
	'A': ".###.|#...#|#####|#...#|#...#", 'B': "####.|#...#|####.|#...#|####.",
	'C': ".####|#....|#....|#....|.####", 'D': "####.|#...#|#...#|#...#|####.",
	'E': "#####|#....|####.|#....|#####", 'F': "#####|#....|####.|#....|#....",
	'G': ".####|#....|#..##|#...#|.####", 'H': "#...#|#...#|#####|#...#|#...#",
	'I': "#####|..#..|..#..|..#..|#####", 'J': "..###|...#.|...#.|#..#.|.##..",
	'K': "#...#|#..#.|###..|#..#.|#...#", 'L': "#....|#....|#....|#....|#####",
	'M': "#...#|##.##|#.#.#|#...#|#...#", 'N': "#...#|##..#|#.#.#|#..##|#...#",
	'O': ".###.|#...#|#...#|#...#|.###.", 'P': "####.|#...#|####.|#....|#....",
	'Q': ".###.|#...#|#.#.#|#..#.|.##.#", 'R': "####.|#...#|####.|#..#.|#...#",
	'S': ".####|#....|.###.|....#|####.", 'T': "#####|..#..|..#..|..#..|..#..",
	'U': "#...#|#...#|#...#|#...#|.###.", 'V': "#...#|#...#|#...#|.#.#.|..#..",
	'W': "#...#|#...#|#.#.#|##.##|#...#", 'X': "#...#|.#.#.|..#..|.#.#.|#...#",
	'Y': "#...#|.#.#.|..#..|..#..|..#..", 'Z': "#####|...#.|..#..|.#...|#####",
	'0': ".###.|#..##|#.#.#|##..#|.###.", '1': "..#..|.##..|..#..|..#..|.###.",
	'2': ".###.|#...#|..##.|.#...|#####", '3': "####.|....#|.###.|....#|####.",
	'4': "#..#.|#..#.|#####|...#.|...#.", '5': "#####|#....|####.|....#|####.",
	'6': ".###.|#....|####.|#...#|.###.", '7': "#####|....#|...#.|..#..|..#..",
	'8': ".###.|#...#|.###.|#...#|.###.", '9': ".###.|#...#|.####|....#|.###.",
	'-': ".....|.....|.###.|.....|.....",
}

// big draws text in the font, with unknown characters left blank.
func big(text string) string {
	var rows [5]strings.Builder
	for i := range rows {
		rows[i].WriteString("  ")
	}
	for _, char := range text {
		glyph, ok := font[char]
		if !ok {
			glyph = ".....|.....|.....|.....|....."
		}
		for i, row := range strings.Split(glyph, "|") {
			rows[i].WriteString(row + " ")
		}
	}
	var out strings.Builder
	for _, row := range rows {
		line := strings.NewReplacer(".", " ", "#", "█").Replace(row.String())
		out.WriteString(line + "\n")
	}
	return out.String()
}
