package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"strings"

	"github.com/spf13/cobra"

	"github.com/jeremytondo/atelier/core/internal/command"
	"github.com/jeremytondo/atelier/core/internal/integrations/bootc"
	"github.com/jeremytondo/atelier/core/internal/linux"
)

func newOSCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "os",
		Short: "Show and manage this machine's Atelier for Linux system",
		Long: `Shows the version this machine runs, any downloaded update, the version a
rollback returns to, and the channel the machine follows: stable, dev or a
release it stays on.

update, channel and rollback prepare their change, then ask before rebooting
into it. --reboot reboots without asking. Without a terminal to ask on, they
never reboot unless --reboot is given, and the change starts at the next
reboot.`,
		Args: cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			machine, err := newMachine(cmd, false)
			if err != nil {
				return err
			}
			state, err := machine.State(cmd.Context())
			if err != nil {
				return err
			}
			_, err = fmt.Fprint(cmd.OutOrStdout(), columns(stateRows(state)))
			return err
		},
	}
	cmd.AddCommand(newOSUpdateCmd(), newOSChannelCmd(), newOSRollbackCmd())
	return cmd
}

func newOSUpdateCmd() *cobra.Command {
	var reboot bool
	cmd := &cobra.Command{
		Use:   "update [--reboot]",
		Short: "Apply the downloaded update, downloading one first if none is waiting",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			machine, err := newMachine(cmd, reboot)
			if err != nil {
				return err
			}
			return machine.Update(cmd.Context())
		},
	}
	addRebootFlag(cmd, &reboot)
	return cmd
}

func newOSChannelCmd() *cobra.Command {
	var reboot bool
	cmd := &cobra.Command{
		Use:   "channel [stable|dev|vX.Y.Z] [--reboot]",
		Short: "Show the channel this machine follows, or switch it",
		Long: `Without a channel, shows the one this machine follows. With one, switches to
it: stable for releases, dev for builds of main or a branch, or a release such
as v0.2.1, which the machine then stays on until it switches back.`,
		Args: cobra.MaximumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			machine, err := newMachine(cmd, reboot)
			if err != nil {
				return err
			}
			if len(args) == 0 {
				channel, err := machine.Channel(cmd.Context())
				if err != nil {
					return err
				}
				_, err = fmt.Fprintln(cmd.OutOrStdout(), channel)
				return err
			}
			channel, err := linux.ParseChannel(args[0])
			if err != nil {
				return err
			}
			return machine.Switch(cmd.Context(), channel)
		},
	}
	addRebootFlag(cmd, &reboot)
	return cmd
}

func newOSRollbackCmd() *cobra.Command {
	var reboot bool
	cmd := &cobra.Command{
		Use:   "rollback [--reboot]",
		Short: "Boot the previous version",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			machine, err := newMachine(cmd, reboot)
			if err != nil {
				return err
			}
			return machine.Rollback(cmd.Context())
		},
	}
	addRebootFlag(cmd, &reboot)
	return cmd
}

func addRebootFlag(cmd *cobra.Command, reboot *bool) {
	cmd.Flags().BoolVar(reboot, "reboot", false, "reboot into the change without asking")
}

// newMachine is the machine's system, when it runs Atelier for Linux.
func newMachine(cmd *cobra.Command, reboot bool) (linux.Machine, error) {
	if _, ok := atelierLinux(); !ok {
		return linux.Machine{}, errors.New("this machine doesn't run Atelier for Linux, so atelier os has nothing to manage")
	}
	stdin, stdout := cmd.InOrStdin(), cmd.OutOrStdout()
	return linux.Machine{
		Bootc: bootc.Bootc{Streams: command.Streams{Stdin: stdin, Stdout: stdout, Stderr: cmd.ErrOrStderr()}},
		UI:    &osUI{in: bufio.NewReader(stdin), out: stdout, reboot: reboot, interactive: isTerminal(stdin)},
	}, nil
}

func stateRows(state linux.State) [][2]string {
	rows := [][2]string{{"Channel", state.Channel}, {"Booted", state.Booted}}
	if state.Downloaded != "" {
		rows = append(rows, [2]string{"Downloaded", state.Downloaded})
	}
	switch {
	case state.NextIsRollback:
		rows = append(rows, [2]string{"Next boot", state.Next + " (rollback)"})
	case state.Next != "":
		rows = append(rows, [2]string{"Next boot", state.Next})
	}
	if state.Rollback != "" {
		rows = append(rows, [2]string{"Rollback", state.Rollback})
	}
	return rows
}

// osUI asks before rebooting. With --reboot it never asks, and with no one to
// ask it never reboots.
type osUI struct {
	in          *bufio.Reader
	out         io.Writer
	reboot      bool
	interactive bool
}

func (u *osUI) Say(message string) { fmt.Fprintln(u.out, message) }

func (u *osUI) Reboot(version string) bool {
	if u.reboot {
		return true
	}
	if !u.interactive {
		return false
	}
	fmt.Fprintf(u.out, "Reboot into %s now? [y/N] ", version)
	line, _ := u.in.ReadString('\n')
	answer := strings.ToLower(strings.TrimSpace(line))
	return answer == "y" || answer == "yes"
}
