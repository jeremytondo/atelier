package system

import (
	"strings"
	"testing"
)

func TestAtelierLinux(t *testing.T) {
	for name, tt := range map[string]struct {
		osRelease string
		version   string
		ok        bool
	}{
		"a release": {`NAME="Fedora Linux"
VERSION_ID=44
IMAGE_ID=atelier-linux
IMAGE_VERSION=v0.2.1
`, "v0.2.1", true},
		"a dev image":      {"IMAGE_ID=\"atelier-linux\"\nIMAGE_VERSION='dev-3cf5189a0b1c'\n", "dev-3cf5189a0b1c", true},
		"another system":   {"# comment\nNAME=\"Fedora Linux\"\nVERSION_ID=44\n", "", false},
		"empty os-release": {"", "", false},
	} {
		t.Run(name, func(t *testing.T) {
			version, ok := atelierLinux(parseOSRelease(strings.NewReader(tt.osRelease)))
			if version != tt.version || ok != tt.ok {
				t.Errorf("atelierLinux() = %q, %v; want %q, %v", version, ok, tt.version, tt.ok)
			}
		})
	}
}
