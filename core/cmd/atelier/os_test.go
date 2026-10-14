package main

import (
	"bufio"
	"context"
	"strings"
	"testing"
)

func TestOSReboot(t *testing.T) {
	for name, tt := range map[string]struct {
		reboot      bool
		interactive bool
		answer      string
		want        bool
		asks        bool
	}{
		"--reboot doesn't ask":        {reboot: true, interactive: true, want: true},
		"--reboot without a terminal": {reboot: true, want: true},
		"no terminal never reboots":   {answer: "y\n"},
		"yes":                         {interactive: true, answer: "y\n", want: true, asks: true},
		"yes in full":                 {interactive: true, answer: " Yes \n", want: true, asks: true},
		"no":                          {interactive: true, answer: "n\n", asks: true},
		"just enter means no":         {interactive: true, answer: "\n", asks: true},
		"the end of input means no":   {interactive: true, asks: true},
		"anything else means no":      {interactive: true, answer: "sure\n", asks: true},
	} {
		t.Run(name, func(t *testing.T) {
			var out strings.Builder
			ui := &osUI{in: bufio.NewReader(strings.NewReader(tt.answer)), out: &out, reboot: tt.reboot, interactive: tt.interactive}
			if got := ui.Reboot("v0.2.2"); got != tt.want {
				t.Errorf("Reboot() = %v, want %v", got, tt.want)
			}
			if asked := out.String() == "Reboot into v0.2.2 now? [y/N] "; asked != tt.asks {
				t.Errorf("printed %q, want asking %v", out.String(), tt.asks)
			}
		})
	}
}

func TestOSChannelRefusesUnknown(t *testing.T) {
	saved := atelierLinux
	t.Cleanup(func() { atelierLinux = saved })
	atelierLinux = func() (string, bool) { return "v0.2.1", true }

	var stdout, stderr strings.Builder
	err := run(context.Background(), []string{"os", "channel", "stabel"}, strings.NewReader(""), &stdout, &stderr)
	want := `unknown channel "stabel": use stable, dev or a release such as v0.2.1`
	if err == nil || err.Error() != want {
		t.Errorf("os channel stabel = %v, want %q", err, want)
	}
	if stdout.String() != "" || stderr.String() != "" {
		t.Errorf("printed %q and %q, want nothing, since bootc never runs", stdout.String(), stderr.String())
	}
}
