package version

import (
	"runtime/debug"
	"testing"
)

func TestResolve(t *testing.T) {
	// What `go install github.com/jeremytondo/atelier/core/cmd/atelier@v0.1.0`
	// embeds: a release-shaped module version with no stamp.
	goInstall := &debug.BuildInfo{Main: debug.Module{Version: "v0.1.0"}}
	vcs := &debug.BuildInfo{Settings: []debug.BuildSetting{
		{Key: "vcs.revision", Value: "3cf5189"},
		{Key: "vcs.modified", Value: "false"},
	}}
	dirty := &debug.BuildInfo{Settings: []debug.BuildSetting{
		{Key: "vcs.revision", Value: "3cf5189"},
		{Key: "vcs.modified", Value: "true"},
	}}
	for name, tt := range map[string]struct {
		stamped string
		info    *debug.BuildInfo
		ok      bool
		want    string
	}{
		"stamped release":         {"v0.1.0", vcs, true, "v0.1.0"},
		"go install is not stamp": {"", goInstall, true, "devel"},
		"vcs build":               {"", vcs, true, "devel-3cf5189"},
		"dirty vcs build":         {"", dirty, true, "devel-3cf5189-dirty"},
		"no build info":           {"", nil, false, "unknown"},
	} {
		t.Run(name, func(t *testing.T) {
			if got := resolve(tt.stamped, tt.info, tt.ok); got != tt.want {
				t.Errorf("resolve() = %q, want %q", got, tt.want)
			}
		})
	}
}
