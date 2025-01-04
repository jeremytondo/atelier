package project

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/charmbracelet/huh"
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
			fmt.Println("Project folder created:", projectPath)

			// Offer to clone a git repo into the new project directory.
			var gitRepo string
			huh.NewInput().
				Title("Would you like to clone a git repo? (Leave blank for empty project)").
				Value(&gitRepo).
				Run()

			if gitRepo != "" {
				cloneRepo(projectPath, gitRepo)
			}

			// Open the new project.
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
		fmt.Println("Error creating project directory:", err)
		return err
	}

	return nil
}

func cloneRepo(projectPath string, gitRepo string) error {
	cmd := exec.Command("gh", "repo", "clone", gitRepo, projectPath)

	fmt.Println("Cloning repo...")
	_, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("Error")
	}

	fmt.Println("Cloned repo", gitRepo)
	return nil
}
