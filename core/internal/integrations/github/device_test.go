package github

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
)

// serve answers polls in order, repeating the last reply.
func serve(t *testing.T, replies ...string) DeviceFlow {
	t.Helper()
	polls := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Accept") != "application/json" {
			http.Error(w, "not JSON", http.StatusNotAcceptable)
			return
		}
		if err := r.ParseForm(); err != nil || r.Form.Get("device_code") != "dev" {
			http.Error(w, "bad form", http.StatusBadRequest)
			return
		}
		reply := replies[min(polls, len(replies)-1)]
		polls++
		if reply == "500" {
			http.Error(w, "unavailable", http.StatusInternalServerError)
			return
		}
		fmt.Fprint(w, reply)
	}))
	t.Cleanup(server.Close)
	return DeviceFlow{BaseURL: server.URL, Client: server.Client()}
}

func TestWait(t *testing.T) {
	code := Code{DeviceCode: "dev", ExpiresIn: 60}
	for name, tt := range map[string]struct {
		replies []string
		token   string
		err     error
	}{
		"approved after pending":   {[]string{`{"error":"authorization_pending"}`, `{"access_token":"gho_x"}`}, "gho_x", nil},
		"a failed poll is retried": {[]string{"500", `{"access_token":"gho_x"}`}, "gho_x", nil},
		"slow down":                {[]string{`{"error":"slow_down","interval":1}`, `{"access_token":"gho_x"}`}, "gho_x", nil},
		"expired":                  {[]string{`{"error":"expired_token"}`}, "", ErrExpired},
		"denied":                   {[]string{`{"error":"access_denied"}`}, "", ErrDenied},
	} {
		t.Run(name, func(t *testing.T) {
			token, err := serve(t, tt.replies...).Wait(context.Background(), code)
			if token != tt.token || !errors.Is(err, tt.err) {
				t.Errorf("Wait() = %q, %v; want %q, %v", token, err, tt.token, tt.err)
			}
		})
	}
}

func TestWaitRefused(t *testing.T) {
	_, err := serve(t, `{"error":"unsupported_grant_type"}`).Wait(context.Background(), Code{DeviceCode: "dev", ExpiresIn: 60})
	if err == nil || err.Error() != "GitHub refused the login: unsupported_grant_type" {
		t.Errorf("Wait() = %v", err)
	}
}

func TestWaitExpiresWithoutAnswer(t *testing.T) {
	_, err := serve(t, `{"error":"authorization_pending"}`).Wait(context.Background(), Code{DeviceCode: "dev", ExpiresIn: 0})
	if !errors.Is(err, ErrExpired) {
		t.Errorf("Wait() = %v, want ErrExpired", err)
	}
}

func TestCodeURI(t *testing.T) {
	code := Code{VerificationURI: "https://github.com/login/device"}
	if got := code.URI(); got != code.VerificationURI {
		t.Errorf("URI() = %q", got)
	}
	code.VerificationURIComplete = "https://github.com/login/device?user_code=ABCD"
	if got := code.URI(); got != code.VerificationURIComplete {
		t.Errorf("URI() = %q", got)
	}
}
