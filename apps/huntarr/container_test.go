package main

import (
	"context"
	"testing"

	"github.com/chillincool/containers/testhelpers"
)

func Test(t *testing.T) {
	ctx := context.Background()
	image := testhelpers.GetTestImage("ghcr.io/chillincool/containers/huntarr:local")
	testhelpers.TestHTTPEndpoint(t, ctx, image, testhelpers.HTTPTestConfig{Port: "9705"}, nil)
}
