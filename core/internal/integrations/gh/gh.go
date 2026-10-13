// Package gh drives the GitHub CLI. Its login is the one setup makes, and the
// one the dotfiles and their history watcher use.
package gh

import (
	"context"
	"strings"

	"github.com/jeremytondo/atelier/core/internal/command"
)

// Host is the GitHub host setup logs in to.
const Host = "github.com"

// GH is one gh installation.
type GH struct {
	Path string
	command.Streams
}

// LoggedIn reports whether gh has a working login to github.com.
func (g GH) LoggedIn(ctx context.Context) bool {
	_, err := command.Output(ctx, g.Path, "auth", "status", "--hostname", Host)
	return err == nil
}

// LogIn stores a token as gh's login to github.com. The token goes through
// stdin, never an argument.
func (g GH) LogIn(ctx context.Context, token string) error {
	return g.WithStdin(strings.NewReader(token+"\n")).Run(ctx, g.Path, "auth", "login", "--hostname", Host, "--with-token")
}

// RepoName returns GitHub's name for a repository given as OWNER/REPO or a
// URL, and fails when it doesn't exist.
func (g GH) RepoName(ctx context.Context, repo string) (string, error) {
	return command.Output(ctx, g.Path, "repo", "view", repo, "--json", "nameWithOwner", "--jq", ".nameWithOwner")
}

// User returns the login gh is logged in as.
func (g GH) User(ctx context.Context) (string, error) {
	return command.Output(ctx, g.Path, "api", "user", "--jq", ".login")
}
