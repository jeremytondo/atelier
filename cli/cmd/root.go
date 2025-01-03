package cmd

import (
	"os"

	"github.com/jeremytondo/atelier/cli/cmd/project"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "atelier",
	Short: "A simple CLI for common development environment tasks",
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	err := rootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(project.ProjectCmd)

	// Add an alias for the project command
	project.ProjectCmd.Aliases = []string{"p"}
}
