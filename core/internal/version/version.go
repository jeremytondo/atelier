// Package version resolves the binary's build identity.
//
// Version is stamped by the Core release workflow with `-ldflags -X`, so only
// released binaries report a vX.Y.Z version. Every other build, including
// `go install ...@vX.Y.Z`, whose build info carries the module version,
// reports a devel identity instead.
package version

import "runtime/debug"

// Version is the release stamped at build time. It's empty in every build the
// release workflow didn't make.
var Version string

// String returns the build identity `atelier version` prints.
func String() string {
	info, ok := debug.ReadBuildInfo()
	return resolve(Version, info, ok)
}

// resolve prefers the release stamp, then VCS metadata (devel-<sha>,
// devel-<sha>-dirty), then devel or unknown. info.Main.Version is ignored on
// purpose, so a build the workflow didn't make never looks like a release.
func resolve(stamped string, info *debug.BuildInfo, ok bool) string {
	if stamped != "" {
		return stamped
	}
	if !ok {
		return "unknown"
	}
	revision, dirty := "", false
	for _, setting := range info.Settings {
		switch setting.Key {
		case "vcs.revision":
			revision = setting.Value
		case "vcs.modified":
			dirty = setting.Value == "true"
		}
	}
	if revision == "" {
		return "devel"
	}
	if dirty {
		return "devel-" + revision + "-dirty"
	}
	return "devel-" + revision
}
