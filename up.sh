#!/bin/bash

echo " ---> Step 0: Flush everything"
vagrant destroy -f

echo " ---> Step 1: Provision vagrant"
vagrant up

echo " ---> Step 2: Setup ssh tunnel into master"
vagrant ssh-config master > ssh.config
ssh -f -nNT -L 8080:127.0.0.1:8080 -F ssh.config master                         ✹

echo " --> Step 3: Confirm kubecfg tunnel"
kubecfg list minions
