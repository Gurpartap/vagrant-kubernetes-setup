## Vagrant config for Kubernetes on CoreOS

Vagrant configuration for setting up a Kubernetes setup on a cluster of CoreOS VMs provisioned with a discovery server, a master and 2 minions by default. Also uses Rudder.

###### Usage

1. Compile kubernetes and rudder.
2. Add the compiled binaries to `./bin`.
3. `$ ./up.sh`
