// Package bootc drives bootc, which updates, switches and rolls back an
// image-based Linux system. Every bootc command needs root, so each runs
// through sudo, which may ask for a password.
package bootc

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jeremytondo/atelier/core/internal/command"
)

// Bootc is the machine's bootc. Its streams are shared with the commands that
// change the machine, so their progress and sudo's prompt reach the user.
type Bootc struct {
	command.Streams
}

// Host is what `bootc status --json` reports.
type Host struct {
	Spec struct {
		// Image is the image the machine follows, or nil when it follows none.
		Image *ImageRef `json:"image"`
	} `json:"spec"`
	Status struct {
		Booted *Entry `json:"booted"`
		// Staged is an update waiting for the next boot.
		Staged   *Entry `json:"staged"`
		Rollback *Entry `json:"rollback"`
		// RollbackQueued means the next boot starts the rollback entry.
		RollbackQueued bool `json:"rollbackQueued"`
	} `json:"status"`
}

// ImageRef names an image, such as ghcr.io/jeremytondo/atelier-linux:stable.
type ImageRef struct {
	Image string `json:"image"`
}

// Entry is one bootable version of the system.
type Entry struct {
	Image *struct {
		Image       ImageRef `json:"image"`
		Version     string   `json:"version"`
		ImageDigest string   `json:"imageDigest"`
	} `json:"image"`
	// DownloadOnly means a staged entry was downloaded but won't be applied
	// until it's unlocked.
	DownloadOnly bool `json:"downloadOnly"`
}

// Version returns the entry's version label, or a short digest when the image
// has none.
func (e *Entry) Version() string {
	switch {
	case e == nil || e.Image == nil:
		return ""
	case e.Image.Version != "":
		return e.Image.Version
	case len(e.Image.ImageDigest) > len("sha256:")+12:
		return e.Image.ImageDigest[:len("sha256:")+12]
	default:
		return e.Image.ImageDigest
	}
}

// Status reads the machine's state.
func (b Bootc) Status(ctx context.Context) (Host, error) {
	var host Host
	out, err := command.Output(ctx, "sudo", "bootc", "status", "--json")
	if err != nil {
		return host, err
	}
	if err := json.Unmarshal([]byte(out), &host); err != nil {
		return host, fmt.Errorf("reading bootc status: %w", err)
	}
	return host, nil
}

// Download downloads the newest version of the image the machine follows, or
// of another image when target isn't empty, and stages it without applying
// it.
func (b Bootc) Download(ctx context.Context, target string) error {
	if target == "" {
		return b.bootc(ctx, "upgrade", "--download-only")
	}
	return b.bootc(ctx, "switch", "--download-only", target)
}

// ApplyDownloaded unlocks the staged version for the next boot, however it was
// staged, and with reboot, reboots into it.
func (b Bootc) ApplyDownloaded(ctx context.Context, reboot bool) error {
	return b.bootc(ctx, apply([]string{"upgrade", "--from-downloaded"}, reboot)...)
}

// Rollback queues the rollback entry for the next boot, discarding any staged
// update, and with reboot, reboots into it.
func (b Bootc) Rollback(ctx context.Context, reboot bool) error {
	return b.bootc(ctx, apply([]string{"rollback"}, reboot)...)
}

// Reboot reboots the machine, which starts whatever is queued for the next
// boot. It's for a queued rollback, which rolling back again would undo.
func (b Bootc) Reboot(ctx context.Context) error {
	return b.Run(ctx, "sudo", "systemctl", "reboot")
}

func (b Bootc) bootc(ctx context.Context, args ...string) error {
	return b.Run(ctx, "sudo", append([]string{"bootc"}, args...)...)
}

func apply(args []string, reboot bool) []string {
	if reboot {
		return append(args, "--apply")
	}
	return args
}
