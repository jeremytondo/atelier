// Command atelier is the Atelier core's command line. It stays thin: the logic
// lives in internal packages that know nothing about flags or terminals.
package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"

	"github.com/spf13/cobra"

	"github.com/jeremytondo/atelier/core/internal/version"
)

func main() {
	if err := run(context.Background(), os.Args[1:], os.Stdin, os.Stdout, os.Stderr); err != nil {
		var exit exitError
		if errors.As(err, &exit) {
			os.Exit(exit.code)
		}
		fmt.Fprintln(os.Stderr, "atelier:", err)
		os.Exit(1)
	}
}

// exitError ends the process with a code. Its message has already been shown.
type exitError struct{ code int }

func (e exitError) Error() string { return fmt.Sprintf("exit status %d", e.code) }

// run executes the command tree with the standard streams injected, so tests
// can drive it. Errors return here, so main owns the exit.
func run(ctx context.Context, args []string, stdin io.Reader, stdout, stderr io.Writer) error {
	root := newRootCmd()
	root.SetIn(stdin)
	root.SetOut(stdout)
	root.SetErr(stderr)
	if args == nil {
		// SetArgs(nil) would make Cobra fall back to os.Args.
		args = []string{}
	}
	root.SetArgs(args)
	return root.ExecuteContext(ctx)
}

func newRootCmd() *cobra.Command {
	cobra.EnableCommandSorting = false
	root := &cobra.Command{
		Use:   "atelier",
		Short: "The Atelier core",
		Long: `The Atelier core sets up and manages the machines of an Atelier
development environment.`,
		// Errors surface once, prefixed "atelier:" in main.
		SilenceUsage:  true,
		SilenceErrors: true,
		Args:          cobra.NoArgs,
	}
	root.AddCommand(newSetupCmd(), newVersionCmd())
	return root
}

func newVersionCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the atelier version",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			_, err := fmt.Fprintln(cmd.OutOrStdout(), version.String())
			return err
		},
	}
}
