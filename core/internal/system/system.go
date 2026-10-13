// Package system describes the machine the core runs on.
package system

import (
	"bufio"
	"io"
	"os"
	"strings"
)

// osRelease lists where Linux keeps its os-release file, in the order
// os-release(5) reads them.
var osRelease = []string{"/etc/os-release", "/usr/lib/os-release"}

// AtelierLinux returns the version of the Atelier Linux image the machine runs,
// vX.Y.Z or dev-<commit>, and false on any other system.
func AtelierLinux() (string, bool) {
	for _, path := range osRelease {
		file, err := os.Open(path)
		if err != nil {
			continue
		}
		defer file.Close()
		return atelierLinux(parseOSRelease(file))
	}
	return "", false
}

func atelierLinux(fields map[string]string) (string, bool) {
	if fields["IMAGE_ID"] != "atelier-linux" {
		return "", false
	}
	return fields["IMAGE_VERSION"], true
}

// parseOSRelease reads os-release's KEY=value lines, with their values
// unquoted.
func parseOSRelease(r io.Reader) map[string]string {
	fields := map[string]string{}
	lines := bufio.NewScanner(r)
	for lines.Scan() {
		key, value, ok := strings.Cut(strings.TrimSpace(lines.Text()), "=")
		if !ok || strings.HasPrefix(key, "#") {
			continue
		}
		if len(value) >= 2 && (value[0] == '"' || value[0] == '\'') && value[len(value)-1] == value[0] {
			value = value[1 : len(value)-1]
		}
		fields[key] = value
	}
	return fields
}
