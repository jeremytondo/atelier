// Package setup sets up a Linux machine for its user. It needs two things from
// the owner: a GitHub login, and the GitHub repository that holds their
// dotfiles, a mise setup repository. The dotfiles do everything else. A
// machine with no SSH keys gets the GitHub account's, and on bare metal, the
// owner also approves the machine joining the tailnet.
//
// The atelier-setup bootstrap in the Linux image installs mise, gh and the
// core, then hands off to this. Each step is skipped when its result is
// already there, so a run that failed or was interrupted can simply run again.
package setup

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"golang.org/x/sys/unix"

	"github.com/jeremytondo/atelier/core/internal/command"
	"github.com/jeremytondo/atelier/core/internal/integrations/gh"
	"github.com/jeremytondo/atelier/core/internal/integrations/github"
	"github.com/jeremytondo/atelier/core/internal/integrations/mise"
	"github.com/jeremytondo/atelier/core/internal/integrations/tailscale"
)

var (
	// ErrNeedDotfiles means no dotfiles repository was named or chosen
	// earlier, and there's no one to ask. Setup stops before changing
	// anything.
	ErrNeedDotfiles = errors.New("no dotfiles repository named, and no one to ask")
	// ErrInProgress means another run of setup holds the lock.
	ErrInProgress = errors.New("setup is already in progress")
)

// StepError is a step that failed. The programs it ran have already shown
// their own output.
type StepError struct {
	Step string
	Err  error
}

func (e *StepError) Error() string { return e.Step + ": " + e.Err.Error() }
func (e *StepError) Unwrap() error { return e.Err }

// Options describe the machine, its user and what they asked for.
type Options struct {
	// Dotfiles is the repository to adopt, as OWNER/REPO or a URL. When it's
	// empty, setup uses the one chosen earlier, or asks.
	Dotfiles string
	// TokenStdin means Token is the gh login to use, rather than a device
	// login. Nothing is asked then, and sudo never prompts.
	TokenStdin bool
	Token      string
	// Interactive means there's someone at a terminal to ask.
	Interactive bool
	// Tailnet means the machine joins the tailnet: Atelier for Linux on bare
	// metal does, and VMs don't.
	Tailnet bool

	User string
	Home string
	// Shell is the login shell to set, /usr/bin/zsh.
	Shell string
	// LingerDir is where logind records linger, /var/lib/systemd/linger.
	LingerDir string
	// MisePath is mise, or "" when it isn't installed.
	MisePath string
	GitHub   github.DeviceFlow
	// Streams are shared with the programs setup runs.
	Streams command.Streams
}

// UI is how setup talks to the user.
type UI interface {
	// Step announces a step.
	Step(name string)
	// Already reports a step, or part of one, that's already done.
	Already(message string)
	// Say shows a message.
	Say(message string)
	// Ask shows a prompt and returns the answer. It fails when there's no one
	// to ask.
	Ask(prompt string) (string, error)
	// ShowCode shows a device code and where to enter it.
	ShowCode(code github.Code)
}

// StateDir is where setup keeps its state. The login hook in the Linux image
// reads setup-done from it.
func StateDir(home string) string {
	return filepath.Join(home, ".local", "state", "atelier")
}

// Run sets up the machine.
func Run(ctx context.Context, opts Options, ui UI) error {
	state := StateDir(opts.Home)
	s := &setup{
		opts:         opts,
		ui:           ui,
		mise:         mise.Mise{Path: opts.MisePath, Streams: opts.Streams},
		dotfilesFile: filepath.Join(state, "dotfiles"),
		dotfiles:     opts.Dotfiles,
	}

	// With no one to ask, stop before changing anything.
	if opts.Dotfiles == "" && !opts.Interactive && !nonEmpty(s.dotfilesFile) && !mise.Adopted(opts.Home) {
		return ErrNeedDotfiles
	}

	if opts.MisePath == "" {
		return errors.New("mise isn't installed; run atelier-setup to install it")
	}
	if err := os.MkdirAll(state, 0o755); err != nil {
		return err
	}
	unlock, err := lock(filepath.Join(state, "setup.lock"))
	if err != nil {
		return err
	}
	defer unlock()

	if err := s.findGH(ctx); err != nil {
		return &StepError{"Install gh", err}
	}
	type step struct {
		name string
		run  func(context.Context) error
	}
	steps := []step{{"Log in to GitHub", s.logIn}, {"Add SSH keys", s.addSSHKeys}}
	if opts.Tailnet {
		steps = append(steps, step{"Join the tailnet", s.joinTailnet})
	}
	for _, step := range append(steps, []step{
		{"Choose the dotfiles", s.chooseDotfiles},
		{"Turn on linger", s.enableLinger},
		{"Set the login shell to " + filepath.Base(opts.Shell), s.setShell},
		{"Adopt the dotfiles", s.adopt},
		{"Record that setup is done", func(context.Context) error {
			return os.WriteFile(filepath.Join(state, "setup-done"), nil, 0o644)
		}},
	}...) {
		ui.Step(step.name)
		if err := step.run(ctx); err != nil {
			return &StepError{step.name, err}
		}
	}
	return nil
}

type setup struct {
	opts         Options
	ui           UI
	mise         mise.Mise
	gh           gh.GH
	dotfilesFile string
	// dotfiles is the repository chosen so far, checked once gh is
	// logged in.
	dotfiles string
}

// findGH finds the gh the bootstrap installed through mise, without the
// global config, which the dotfiles bring. Their `gh = "latest"` then finds
// this installation. When setup runs without the bootstrap, it installs gh
// here.
func (s *setup) findGH(ctx context.Context) error {
	version, err := s.mise.Installed(ctx, "gh")
	if err != nil {
		return err
	}
	if version == "" {
		s.ui.Step("Install gh")
		if err := s.mise.Install(ctx, "gh@latest"); err != nil {
			return err
		}
		if version, err = s.mise.Installed(ctx, "gh"); err != nil {
			return err
		}
	}
	path, err := s.mise.Which(ctx, "gh", version, "gh")
	if err != nil {
		return err
	}
	s.gh = gh.GH{Path: path, Streams: s.opts.Streams}
	return nil
}

func (s *setup) logIn(ctx context.Context) error {
	if s.gh.LoggedIn(ctx) {
		s.ui.Already("gh is logged in to " + gh.Host)
		return nil
	}
	if s.opts.TokenStdin {
		if s.opts.Token == "" {
			return errors.New("no token on standard input")
		}
		return s.gh.LogIn(ctx, s.opts.Token)
	}
	for {
		code, err := s.opts.GitHub.Request(ctx)
		if err != nil {
			return err
		}
		s.ui.ShowCode(code)
		token, err := s.opts.GitHub.Wait(ctx, code)
		switch {
		case err == nil:
			return s.gh.LogIn(ctx, token)
		case !errors.Is(err, github.ErrExpired):
			return err
		}
		s.ui.Say("The code expired.")
		if !s.opts.Interactive {
			return err
		}
		if _, err := s.ui.Ask("Press Enter for a new code, or Ctrl-C to stop. "); err != nil {
			return err
		}
	}
}

// addSSHKeys lets the owner in over SSH with their GitHub account's keys,
// when the machine has none. One installed from the installer ISO starts with
// only a password, while VMs get keys from cloud-init.
func (s *setup) addSSHKeys(ctx context.Context) error {
	path := filepath.Join(s.opts.Home, ".ssh", "authorized_keys")
	if hasKeys(path) {
		s.ui.Already("~/.ssh/authorized_keys has keys")
		return nil
	}
	login, err := s.gh.User(ctx)
	if err != nil {
		return err
	}
	keys, err := s.gh.SSHKeys(ctx, login)
	if err != nil {
		return err
	}
	if len(keys) == 0 {
		s.ui.Say("GitHub has no SSH keys for " + login + ". Add one there, then run atelier-setup again to use it here.")
		return nil
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o700); err != nil {
		return err
	}
	file, err := os.OpenFile(path, os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0o600)
	if err != nil {
		return err
	}
	if _, err := file.WriteString(strings.Join(keys, "\n") + "\n"); err != nil {
		file.Close()
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	s.ui.Say("Added the SSH keys on " + login + "'s GitHub account.")
	return nil
}

// joinTailnet joins the machine to the tailnet. Tailscale shows its login
// address as a QR code, and someone approves it, so a run with no one to ask
// leaves it for later.
func (s *setup) joinTailnet(ctx context.Context) error {
	joined, err := tailscale.Joined(ctx)
	if err != nil {
		return err
	}
	if joined {
		s.ui.Already("this machine is on the tailnet")
		return nil
	}
	if !s.opts.Interactive {
		s.ui.Say("No one is here to approve it, so join later with: sudo tailscale up --qr")
		return nil
	}
	return s.asRoot(ctx, "tailscale", "up", "--qr")
}

// chooseDotfiles takes the repository from Options, an earlier run, or the
// user, and keeps it in case setup has to start again. It's checked once gh
// is logged in, so a mistyped name stops setup here.
func (s *setup) chooseDotfiles(ctx context.Context) error {
	if mise.Adopted(s.opts.Home) {
		s.ui.Already("the dotfiles are adopted")
		return nil
	}
	repo := s.dotfiles
	if repo == "" {
		if saved, err := os.ReadFile(s.dotfilesFile); err == nil {
			if repo = strings.TrimSpace(string(saved)); repo != "" {
				s.ui.Already("using " + repo + ", chosen earlier")
			}
		}
	}
	if repo != "" {
		name, err := s.gh.RepoName(ctx, repo)
		if err != nil {
			return err
		}
		s.dotfiles = name
	} else {
		// The owner's own dotfiles repository, if there is one.
		var suggestion string
		if login, err := s.gh.User(ctx); err == nil {
			suggestion, _ = s.gh.RepoName(ctx, login+"/dotfiles")
		}
		prompt := "Dotfiles repository (OWNER/REPO): "
		if suggestion != "" {
			prompt = "Dotfiles repository (OWNER/REPO) [" + suggestion + "]: "
		}
		for s.dotfiles == "" {
			reply, err := s.ui.Ask(prompt)
			if err != nil {
				return err
			}
			if reply = strings.TrimSpace(reply); reply == "" {
				reply = suggestion
			}
			if reply == "" {
				continue
			}
			name, err := s.gh.RepoName(ctx, reply)
			if err != nil {
				s.ui.Say(err.Error())
				continue
			}
			s.dotfiles = name
		}
	}
	return os.WriteFile(s.dotfilesFile, []byte(s.dotfiles+"\n"), 0o644)
}

// enableLinger keeps the user's services running without a login session, so
// the dotfiles' history watcher keeps running.
func (s *setup) enableLinger(ctx context.Context) error {
	if _, err := os.Stat(filepath.Join(s.opts.LingerDir, s.opts.User)); err == nil {
		s.ui.Already("linger is on")
		return nil
	}
	return s.asRoot(ctx, "loginctl", "enable-linger", s.opts.User)
}

func (s *setup) setShell(ctx context.Context) error {
	shell, err := LoginShell(ctx, s.opts.User)
	if err != nil {
		return err
	}
	if shell == s.opts.Shell {
		s.ui.Already("the login shell is " + filepath.Base(s.opts.Shell))
		return nil
	}
	return s.asRoot(ctx, "usermod", "--shell", s.opts.Shell, s.opts.User)
}

func (s *setup) adopt(ctx context.Context) error {
	if mise.Adopted(s.opts.Home) {
		s.ui.Already("the dotfiles are adopted; bootstrapping again")
		return s.mise.Bootstrap(ctx)
	}
	return s.mise.Adopt(ctx, s.dotfiles)
}

// asRoot runs a command with sudo, which may ask for a password unless a
// token came on standard input.
func (s *setup) asRoot(ctx context.Context, args ...string) error {
	if s.opts.TokenStdin {
		args = append([]string{"-n"}, args...)
	}
	return s.opts.Streams.Run(ctx, "sudo", args...)
}

// LoginShell returns a user's login shell from the passwd database.
func LoginShell(ctx context.Context, user string) (string, error) {
	entry, err := command.Output(ctx, "getent", "passwd", user)
	if err != nil {
		return "", err
	}
	fields := strings.Split(entry, ":")
	if len(fields) < 7 {
		return "", fmt.Errorf("getent passwd %s: unexpected entry %q", user, entry)
	}
	return fields[6], nil
}

// lock takes the setup lock, which is released when the process ends,
// including by exec. Programs setup runs don't inherit it, so a process they
// leave running never holds it.
func lock(path string) (func(), error) {
	file, err := os.OpenFile(path, os.O_RDWR|os.O_CREATE, 0o644)
	if err != nil {
		return nil, err
	}
	if err := unix.Flock(int(file.Fd()), unix.LOCK_EX|unix.LOCK_NB); err != nil {
		file.Close()
		if errors.Is(err, unix.EWOULDBLOCK) {
			return nil, ErrInProgress
		}
		return nil, err
	}
	return func() { file.Close() }, nil
}

// hasKeys reports whether an authorized_keys file lists a key.
func hasKeys(path string) bool {
	data, err := os.ReadFile(path)
	if err != nil {
		return false
	}
	for _, line := range strings.Split(string(data), "\n") {
		if line = strings.TrimSpace(line); line != "" && !strings.HasPrefix(line, "#") {
			return true
		}
	}
	return false
}

func nonEmpty(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.Size() > 0
}
