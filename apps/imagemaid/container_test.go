package main

import (
	"bytes"
	"context"
	"testing"
	"time"

	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
	"github.com/chillincool/containers/testhelpers"
)

func Test(t *testing.T) {
	image := testhelpers.GetTestImage("ghcr.io/chillincool/containers/imagemaid:local")
	
	ctx := context.Background()
	
	// ImageMaid is a script that runs and exits, not a service
	// Test that it starts without crashing
	req := testcontainers.ContainerRequest{
		Image: image,
		Cmd:   []string{"--help"},
		WaitingFor: wait.ForExit().WithExitTimeout(30 * time.Second),
	}
	
	container, err := testcontainers.GenericContainer(ctx, testcontainers.GenericContainerRequest{
		ContainerRequest: req,
		Started:          true,
	})
	if err != nil {
		t.Fatalf("Failed to start container: %v", err)
	}
	defer container.Terminate(ctx)
	
	// Check exit code
	exitCode, err := container.State(ctx)
	if err != nil {
		t.Fatalf("Failed to get container state: %v", err)
	}
	
	if exitCode.ExitCode != 0 {
		logs, _ := container.Logs(ctx)
		buf := new(bytes.Buffer)
		buf.ReadFrom(logs)
		t.Fatalf("Container exited with code %d. Logs:\n%s", exitCode.ExitCode, buf.String())
	}
	
	t.Log("ImageMaid --help executed successfully")
}
