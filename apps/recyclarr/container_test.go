package main

import (
	"bytes"
	"context"
	"testing"
	"time"

	"github.com/chillincool/containers/testhelpers"
	"github.com/testcontainers/testcontainers-go"
	"github.com/testcontainers/testcontainers-go/wait"
)

func Test(t *testing.T) {
	image := testhelpers.GetTestImage("ghcr.io/chillincool/containers/recyclarr:local")

	ctx := context.Background()

	// Recyclarr is a CLI tool - test that it can show help without crashing
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

	t.Log("Recyclarr --help executed successfully")
}
