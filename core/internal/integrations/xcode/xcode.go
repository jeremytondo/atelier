// Package xcode drives xcode-select, which installs Apple's Command Line
// Tools. They bring git, which mise needs to adopt the dotfiles, and the
// compilers some tools build with. A fresh Mac has only stubs that ask for
// them.
package xcode

import (
	"context"
	"os"
	"path/filepath"

	"github.com/jeremytondo/atelier/core/internal/command"
)

// Installed reports whether the Command Line Tools, or Xcode, which includes
// them, are installed: xcode-select points at a developer directory whose git
// can run.
func Installed(ctx context.Context) bool {
	dir, err := command.Output(ctx, "xcode-select", "--print-path")
	if err != nil || dir == "" {
		return false
	}
	info, err := os.Stat(filepath.Join(dir, "usr", "bin", "git"))
	return err == nil && info.Mode().IsRegular() && info.Mode().Perm()&0o111 != 0
}

// Install asks macOS to install the Command Line Tools. macOS shows a dialog
// on the Mac's screen, and Install returns once it's shown, well before the
// tools are installed. It fails when macOS doesn't start an install, and
// says why.
func Install(ctx context.Context) error {
	_, err := command.Output(ctx, "xcode-select", "--install")
	return err
}
