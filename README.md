## Vagrant config for Kubernetes on CoreOS

Vagrant configuration for setting up a Kubernetes setup on a cluster of CoreOS VMs provisioned with a discovery server, a master and 2 minions by default. Also uses Rudder.

###### Usage

    vagrant up

    # OS X
    wget https://storage.googleapis.com/kubernetes/darwin/kubecfg

    # Linux
    wget https://storage.googleapis.com/kubernetes/kubecfg

    vagrant ssh-config master > ssh.config
    ssh -f -nNT -L 8080:127.0.0.1:8080 -F ssh.config master

    ./kubecfg list minions
