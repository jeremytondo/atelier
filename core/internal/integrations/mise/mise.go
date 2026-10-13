// Package mise drives mise, which installs Atelier's tools, gh and the core
// among them, and adopts the owner's dotfiles.
package mise

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/jeremytondo/atelier/core/internal/command"
)

// Mise is one mise installation.
type Mise struct {
	Path string
	command.Streams
}

// Find returns mise in ~/.local/bin, where its installer puts it, or else on
// PATH.
func Find(home string) (string, error) {
	path := filepath.Join(home, ".local", "bin", "mise")
	if info, err := os.Stat(path); err == nil && !info.IsDir() && info.Mode()&0o111 != 0 {
		return path, nil
	}
	return exec.LookPath("mise")
}

// Installed returns the newest installed version of a tool, or "" when none
// is installed.
func (m Mise) Installed(ctx context.Context, tool string) (string, error) {
	out, err := command.Output(ctx, m.Path, "ls", "--installed", "--json", tool)
	if err != nil {
		return "", err
	}
	var versions []struct {
		Version string `json:"version"`
	}
	if err := json.Unmarshal([]byte(out), &versions); err != nil {
		return "", fmt.Errorf("reading mise ls: %w", err)
	}
	if len(versions) == 0 {
		return "", nil
	}
	return versions[len(versions)-1].Version, nil
}

// Install installs a tool, such as gh@latest, without adding it to any
// config.
func (m Mise) Install(ctx context.Context, spec string) error {
	return m.Run(ctx, m.Path, "install", spec)
}

// Which returns the path of a program from an installed version of a tool,
// which needn't be in any config.
func (m Mise) Which(ctx context.Context, tool, version, program string) (string, error) {
	path, err := command.Output(ctx, m.Path, "exec", tool+"@"+version, "--", "sh", "-c", `command -v "$0"`, program)
	if err != nil {
		return "", err
	}
	if path == "" {
		return "", fmt.Errorf("%s@%s has no %s", tool, version, program)
	}
	return path, nil
}

// Adopt adopts the dotfiles from a GitHub repository, then installs the tools
// they list. A fresh machine's starter files, such as ~/.zshrc and gh's
// config.yml, differ from the dotfiles, so the dotfiles' versions replace
// them, and mise saves each one first. mise gives its own git commands a
// credential helper that reads gh's login, so the download and the history
// watcher's pushes need nothing more.
func (m Mise) Adopt(ctx context.Context, repo string) error {
	return m.Run(ctx, m.Path, "bootstrap", "--adopt", repo, "--take-remote-all", "--yes")
}

// Bootstrap brings adopted dotfiles up to date and installs their tools.
func (m Mise) Bootstrap(ctx context.Context) error {
	return m.Run(ctx, m.Path, "bootstrap", "--yes")
}

// Adopted reports whether the dotfiles are adopted. Adoption records the
// origin in the machine-local config, then restores the files. An adoption
// that paused has the origin but no restored config, and adopting again
// completes it.
func Adopted(home string) bool {
	dir := filepath.Join(home, ".config", "mise")
	if _, err := os.Stat(filepath.Join(dir, "config.toml")); err != nil {
		return false
	}
	local, err := os.Open(filepath.Join(dir, "config.local.toml"))
	if err != nil {
		return false
	}
	defer local.Close()
	lines := bufio.NewScanner(local)
	for lines.Scan() {
		if strings.HasPrefix(lines.Text(), "[history.origin]") {
			return true
		}
	}
	return false
}
