package project

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/spf13/cobra"
)

// projectCmd represents the project command
var createCmd = &cobra.Command{
	Use:   "create",
	Short: "Create a new project",
	Long: `
  Creates a folder in the default projects directory and then opens the
  project.`,
	Run: func(cmd *cobra.Command, args []string) {
		homeDir, _ := os.UserHomeDir()
		projectsDir := "projects"
		projectName, _ := cmd.Flags().GetString("name")
		projectPath := filepath.Join(homeDir, projectsDir, projectName)

		if err := createProject(projectPath); err != nil {
			fmt.Println("There was an error creating the project", err)
		} else {
			fmt.Println("Project successfully created.")
			openProject(projectName, projectPath)
		}
	},
}

func init() {
	createCmd.Flags().StringP("name", "n", "", "Name of the project to create")
	createCmd.MarkFlagRequired("name")
}

func createProject(projectPath string) error {
	err := os.Mkdir(projectPath, 0755) // Create the directory with read, write, and execute permissions
	if err != nil {
		fmt.Println("Error creating project:", err)
		return err
	}
	return nil
}
