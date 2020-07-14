# Description

This directory contains the cluster providers used for creating/destroying/something-else
clusters for running tests.

The `providers.sh` script provides the following entry points:

  * **setup**: install any software necessary, usually called in the setup stage of your
  Travis/CircleCI/etc. script. For example, for GKE it should install the _Google Cloud SDK_,
  as well as some other tools like `kubectl`.
  * **cleanup**: perform any cleanups when we are done with this cluster provider, like
  removing any tools that were downloaded. The cleanup should make sure that no clusters
  are kept alive in the provider.
  * **exists**: return 0 if the cluster already exists.
  * **login**/**logout**: login/logout from the cloud provider. Usually not directly used
  by users but from other entrypoints.
  * **create**: create a cluster that will become the _current cluster_. The _kubeconfig_
  will be returned in `get-env` as `KUBECONFIG`.
  * **delete**: delete the current cluster, previously created with `create`.
  * **create-registry**: create a registry or login into an existing one. The registry
  will be returned in `get-env` as `DEV_REGISTRY`.
  * **delete-registry**: release the current registry or cleanup any resources.
  * **get-env**: get any environment variables necessary for using the current cluster.
  See the [output variables](#Output-variables)

# Using the cluster providers

## How to use the cluster providers

* _running the script_ from command line: just invoke the main script with the right
  entrypoint, like `providers.sh setup`. Get the environment for the current
  cluster with `eval "$(providers.sh get-env)"`.

* _including the script_: with `source providers.sh` and then
  running the `cluster_provider` function with the desired _entrypoint_,
  like `cluster_provider 'create'`. After creating the cluster you can get the
  environment with `eval "$(cluster_provider 'get-env')"`

Note that some cluster providers will require some [authentication](#Authentication)
as well as some [customization with environment variables](#Configuring-the-cluster-with-env-variables).

## Example

For example, we can create local k3d cluster with:

```commandline
$ CLUSTER_PROVIDER=k3d ./providers.sh create
>>> (cluster provider: k3d: create)
>>> Creating k3d cluster operator-tests-alvaro-0...
INFO[0000] Created cluster network with ID 8f45e65287b15083cbfb5c208862d791f0b25a82416de9df8417a2ff5b32d187
INFO[0000] Created docker volume  k3d-operator-tests-alvaro-0-images
INFO[0000] Creating cluster [operator-tests-alvaro-0]
INFO[0000] Registry already present: ensuring that it's running and connecting it to the 'k3d-operator-tests-alvaro-0' network...
INFO[0000] Creating server using docker.io/rancher/k3s:v1.17.4-k3s1...
INFO[0006] SUCCESS: created cluster [operator-tests-alvaro-0]
INFO[0006] A local registry has been started as registry.localhost:5000
INFO[0006] You can now use the cluster with:

export KUBECONFIG="$(k3d get-kubeconfig --name='operator-tests-alvaro-0')"
kubectl cluster-info
>>> Replacing 127.0.0.1 by 172.29.0.3
>>> Showing some k3d cluster info:
Kubernetes master is running at https://172.29.0.3:6444
CoreDNS is running at https://172.29.0.3:6444/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
Metrics-server is running at https://172.29.0.3:6444/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

and then we can get the configuration for this cluster with:

```commandline
$ CLUSTER_PROVIDER=k3d ./providers.sh get-env
>>> (cluster provider: k3d: get-env)
DEV_REGISTRY=registry.localhost:5000
DOCKER_NETWORK=k3d-operator-tests-alvaro-0
DEV_KUBECONFIG=/home/alvaro/.config/k3d/operator-tests-alvaro-0/kubeconfig.yaml
KUBECONFIG=/home/alvaro/.config/k3d/operator-tests-alvaro-0/kubeconfig.yaml
CLUSTER_NAME=operator-tests-alvaro-0
CLUSTER_SIZE=1
CLUSTER_MACHINE=
CLUSTER_REGION=
K3D_CLUSTER_NAME=operator-tests-alvaro-0
K3D_NETWORK_NAME=k3d-operator-tests-alvaro-0
K3D_API_PORT=6444
```

Once we are done, we can destroy the cluster with:

```commandline
$ CLUSTER_PROVIDER=k3d ./providers.sh delete
>>> (cluster provider: k3d: delete)
>>> Stopping container CID:b521db1b8bc4
b521db1b8bc4
>>> Destroying k3d cluster operator-tests-alvaro-0...
INFO[0000] Removing cluster [operator-tests-alvaro-0]
INFO[0000] ...Removing server
INFO[0000] ...Disconnecting Registry from the k3d-operator-tests-alvaro-0 network
INFO[0000] ...Removing docker image volume
INFO[0000] Removed cluster [operator-tests-alvaro-0]
```

## Authentication

See the [credentials](CREDENTIALS.md) document for more details.

## Environment variables

### Input variables: configuring the cluster we want.

* `CLUSTER_PROVIDER`: the name of one of the cluster providers currently supported.
* `CLUSTER_NAME`: specifies the name of the cluster. It should be unique, but it should
  be "constant" so that a new execution of the provider could detect if the cluster
  already exists.
* `CLUSTER_SIZE`: total number of nodes in the cluster (including master and worker nodes).
  Some cluster will always create the same number of masters (ie, K3D or LXC always create 1).
* `CLUSTER_MACHINE`: node size or _model_, depending on the cluster provider
  (ie, on Azure it can be something like `Standard_D2s_v3`).
* `CLUSTER_REGION`: cluster location (ie, `us-east1-b` on GKE).
* `CLUSTER_REGISTRY`: (supported by some providers) custom name for the registry in the cluster.

### Output variables: getting info for using the cluster.

* `DEV_REGISTRY`: the registry created (ie, `registry.localhost:5000`).
* `KUBECONFIG`: the kubeconfig generated for connecting to the API server in this cluster.
* `DEV_KUBECONFIG`: same as `KUBECONFIG`.
* `CLUSTER_NAME`: a unique cluster name. Will be the `CLUSTER_NAME` provided when it was not empty.
* `CLUSTER_SIZE`: (see the input environment variables)
* `CLUSTER_MACHINE`: (see the input environment variables)
* `CLUSTER_REGION`: (see the input environment variables)

In some environments you can get:

* `DOCKER_NETWORK`:the docker network used for connecting all the machines in the cluster.
* `SSH_IP_MASTER<NUM>`: the IP address for ssh'ing to the master number `<NUM>`
* `SSH_IP_WORKER<NUM>`: the IP address for ssh'ing to the worker number `<NUM>`
* `SSH_IPS`: all the IP addresses for ssh'ing to the nodes.
* `SSH_USERNAME`: the ssh username required for connecting to the nodes of the cluster
  (will never be provided for machines created in the cloud, only for local environments).
* `SSH_PASSWORD`: the ssh password required for connecting to the nodes of the cluster
  (will never be provided for machines created in the cloud, only for local environments).

Example for LXC:

```commandline
$ CLUSTER_PROVIDER=lxc ./providers.sh get-env
>>> (cluster provider: lxc: get-env)
CLUSTER_NAME=
CLUSTER_SIZE=2
CLUSTER_MACHINE=
CLUSTER_REGION=
SSH_IP_MASTER0=10.0.1.169
SSH_IP_WORKER0=10.0.1.57
SSH_IPS='10.0.1.169 10.0.1.57'
```

## Using it in GitHub actions

### Pre-requisites

Create a workflow YAML file in your `.github/workflows` directory. An
[example workflow](#example-workflow) is available below.
For more information, reference the GitHub Help Documentation for
[Creating a workflow file](https://help.github.com/en/articles/configuring-a-workflow#creating-a-workflow-file).

### Inputs

For more information on inputs, see the [API Documentation](https://developer.github.com/v3/repos/releases/#input)

- `provider`: The cluster-provider (ie, k3d, kind, gke...)
- `command`: The command to run (ie, create, destroy, login...)
- `name`: (optional) The name of the cluster. It should be unique.
- `size`: (optional) The total number of nodes in the cluster (including
  master and worker nodes)
- `machine`: (optional)The node size or 'model', depending on the cluster provider (ie, on Azure it can be something like 'Standard_D2s_v3')
- `region`: (optional) cluster location (ie, 'us-east1-b' on GKE)
- `registry`: (optional) a custom name for the registry in the cluster (supported only in some providers)

Any other advanced environment variable can be passed through the `env` in the action.

All the subsequent steps in the workflow will automatically have available the environment
variables that would be exported with `get-env`.

### Example Workflow

Create a workflow (eg: `.github/workflows/create-cluster.yml`):

```yaml
name: Create Cluster
on: pull_request
jobs:
  create-cluster:
    runs-on: ubuntu-latest
    steps:
      - name: Create a k3d Cluster
        uses: datawire/cluster-providers@master
        with:
            provider: k3d
            command: create
        env:
            K3D_EXTRA_ARGS: --server-arg '--no-deploy=traefik'

      - name: Test the cluster created
        run: |
          kubectl cluster-info
```

This uses [@datawire/cluster-provider@master](https://www.github.com/datawire/cluster-provider)
GitHub Action to spin up a [k3d](https://github.com/t\rancher/k3d/) Kubernetes cluster on
every Pull Request.
