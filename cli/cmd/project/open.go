package project

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/spf13/cobra"
)

var openCmd = &cobra.Command{
	Use:   "open",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		homeDir, _ := os.UserHomeDir()
		projectsDir := "projects"
		projectName, _ := cmd.Flags().GetString("name")
		projectPath := filepath.Join(homeDir, projectsDir, projectName)

		// Handle the special use case when editing Atelier directly.
		if projectName == "atelier" {
			projectPath = filepath.Join(homeDir, ".local/share/atelier")
		}
		fmt.Println("project open called with name:", projectPath)

		// Check if the project exists.
		_, err := os.Stat(projectPath)
		if os.IsNotExist(err) {
			// TODO: Eventually ask if user wants to create a project.
			fmt.Println("Project does not exist.")
			return
		}

		openProject(projectName, projectPath)
	},
}

func init() {
	openCmd.Flags().StringP("name", "n", "", "Name of the project to open")
}

func openProject(projectName string, projectPath string) error {
	// Helper function to run tmux commands
	runTmuxCmd := func(args ...string) error {
		cmd := exec.Command("tmux", args...)
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	}

	// Attempt to attach to existing project session
	err := runTmuxCmd("attach-session", "-t", projectName)
	if err == nil {
		return nil
	}

	// If a session does not exist, create a new one.
	args := []string{"new-session", "-s", projectName, "-d", "-c", projectPath, "nvim", "."}
	if err := runTmuxCmd(args...); err != nil {
		return fmt.Errorf("failed to create new session: %w", err)
	}

	cmdOpenTmuxWindow := []string{"new-window", "-t", projectName, "-c", projectPath}
	if err := runTmuxCmd(cmdOpenTmuxWindow...); err != nil {
		return fmt.Errorf("failed to open window: %w", err)
	}

	cmdSwitchToFirstWindow := []string{"select-window", "-t", projectName + ":1"}
	if err := runTmuxCmd(cmdSwitchToFirstWindow...); err != nil {
		return fmt.Errorf("failed to switch window: %w", err)
	}
	// Create a new window
	// cmd = exec.Command("tmux", "new-window", "-t", projectName+":2", "-c", projectFolder)
	// if err := cmd.Run(); err != nil {
	// 	return fmt.Errorf("failed to create new window: %w", err)
	// }
	//
	// // Switch back the first window
	// cmd = exec.Command("tmux", "select-window", "-t", projectName+":1")
	// if err := cmd.Run(); err != nil {
	// 	return fmt.Errorf("failed to switch to first window: %w", err)
	// }

	// Attach to the newly created session
	return runTmuxCmd("attach-session", "-t", projectName)
}