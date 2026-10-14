package linux

import "testing"

func TestParseChannel(t *testing.T) {
	for _, name := range []string{"stable", "dev", "v0.2.1", "v10.20.30"} {
		if got, err := ParseChannel(name); got != name || err != nil {
			t.Errorf("ParseChannel(%q) = %q, %v; want it accepted", name, got, err)
		}
	}
	for _, name := range []string{"", "stabel", "Stable", "latest", "0.2.1", "v0.2", "v0.2.1-rc1", "dev-3cf5189a0b1c", "ghcr.io/jeremytondo/atelier-linux:stable"} {
		if got, err := ParseChannel(name); err == nil {
			t.Errorf("ParseChannel(%q) = %q; want it refused", name, got)
		}
	}
}
