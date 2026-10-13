package main

import (
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"

	"github.com/jeremytondo/atelier/core/internal/version"
)

func TestVersion(t *testing.T) {
	saved := version.Version
	version.Version = "v1.2.3"
	t.Cleanup(func() { version.Version = saved })

	var stdout, stderr strings.Builder
	if err := run(context.Background(), []string{"version"}, strings.NewReader(""), &stdout, &stderr); err != nil {
		t.Fatal(err)
	}
	if got := stdout.String(); got != "v1.2.3\n" {
		t.Errorf("version printed %q", got)
	}
}

func TestSetupNeedsDotfilesWithoutTerminal(t *testing.T) {
	t.Setenv("HOME", t.TempDir())
	var stdout, stderr strings.Builder
	err := run(context.Background(), []string{"setup", "--token-stdin"}, strings.NewReader("gho_secret\n"), &stdout, &stderr)
	var exit exitError
	if !errors.As(err, &exit) || exit.code != 2 {
		t.Fatalf("setup = %v, want exit status 2", err)
	}
	if got := stderr.String(); got != "atelier setup: name the dotfiles repository with --dotfiles OWNER/REPO\n" {
		t.Errorf("stderr = %q", got)
	}
}

func TestBig(t *testing.T) {
	want := []string{
		"   ███  ████        ",
		"  █   █ █   █       ",
		"  █████ ████   ███  ",
		"  █   █ █   █       ",
		"  █   █ ████        ",
	}
	if diff := cmp.Diff(want, strings.Split(strings.TrimSuffix(big("AB-"), "\n"), "\n")); diff != "" {
		t.Errorf("big (-want +got):\n%s", diff)
	}
}
