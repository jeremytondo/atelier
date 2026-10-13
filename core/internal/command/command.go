// Package command runs the external programs Atelier drives, such as mise, gh
// and sudo. A program either shares the user's streams, so its own output and
// prompts reach them, or runs for what it prints. Either way, a failure names
// the program, and carries its stderr when that was captured.
package command

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"os/exec"
	"path/filepath"
	"strings"
)

// Streams are what a program shares with the user.
type Streams struct {
	// Stdin is nil, which reads as /dev/null, when nothing may be read from
	// the user: with a token on standard input, nothing else may read it.
	Stdin  io.Reader
	Stdout io.Writer
	Stderr io.Writer
}

// Run runs a program on the streams.
func (s Streams) Run(ctx context.Context, name string, args ...string) error {
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Stdin, cmd.Stdout, cmd.Stderr = s.Stdin, s.Stdout, s.Stderr
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%s: %w", describe(name, args), err)
	}
	return nil
}

// WithStdin returns the streams with stdin replaced.
func (s Streams) WithStdin(stdin io.Reader) Streams {
	s.Stdin = stdin
	return s
}

// Output runs a program with no input and returns what it prints, trimmed.
func Output(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	var stdout, stderr bytes.Buffer
	cmd.Stdout, cmd.Stderr = &stdout, &stderr
	if err := cmd.Run(); err != nil {
		if detail := strings.TrimSpace(stderr.String()); detail != "" {
			return "", fmt.Errorf("%s: %s", describe(name, args), detail)
		}
		return "", fmt.Errorf("%s: %w", describe(name, args), err)
	}
	return strings.TrimSpace(stdout.String()), nil
}

func describe(name string, args []string) string {
	return strings.Join(append([]string{filepath.Base(name)}, args...), " ")
}
