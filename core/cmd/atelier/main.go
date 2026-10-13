// Command atelier is the Atelier core's command line. It stays thin: the logic
// lives in internal packages that know nothing about flags or terminals.
package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/spf13/cobra"

	"github.com/jeremytondo/atelier/core/internal/system"
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

// atelierLinux is held in a variable so tests can replace the machine's own
// image.
var atelierLinux = system.AtelierLinux

func newVersionCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the versions of the parts of Atelier on this machine",
		Args:  cobra.NoArgs,
		RunE: func(cmd *cobra.Command, _ []string) error {
			rows := [][2]string{{"Atelier Core", version.String()}}
			if image, ok := atelierLinux(); ok {
				rows = append(rows, [2]string{"Atelier Linux", image})
			}
			_, err := fmt.Fprint(cmd.OutOrStdout(), columns(rows))
			return err
		},
	}
}

// columns lines up name and version pairs, two spaces apart.
func columns(rows [][2]string) string {
	width := 0
	for _, row := range rows {
		width = max(width, len(row[0]))
	}
	var out strings.Builder
	for _, row := range rows {
		line := fmt.Sprintf("%-*s  %s", width, row[0], row[1])
		out.WriteString(strings.TrimRight(line, " ") + "\n")
	}
	return out.String()
}
