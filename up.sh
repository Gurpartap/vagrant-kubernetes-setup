#!/bin/bash
# Usage ./up.sh

set -o errexit
set -o nounset
set -o pipefail

green='\033[00;32m'
red='\033[00;31m'

function color_echo {
  echo -e -n "${2}${1}"
  echo -e '\033[0m'
}

base_dir=$(dirname "$0")
base_dir=$(cd "${base_dir}" && pwd)

required_files="apiserver controller-manager flanneld kubelet kubecfg proxy scheduler"

echo " ---> Step 1: Check prerequisites."

for file in ${required_files}
do
  if [ -f "${base_dir}/bin/${file}" ]; then
    color_echo "[OK]\tFound ${file}." $green
  else
    color_echo "[ERR]\tCouldn't find ${file}. Please read the usage instructions available in the README.md file." $red
    exit 1
  fi
done

echo " ---> Step 2: Destroy existing cluster."
vagrant destroy -f

echo " ---> Step 3: Provision vagrant."
vagrant up

echo " ---> Step 4: Setup ssh tunnel into master."
vagrant ssh-config master > ssh.config
ssh -f -nNT -L 8080:127.0.0.1:8080 -F ssh.config master

echo " ---> Done."
echo ""
echo "      Use kubecfg on your host machine to interact with Kubernetes API Server running on master."
echo ""
echo "      Try: \`kubecfg list minions\`"
echo ""
