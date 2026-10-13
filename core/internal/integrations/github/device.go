// Package github logs in to GitHub with the OAuth device flow, as `gh auth
// login --web` does, so that setup can show the address as a QR code for a
// phone to approve.
package github

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// gh's own OAuth app, and the scopes `gh auth login` asks for, so the token is
// one gh could have made itself.
const (
	ClientID = "178c6fc778ccc68e1d6a"
	Scopes   = "repo read:org gist"
)

var (
	ErrExpired = errors.New("the code expired")
	ErrDenied  = errors.New("the login was cancelled on GitHub")
)

// DeviceFlow talks to GitHub's device flow endpoints.
type DeviceFlow struct {
	// BaseURL is https://github.com outside tests.
	BaseURL string
	Client  *http.Client
}

// Code is a device code and what the user needs to approve it.
type Code struct {
	DeviceCode              string `json:"device_code"`
	UserCode                string `json:"user_code"`
	VerificationURI         string `json:"verification_uri"`
	VerificationURIComplete string `json:"verification_uri_complete"`
	ExpiresIn               int    `json:"expires_in"`
	Interval                int    `json:"interval"`
}

// URI is the address to open. GitHub sends no verification_uri_complete
// today; it's used if it ever does.
func (c Code) URI() string {
	if c.VerificationURIComplete != "" {
		return c.VerificationURIComplete
	}
	return c.VerificationURI
}

// Request asks GitHub for a new device code.
func (f DeviceFlow) Request(ctx context.Context) (Code, error) {
	var code Code
	err := f.post(ctx, "/login/device/code", url.Values{"client_id": {ClientID}, "scope": {Scopes}}, &code)
	if err != nil {
		return Code{}, fmt.Errorf("requesting a device code: %w", err)
	}
	if code.DeviceCode == "" || code.UserCode == "" {
		return Code{}, errors.New("requesting a device code: GitHub sent no code")
	}
	return code, nil
}

// Wait polls GitHub until the code is approved and returns the token. It
// returns ErrExpired when the code expires first, and ErrDenied when the user
// cancels.
func (f DeviceFlow) Wait(ctx context.Context, code Code) (string, error) {
	interval := time.Duration(code.Interval) * time.Second
	deadline := time.Now().Add(time.Duration(code.ExpiresIn) * time.Second)
	for time.Now().Before(deadline) {
		select {
		case <-ctx.Done():
			return "", ctx.Err()
		case <-time.After(interval):
		}
		var reply struct {
			AccessToken string `json:"access_token"`
			Error       string `json:"error"`
			Interval    int    `json:"interval"`
		}
		err := f.post(ctx, "/login/oauth/access_token", url.Values{
			"client_id":   {ClientID},
			"device_code": {code.DeviceCode},
			"grant_type":  {"urn:ietf:params:oauth:grant-type:device_code"},
		}, &reply)
		if err != nil {
			// A dropped request is retried at the next poll.
			continue
		}
		switch reply.Error {
		case "":
			if reply.AccessToken == "" {
				return "", errors.New("GitHub sent no token")
			}
			return reply.AccessToken, nil
		case "authorization_pending":
		case "slow_down":
			if reply.Interval > 0 {
				interval = time.Duration(reply.Interval) * time.Second
			} else {
				interval += 5 * time.Second
			}
		case "expired_token":
			return "", ErrExpired
		case "access_denied":
			return "", ErrDenied
		default:
			return "", fmt.Errorf("GitHub refused the login: %s", reply.Error)
		}
	}
	return "", ErrExpired
}

func (f DeviceFlow) post(ctx context.Context, path string, form url.Values, reply any) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, f.BaseURL+path, strings.NewReader(form.Encode()))
	if err != nil {
		return err
	}
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	client := f.Client
	if client == nil {
		client = http.DefaultClient
	}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	if resp.StatusCode/100 != 2 {
		return fmt.Errorf("%s: %s", path, resp.Status)
	}
	return json.NewDecoder(resp.Body).Decode(reply)
}
