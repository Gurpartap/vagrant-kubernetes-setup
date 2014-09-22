## Vagrant config for Kubernetes on CoreOS

Vagrant configuration for setting up a Kubernetes setup on a cluster of CoreOS VMs provisioned with a discovery server, a master and 2 minions by default. Also uses [Flannel](https://github.com/coreos/flannel) (formerly Rudder).

###### Usage

1. Build[1] [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes) and [Flannel](https://github.com/coreos/flannel).
2. Add the compiled binaries to this repo's `bin` directory.
3. Run `bash up.sh` to provision vagrant and setup ssh tunnel for `kubecfg`.
4. Use `kubecfg` to interact with Kubernetes API Server which is running on cluster's master.

[1] Hint: Use `make` to build Kubernetes (look for binaries in `_output` directory).Use `./build` for Flannel and find the `flanneld` binary in your `$GOBIN` path.
