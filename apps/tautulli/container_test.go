package main

import (
	"context"
	"testing"

	"github.com/chillincool/containers/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/chillincool/containers/tautulli:local")
	testhelpers.TestHTTPEndpoint(t, ctx, image, testhelpers.HTTPTestConfig{Port: "8181"}, nil)
}