## Vagrant config for Kubernetes on CoreOS

Vagrant configuration for setting up a [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes) setup on a cluster of CoreOS VMs provisioned with a discovery server, a master and 2 minions by default. Also uses [Flannel](https://github.com/coreos/flannel) (formerly Rudder).

#### Usage

[![Click to view full version on asciinema.org](https://raw.githubusercontent.com/Gurpartap/vagrant-kubernetes-setup/master/demo.gif)](https://asciinema.org/a/12399)

1. Build Kubernetes and Flannel. See instructions below.
2. Add the compiled binaries to this repo's `bin` directory.
3. Run `bash up.sh` to provision vagrant and setup ssh tunnel for `kubecfg`.
4. Use `kubecfg` to interact with Kubernetes API Server which is running on cluster's master. If you don't want to setup `kubecfg` on your machine, proceed with `vagrant ssh master`.

#### Building Kubernetes and Flannel

```
docker pull google/golang
docker -ti --rm -v /tmp/mybins/:/tmp/mybins/ google/golang /bin/bash
```

###### Inside the container
```
# Build Kubernetes
go get github.com/GoogleCloudPlatform/kubernetes
cd $GOPATH/src/github.com/GoogleCloudPlatform/kubernetes
make
cp _output/go/bin/* /tmp/mybins/

# Build Flannel
go get github.com/coreos/flannel
$GOPATH/src/github.com/coreos/flannel/build
cp $GOPATH/bin/flanneld /tmp/mybins/

exit
```

###### If you use boot2docker
```
# for each of the binary; or tar them before hand.
scp docker@192.168.59.103:/tmp/mybins/<filename> /path/to/vagrant-kubernetes-setup/bin/
Password: tcuser
```

###### And if you don't
```
cp /tmp/mybins/* /path/to/vagrant-kubernetes-setup/bin/
```

###### Other notes

You *may* need to build and install `kubecfg` on your platform if you want to use it natively.

I have a OS X kubecfg symlinked as such:

```
ln -s /path/to/kubecfg-darwin /usr/local/bin/kubecfg
```
