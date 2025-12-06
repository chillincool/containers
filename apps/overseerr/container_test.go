package main

import (
	"context"
	"testing"

	"github.com/chillincool/containers/testhelpers"
)

func Test(t *testing.T) {
	image := testhelpers.GetTestImage("ghcr.io/chillincool/containers/overseerr:local")
	testhelpers.TestHTTPEndpoint(t, context.Background(), image, testhelpers.HTTPTestConfig{Port: "5055", Path: "/api/v1/status"}, nil)
}
