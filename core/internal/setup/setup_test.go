package setup

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"

	"github.com/jeremytondo/atelier/core/internal/command"
	"github.com/jeremytondo/atelier/core/internal/integrations/github"
)

// The fakes log each call to $FAKE_DIR/log, and keep their state as files in
// $FAKE_DIR: gh-installed, logged-in (holding the token), gh-keys (the
// account's SSH keys), zsh and tailnet.
const (
	fakeMise = `#!/bin/sh
echo "mise $*" >>"$FAKE_DIR/log"
case $1 in
ls) if [ -e "$FAKE_DIR/gh-installed" ]; then echo '[{"version":"2.95.0"},{"version":"2.96.0"}]'; else echo '[]'; fi ;;
install) touch "$FAKE_DIR/gh-installed" ;;
exec) echo "$FAKE_DIR/bin/gh" ;;
bootstrap)
	if [ "$2" = --adopt ]; then
		mkdir -p "$HOME/.config/mise"
		printf '[history.origin]\nurl = "x"\n' >"$HOME/.config/mise/config.local.toml"
		: >"$HOME/.config/mise/config.toml"
	fi
	;;
esac
`
	fakeGH = `#!/bin/sh
echo "gh $*" >>"$FAKE_DIR/log"
case "$1 $2" in
"auth status") [ -e "$FAKE_DIR/logged-in" ] ;;
"auth login") cat >"$FAKE_DIR/logged-in" ;;
"repo view")
	case $3 in
	*/missing) echo "GraphQL: Could not resolve to a Repository" >&2; exit 1 ;;
	https://github.com/*) echo "${3#https://github.com/}" ;;
	*) echo "$3" ;;
	esac
	;;
"api user") echo octo ;;
"api users/octo/keys") [ ! -e "$FAKE_DIR/gh-keys" ] || cat "$FAKE_DIR/gh-keys" ;;
esac
`
	fakeSudo = `#!/bin/sh
echo "sudo $*" >>"$FAKE_DIR/log"
`
	fakeTailscale = `#!/bin/sh
echo "tailscale $*" >>"$FAKE_DIR/log"
state=NeedsLogin
[ -e "$FAKE_DIR/tailnet" ] && state=Running
echo "{\"BackendState\": \"$state\"}"
`
	fakeGetent = `#!/bin/sh
echo "getent $*" >>"$FAKE_DIR/log"
shell=/bin/bash
[ -e "$FAKE_DIR/zsh" ] && shell=/usr/bin/zsh
echo "tester:x:1000:1000::$HOME:$shell"
`
)

type fixture struct {
	dir  string
	home string
	opts Options
}

func newFixture(t *testing.T) *fixture {
	t.Helper()
	dir := t.TempDir()
	home := filepath.Join(dir, "home")
	bin := filepath.Join(dir, "bin")
	for _, path := range []string{home, bin, filepath.Join(dir, "linger")} {
		if err := os.MkdirAll(path, 0o755); err != nil {
			t.Fatal(err)
		}
	}
	for name, script := range map[string]string{"mise": fakeMise, "gh": fakeGH, "sudo": fakeSudo, "getent": fakeGetent, "tailscale": fakeTailscale} {
		if err := os.WriteFile(filepath.Join(bin, name), []byte(script), 0o755); err != nil {
			t.Fatal(err)
		}
	}
	t.Setenv("FAKE_DIR", dir)
	t.Setenv("HOME", home)
	t.Setenv("PATH", bin+":"+os.Getenv("PATH"))
	return &fixture{dir: dir, home: home, opts: Options{
		User:      "tester",
		Home:      home,
		Shell:     "/usr/bin/zsh",
		LingerDir: filepath.Join(dir, "linger"),
		MisePath:  filepath.Join(bin, "mise"),
		Streams:   command.Streams{Stdout: os.Stderr, Stderr: os.Stderr},
	}}
}

func (f *fixture) touch(t *testing.T, path, content string) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
}

func (f *fixture) log(t *testing.T) []string {
	t.Helper()
	data, err := os.ReadFile(filepath.Join(f.dir, "log"))
	if errors.Is(err, os.ErrNotExist) {
		return nil
	}
	if err != nil {
		t.Fatal(err)
	}
	return strings.Split(strings.TrimSuffix(string(data), "\n"), "\n")
}

func (f *fixture) read(t *testing.T, path string) string {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	return string(data)
}

// fakeUI records what setup shows, and answers prompts in order.
type fakeUI struct {
	shown   []string
	answers []string
}

func (u *fakeUI) Step(name string)       { u.shown = append(u.shown, "==> "+name) }
func (u *fakeUI) Already(message string) { u.shown = append(u.shown, "    "+message) }
func (u *fakeUI) Say(message string)     { u.shown = append(u.shown, message) }
func (u *fakeUI) ShowCode(code github.Code) {
	u.shown = append(u.shown, "code "+code.UserCode+" at "+code.URI())
}

func (u *fakeUI) Ask(prompt string) (string, error) {
	u.shown = append(u.shown, "? "+prompt)
	if len(u.answers) == 0 {
		return "", errors.New("no answer")
	}
	answer := u.answers[0]
	u.answers = u.answers[1:]
	return answer, nil
}

func TestRunWithToken(t *testing.T) {
	f := newFixture(t)
	f.opts.TokenStdin = true
	f.opts.Token = "gho_secret"
	f.opts.Dotfiles = "https://github.com/octo/dotfiles"
	f.touch(t, filepath.Join(f.dir, "gh-keys"), "ssh-ed25519 AAAA octo\n")
	ui := &fakeUI{}

	if err := Run(context.Background(), f.opts, ui); err != nil {
		t.Fatal(err)
	}

	wantLog := []string{
		"mise ls --installed --json gh",
		"mise install gh@latest",
		"mise ls --installed --json gh",
		"mise exec gh@2.96.0 -- sh -c command -v \"$0\" gh",
		"gh auth status --hostname github.com",
		"gh auth login --hostname github.com --with-token",
		"gh api user --jq .login",
		"gh api users/octo/keys --jq .[].key",
		"gh repo view https://github.com/octo/dotfiles --json nameWithOwner --jq .nameWithOwner",
		"sudo -n loginctl enable-linger tester",
		"getent passwd tester",
		"sudo -n usermod --shell /usr/bin/zsh tester",
		"mise bootstrap --adopt octo/dotfiles --take-remote-all --yes",
	}
	if diff := cmp.Diff(wantLog, f.log(t)); diff != "" {
		t.Errorf("calls (-want +got):\n%s", diff)
	}
	wantShown := []string{
		"==> Install gh",
		"==> Log in to GitHub",
		"==> Add SSH keys",
		"Added the SSH keys on octo's GitHub account.",
		"==> Choose the dotfiles",
		"==> Turn on linger",
		"==> Set the login shell to zsh",
		"==> Adopt the dotfiles",
		"==> Record that setup is done",
	}
	if diff := cmp.Diff(wantShown, ui.shown); diff != "" {
		t.Errorf("shown (-want +got):\n%s", diff)
	}
	if got := f.read(t, filepath.Join(f.dir, "logged-in")); got != "gho_secret\n" {
		t.Errorf("gh got token %q", got)
	}
	state := StateDir(f.home)
	if got := f.read(t, filepath.Join(state, "dotfiles")); got != "octo/dotfiles\n" {
		t.Errorf("dotfiles file = %q", got)
	}
	f.read(t, filepath.Join(state, "setup-done"))
	if got := f.read(t, filepath.Join(f.home, ".ssh", "authorized_keys")); got != "ssh-ed25519 AAAA octo\n" {
		t.Errorf("authorized_keys = %q", got)
	}
}

func TestRunAgainSkipsWhatsDone(t *testing.T) {
	f := newFixture(t)
	f.touch(t, filepath.Join(f.dir, "gh-installed"), "")
	f.touch(t, filepath.Join(f.dir, "logged-in"), "")
	f.touch(t, filepath.Join(f.dir, "zsh"), "")
	f.touch(t, filepath.Join(f.dir, "linger", "tester"), "")
	f.touch(t, filepath.Join(f.home, ".config", "mise", "config.toml"), "")
	f.touch(t, filepath.Join(f.home, ".config", "mise", "config.local.toml"), "[history.origin]\n")
	f.touch(t, filepath.Join(f.home, ".ssh", "authorized_keys"), "ssh-ed25519 AAAA octo\n")
	ui := &fakeUI{}

	if err := Run(context.Background(), f.opts, ui); err != nil {
		t.Fatal(err)
	}

	wantLog := []string{
		"mise ls --installed --json gh",
		"mise exec gh@2.96.0 -- sh -c command -v \"$0\" gh",
		"gh auth status --hostname github.com",
		"getent passwd tester",
		"mise bootstrap --yes",
	}
	if diff := cmp.Diff(wantLog, f.log(t)); diff != "" {
		t.Errorf("calls (-want +got):\n%s", diff)
	}
	wantShown := []string{
		"==> Log in to GitHub",
		"    gh is logged in to github.com",
		"==> Add SSH keys",
		"    ~/.ssh/authorized_keys has keys",
		"==> Choose the dotfiles",
		"    the dotfiles are adopted",
		"==> Turn on linger",
		"    linger is on",
		"==> Set the login shell to zsh",
		"    the login shell is zsh",
		"==> Adopt the dotfiles",
		"    the dotfiles are adopted; bootstrapping again",
		"==> Record that setup is done",
	}
	if diff := cmp.Diff(wantShown, ui.shown); diff != "" {
		t.Errorf("shown (-want +got):\n%s", diff)
	}
}

func TestRunUsesDotfilesChosenEarlier(t *testing.T) {
	f := newFixture(t)
	f.touch(t, filepath.Join(f.dir, "gh-installed"), "")
	f.touch(t, filepath.Join(f.dir, "logged-in"), "")
	f.touch(t, filepath.Join(StateDir(f.home), "dotfiles"), "octo/dotfiles\n")
	f.touch(t, filepath.Join(f.home, ".ssh", "authorized_keys"), "ssh-ed25519 AAAA octo\n")
	ui := &fakeUI{}

	if err := Run(context.Background(), f.opts, ui); err != nil {
		t.Fatal(err)
	}
	if diff := cmp.Diff([]string{"==> Choose the dotfiles", "    using octo/dotfiles, chosen earlier"}, ui.shown[4:6]); diff != "" {
		t.Errorf("shown (-want +got):\n%s", diff)
	}
	if got := f.log(t); got[len(got)-1] != "mise bootstrap --adopt octo/dotfiles --take-remote-all --yes" {
		t.Errorf("last call = %q", got[len(got)-1])
	}
}

func TestRunNeedsDotfilesWithNoOneToAsk(t *testing.T) {
	f := newFixture(t)
	f.opts.TokenStdin = true
	f.opts.Token = "gho_secret"

	err := Run(context.Background(), f.opts, &fakeUI{})
	if !errors.Is(err, ErrNeedDotfiles) {
		t.Fatalf("Run() = %v, want ErrNeedDotfiles", err)
	}
	if log := f.log(t); log != nil {
		t.Errorf("setup ran %q before stopping", log)
	}
	if _, err := os.Stat(StateDir(f.home)); !errors.Is(err, os.ErrNotExist) {
		t.Errorf("setup made its state directory before stopping: %v", err)
	}
}

func TestRunStopsWithoutToken(t *testing.T) {
	f := newFixture(t)
	f.opts.TokenStdin = true
	f.opts.Dotfiles = "octo/dotfiles"

	err := Run(context.Background(), f.opts, &fakeUI{})
	var step *StepError
	if !errors.As(err, &step) || step.Step != "Log in to GitHub" {
		t.Fatalf("Run() = %v, want a failed login", err)
	}
	if _, err := os.Stat(filepath.Join(StateDir(f.home), "setup-done")); !errors.Is(err, os.ErrNotExist) {
		t.Error("setup recorded that it's done")
	}
}

func TestRunStopsOnMissingRepository(t *testing.T) {
	f := newFixture(t)
	f.touch(t, filepath.Join(f.dir, "logged-in"), "")
	f.opts.Dotfiles = "octo/missing"

	err := Run(context.Background(), f.opts, &fakeUI{})
	var step *StepError
	if !errors.As(err, &step) || step.Step != "Choose the dotfiles" || !strings.Contains(err.Error(), "Could not resolve") {
		t.Fatalf("Run() = %v, want a failed choice naming gh's error", err)
	}
}

func TestRunWhileInProgress(t *testing.T) {
	f := newFixture(t)
	f.opts.Dotfiles = "octo/dotfiles"
	state := StateDir(f.home)
	if err := os.MkdirAll(state, 0o755); err != nil {
		t.Fatal(err)
	}
	unlock, err := lock(filepath.Join(state, "setup.lock"))
	if err != nil {
		t.Fatal(err)
	}
	defer unlock()

	if err := Run(context.Background(), f.opts, &fakeUI{}); !errors.Is(err, ErrInProgress) {
		t.Fatalf("Run() = %v, want ErrInProgress", err)
	}
	if log := f.log(t); log != nil {
		t.Errorf("setup ran %q while another run held the lock", log)
	}
}

func TestRunDeviceLoginAndAsk(t *testing.T) {
	f := newFixture(t)
	f.touch(t, filepath.Join(f.dir, "gh-installed"), "")
	polls := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if err := r.ParseForm(); err != nil || r.Form.Get("client_id") != github.ClientID {
			http.Error(w, "bad form", http.StatusBadRequest)
			return
		}
		switch r.URL.Path {
		case "/login/device/code":
			fmt.Fprint(w, `{"device_code":"dev","user_code":"ABCD-1234","verification_uri":"https://github.com/login/device","expires_in":60,"interval":0}`)
		case "/login/oauth/access_token":
			if polls++; polls == 1 {
				fmt.Fprint(w, `{"error":"authorization_pending"}`)
				return
			}
			fmt.Fprint(w, `{"access_token":"gho_device"}`)
		}
	}))
	defer server.Close()
	f.opts.Interactive = true
	f.opts.GitHub = github.DeviceFlow{BaseURL: server.URL, Client: server.Client()}
	// A repository that doesn't exist is asked for again; Enter takes the
	// suggestion.
	ui := &fakeUI{answers: []string{"octo/missing", ""}}

	if err := Run(context.Background(), f.opts, ui); err != nil {
		t.Fatal(err)
	}

	if got := f.read(t, filepath.Join(f.dir, "logged-in")); got != "gho_device\n" {
		t.Errorf("gh got token %q", got)
	}
	want := []string{
		"==> Log in to GitHub",
		"code ABCD-1234 at https://github.com/login/device",
		"==> Add SSH keys",
		"GitHub has no SSH keys for octo. Add one there, then run atelier-setup again to use it here.",
		"==> Choose the dotfiles",
		"? Dotfiles repository (OWNER/REPO) [octo/dotfiles]: ",
		"gh repo view octo/missing --json nameWithOwner --jq .nameWithOwner: GraphQL: Could not resolve to a Repository",
		"? Dotfiles repository (OWNER/REPO) [octo/dotfiles]: ",
	}
	if diff := cmp.Diff(want, ui.shown[:len(want)]); diff != "" {
		t.Errorf("shown (-want +got):\n%s", diff)
	}
	if got := f.read(t, filepath.Join(StateDir(f.home), "dotfiles")); got != "octo/dotfiles\n" {
		t.Errorf("dotfiles file = %q", got)
	}
}

func TestRunJoinsTailnet(t *testing.T) {
	for _, tt := range []struct {
		name        string
		joined      bool
		interactive bool
		wantCalls   []string
		wantShown   []string
	}{
		{
			name:        "joins",
			interactive: true,
			wantCalls:   []string{"tailscale status --json", "sudo tailscale up --qr"},
			wantShown:   []string{"==> Join the tailnet"},
		},
		{
			name:        "already on it",
			joined:      true,
			interactive: true,
			wantCalls:   []string{"tailscale status --json"},
			wantShown:   []string{"==> Join the tailnet", "    this machine is on the tailnet"},
		},
		{
			name:      "no one to approve it",
			wantCalls: []string{"tailscale status --json"},
			wantShown: []string{"==> Join the tailnet", "No one is here to approve it, so join later with: sudo tailscale up --qr"},
		},
	} {
		t.Run(tt.name, func(t *testing.T) {
			f := newFixture(t)
			f.touch(t, filepath.Join(f.dir, "gh-installed"), "")
			f.touch(t, filepath.Join(f.dir, "logged-in"), "")
			if tt.joined {
				f.touch(t, filepath.Join(f.dir, "tailnet"), "")
			}
			f.touch(t, filepath.Join(f.home, ".ssh", "authorized_keys"), "ssh-ed25519 AAAA octo\n")
			f.opts.Dotfiles = "octo/dotfiles"
			f.opts.Interactive = tt.interactive
			f.opts.Tailnet = true
			ui := &fakeUI{}

			if err := Run(context.Background(), f.opts, ui); err != nil {
				t.Fatal(err)
			}

			// After the SSH keys, and before the dotfiles.
			log := f.log(t)
			if diff := cmp.Diff(tt.wantCalls, log[3:3+len(tt.wantCalls)]); diff != "" {
				t.Errorf("calls (-want +got):\n%s", diff)
			}
			if diff := cmp.Diff(tt.wantShown, ui.shown[4:4+len(tt.wantShown)]); diff != "" {
				t.Errorf("shown (-want +got):\n%s", diff)
			}
			if next := ui.shown[4+len(tt.wantShown)]; next != "==> Choose the dotfiles" {
				t.Errorf("next step = %q", next)
			}
		})
	}
}

func TestRunWithoutSSHKeysOnGitHub(t *testing.T) {
	f := newFixture(t)
	f.touch(t, filepath.Join(f.dir, "gh-installed"), "")
	f.touch(t, filepath.Join(f.dir, "logged-in"), "")
	f.opts.Dotfiles = "octo/dotfiles"
	ui := &fakeUI{}

	if err := Run(context.Background(), f.opts, ui); err != nil {
		t.Fatal(err)
	}
	want := []string{"==> Add SSH keys", "GitHub has no SSH keys for octo. Add one there, then run atelier-setup again to use it here."}
	if diff := cmp.Diff(want, ui.shown[2:4]); diff != "" {
		t.Errorf("shown (-want +got):\n%s", diff)
	}
	if _, err := os.Stat(filepath.Join(f.home, ".ssh", "authorized_keys")); !errors.Is(err, os.ErrNotExist) {
		t.Errorf("setup wrote authorized_keys with no keys: %v", err)
	}
}
