#!/bin/bash
# Usage ./up.sh

set -o errexit
set -o nounset
set -o pipefail

green='\033[00;32m'
red='\033[00;31m'
blue='\033[00;34m'

function cecho {
  color="${2:-$blue}"
  echo -e -n "${color}${1}"
  echo -e '\033[0m'
}

base_dir=$(dirname "$0")
base_dir=$(cd "${base_dir}" && pwd)

required_files="apiserver controller-manager flanneld kubelet kubecfg proxy scheduler"

cecho " ---> Step 1: Check prerequisites."

for file in ${required_files}
do
  if [ -f "${base_dir}/bin/${file}" ]; then
    cecho "[OK] Found ${file}." $green
  else
    cecho "[ERR] Couldn't find ${file}. Please read the usage instructions available in the README.md file." $red
    exit 1
  fi

  if ! [[ -x "${base_dir}/bin/${file}" ]]; then
    cecho "[ERR] File ${file} is not executable. Try \`chmod +x ./bin/${file}\`." $red
    exit 1
  fi
done

cecho " ---> Step 2: Destroy existing cluster."
vagrant destroy -f

cecho " ---> Step 3: Provision vagrant."
vagrant up

cecho " ---> Step 4: Setup ssh tunnel into master."
vagrant ssh-config master > ssh.config
ssh -f -nNT -L 8080:127.0.0.1:8080 -F ssh.config master

cecho " ---> Done."
echo ""
echo "      Use kubecfg on your host machine to interact with Kubernetes API Server running on master."
echo "      If you don't want to setup kubecfg on your host machine, proceed with \`vagrant ssh master\`."
echo ""
echo "      Try: \`kubecfg list minions\`"
echo ""
