# Kubernetes Cluster Providers

This repository contains the providers used for
creating/destroying/_something-else_ Kubernetes clusters in a
versatile way.

# Table of contents

- Using the Kubernetes cluster providers in:
  - [shell scripts](docs/usage-shell.md)
  - [GitHub actions](docs/usage-github.md)
- Usage:
  - [List of commands](docs/entrypoints.md): `create`, `delete`...
  - [Input and output](docs/variables.md) variables: configuring the cluster and getting info from it.
- List of [current providers](docs/providers.md):
  - [k3d](docs/providers.md#k3d)
  - [KIND](docs/providers.md#kind)
  - [GKE](docs/providers.md#GKE)
  - [Azure](docs/providers.md#Azure)
