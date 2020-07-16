# Actions

The `providers.sh` script provides the following actions:

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
  See the [output variables](variables.md)
