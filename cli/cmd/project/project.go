package project

import (
	"github.com/spf13/cobra"
)

// projectCmd represents the project command
var ProjectCmd = &cobra.Command{
	Use:   "project",
	Short: "A set of commands for working with dev projects",
}

func init() {
	ProjectCmd.AddCommand(createCmd)
	ProjectCmd.AddCommand(openCmd)
	ProjectCmd.AddCommand(listCmd)

	// Command aliases
	openCmd.Aliases = []string{"o"}
	createCmd.Aliases = []string{"c"}
}
