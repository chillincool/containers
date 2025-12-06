package main

import (
	"context"
	"testing"

	"github.com/chillincool/containers/testhelpers"
)

func Test(t *testing.T) {
	image := testhelpers.GetTestImage("ghcr.io/chillincool/containers/suggestarr:local")
	testhelpers.TestHTTPEndpoint(t, context.Background(), image, testhelpers.HTTPTestConfig{Port: "5000"}, nil)
}
