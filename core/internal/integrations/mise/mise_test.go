package mise

import (
	"os"
	"path/filepath"
	"testing"
)

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
