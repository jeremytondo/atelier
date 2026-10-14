// Package tailscale reads Tailscale's state. Joining the tailnet needs root,
// so setup runs `tailscale up` itself, through sudo.
package tailscale

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/jeremytondo/atelier/core/internal/command"
)

// Joined reports whether the machine is on the tailnet. Any user can ask.
func Joined(ctx context.Context) (bool, error) {
	out, err := command.Output(ctx, "tailscale", "status", "--json")
	if err != nil {
		return false, err
	}
	var status struct {
		BackendState string
	}
	if err := json.Unmarshal([]byte(out), &status); err != nil {
		return false, fmt.Errorf("reading tailscale status: %w", err)
	}
	return status.BackendState == "Running", nil
}
