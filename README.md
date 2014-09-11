## Vagrant config for Kubernetes on CoreOS

Vagrant configuration for setting up a Kubernetes setup on a cluster of CoreOS VMs provisioned with a discovery server, a master and 2 minions by default. Also uses Rudder.

###### Usage

1. Compile kubernetes and rudder.
2. Add the compiled binaries to `./bin`.

```bash
$ vagrant up

$ vagrant ssh-config master > ssh.config
$ ssh -f -nNT -L 8080:127.0.0.1:8080 -F ssh.config master

$ ./bin/kubecfg list minions
```
