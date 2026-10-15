package mise

import (
	"os"
	"path/filepath"
	"testing"
)

func TestChooseModules(t *testing.T) {
	home := t.TempDir()
	wrote, err := ChooseModules(home, "workstation")
	if err != nil || !wrote {
		t.Fatalf("ChooseModules() = %v, %v, want true", wrote, err)
	}
	data, err := os.ReadFile(ModulesFile(home))
	if err != nil {
		t.Fatal(err)
	}
	want := "# The dotfiles' modules this machine loads, config.<name>.toml each.\nenv = [\"workstation\"]\n"
	if string(data) != want {
		t.Errorf("modules file = %q, want %q", data, want)
	}

	// The owner's own choice stays.
	if err := os.WriteFile(ModulesFile(home), []byte("env = []\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	if wrote, err := ChooseModules(home, "workstation"); err != nil || wrote {
		t.Fatalf("ChooseModules() again = %v, %v, want false", wrote, err)
	}
	if data, _ := os.ReadFile(ModulesFile(home)); string(data) != "env = []\n" {
		t.Errorf("modules file = %q, want it unchanged", data)
	}
}

func TestAdopted(t *testing.T) {
	for name, tt := range map[string]struct {
		files map[string]string
		want  bool
	}{
		"fresh machine": {nil, false},
		"adopted": {map[string]string{
			"config.toml":       "",
			"config.local.toml": "[tools]\n\n[history.origin]\nurl = \"x\"\n",
		}, true},
		"paused before restoring the config": {map[string]string{
			"config.local.toml": "[history.origin]\n",
		}, false},
		"config without an origin": {map[string]string{
			"config.toml":       "",
			"config.local.toml": "[tools]\n",
		}, false},
	} {
		t.Run(name, func(t *testing.T) {
			home := t.TempDir()
			dir := filepath.Join(home, ".config", "mise")
			if err := os.MkdirAll(dir, 0o755); err != nil {
				t.Fatal(err)
			}
			for file, content := range tt.files {
				if err := os.WriteFile(filepath.Join(dir, file), []byte(content), 0o644); err != nil {
					t.Fatal(err)
				}
			}
			if got := Adopted(home); got != tt.want {
				t.Errorf("Adopted() = %v, want %v", got, tt.want)
			}
		})
	}
}
