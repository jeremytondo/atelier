// Package linux manages an Atelier for Linux machine's system through bootc:
// what it runs, its updates, the channel it follows, and rollback.
//
// A change is always prepared first, then the user decides whether to reboot
// into it. Updates and channel switches download without applying, and the
// download is unlocked for the next boot after the user has chosen, so a
// declined reboot leaves the change waiting for the next one.
package linux

import (
	"context"
	"fmt"
	"regexp"
	"strings"

	"github.com/jeremytondo/atelier/core/internal/integrations/bootc"
)

// Image is Atelier for Linux's image. Its tags are the channels.
const Image = "ghcr.io/jeremytondo/atelier-linux"

var release = regexp.MustCompile(`^v[0-9]+\.[0-9]+\.[0-9]+$`)

// ParseChannel checks a channel's name: stable, dev or a release such as
// v0.2.1, which the machine then stays on.
func ParseChannel(name string) (string, error) {
	if name == "stable" || name == "dev" || release.MatchString(name) {
		return name, nil
	}
	return "", fmt.Errorf("unknown channel %q: use stable, dev or a release such as v0.2.1", name)
}

// channelOf returns the channel an image reference follows, or the whole
// reference when it isn't a tag of Image.
func channelOf(ref *bootc.ImageRef) string {
	if ref == nil {
		return "none"
	}
	if tag, ok := strings.CutPrefix(ref.Image, Image+":"); ok {
		return tag
	}
	return ref.Image
}

// UI is how the machine talks to the user.
type UI interface {
	// Say shows a message.
	Say(message string)
	// Reboot reports whether to reboot now into version, which the next boot
	// starts.
	Reboot(version string) bool
}

// State is what the machine runs, and what it will run.
type State struct {
	// Channel is stable, dev or a release, or the image's whole reference
	// when the machine follows another image.
	Channel string
	Booted  string
	// Downloaded is an update downloaded but not yet applied.
	Downloaded string
	// Next is what the next boot starts, when that isn't Booted.
	Next string
	// NextIsRollback means Next is the rollback version.
	NextIsRollback bool
	Rollback       string
}

// Machine is the machine the core runs on.
type Machine struct {
	Bootc bootc.Bootc
	UI    UI
}

// State reads what the machine runs.
func (m Machine) State(ctx context.Context) (State, error) {
	host, err := m.Bootc.Status(ctx)
	if err != nil {
		return State{}, err
	}
	return stateOf(host), nil
}

func stateOf(host bootc.Host) State {
	status := host.Status
	state := State{
		Channel:  channelOf(host.Spec.Image),
		Booted:   status.Booted.Version(),
		Rollback: status.Rollback.Version(),
	}
	switch {
	case status.RollbackQueued:
		state.Next, state.NextIsRollback = state.Rollback, true
	case status.Staged != nil && status.Staged.DownloadOnly:
		state.Downloaded = status.Staged.Version()
	case status.Staged != nil:
		state.Next = status.Staged.Version()
	}
	return state
}

// Update applies the downloaded update, downloading one first when none is
// waiting.
func (m Machine) Update(ctx context.Context) error {
	state, err := m.State(ctx)
	if err != nil {
		return err
	}
	if release.MatchString(state.Channel) {
		m.UI.Say(fmt.Sprintf("This machine stays on %s. Run atelier os channel stable to follow updates again.", state.Channel))
		return nil
	}
	if state.Next != "" && !state.NextIsRollback {
		return m.applyDownloaded(ctx, state.Next)
	}
	if state.Downloaded == "" {
		if err := m.Bootc.Download(ctx, ""); err != nil {
			return err
		}
		if state, err = m.State(ctx); err != nil {
			return err
		}
		if state.Downloaded == "" {
			m.UI.Say(fmt.Sprintf("%s is up to date.", state.Booted))
			return nil
		}
	}
	return m.applyDownloaded(ctx, state.Downloaded)
}

// Channel returns the channel the machine follows.
func (m Machine) Channel(ctx context.Context) (string, error) {
	state, err := m.State(ctx)
	return state.Channel, err
}

// Switch switches the machine to a channel, from ParseChannel.
func (m Machine) Switch(ctx context.Context, channel string) error {
	state, err := m.State(ctx)
	if err != nil {
		return err
	}
	if state.Channel == channel {
		m.UI.Say(fmt.Sprintf("This machine already follows %s.", channel))
		return nil
	}
	if err := m.Bootc.Download(ctx, Image+":"+channel); err != nil {
		return err
	}
	if state, err = m.State(ctx); err != nil {
		return err
	}
	// bootc stages a switch even to the image already booted, since the
	// machine only follows the new name once it boots the new deployment.
	if state.Downloaded == "" {
		return fmt.Errorf("bootc staged nothing for %s", channel)
	}
	return m.applyDownloaded(ctx, state.Downloaded)
}

// Rollback boots the previous version.
func (m Machine) Rollback(ctx context.Context) error {
	state, err := m.State(ctx)
	if err != nil {
		return err
	}
	if state.Rollback == "" {
		return fmt.Errorf("there's no previous version to roll back to")
	}
	if state.NextIsRollback {
		// Rolling back again would undo it.
		if m.UI.Reboot(state.Next) {
			return m.Bootc.Reboot(ctx)
		}
		m.startsNextBoot(state.Next)
		return nil
	}
	if pending := state.Downloaded + state.Next; pending != "" {
		m.UI.Say(fmt.Sprintf("Rolling back discards %s, which was waiting for the next boot.", pending))
	}
	reboot := m.UI.Reboot(state.Rollback)
	if err := m.Bootc.Rollback(ctx, reboot); err != nil {
		return err
	}
	if !reboot {
		m.startsNextBoot(state.Rollback)
	}
	return nil
}

// applyDownloaded unlocks the staged version, which may already be unlocked,
// for the next boot.
func (m Machine) applyDownloaded(ctx context.Context, version string) error {
	reboot := m.UI.Reboot(version)
	if err := m.Bootc.ApplyDownloaded(ctx, reboot); err != nil {
		return err
	}
	if !reboot {
		m.startsNextBoot(version)
	}
	return nil
}

func (m Machine) startsNextBoot(version string) {
	m.UI.Say(fmt.Sprintf("%s starts at the next reboot.", version))
}
