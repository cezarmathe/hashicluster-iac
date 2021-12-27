#!/usr/bin/env bash

# hashicluster-iac - scripts/hashicorp_setup.sh
#
# This script installs the HashiCorp repository.

set -euxo pipefail

# select architecture for this machine
ARCH=""
if [[ "$(uname -m)" == "x86_64" ]]; then
    ARCH="amd64"
elif [[ "$(uname -m)" == "amd64" ]]; then
    ARCH="amd64"
elif [[ "$(uname -m)" == "aarch64" ]]; then
    ARCH="arm64"
elif [[ "$(uname -m)" == "arm64" ]]; then
    ARCH="arm64"
else
    printf "%s\n" "Unsupported architecture: $(uname -m)"
    exit 1
fi

# set up hashicorp repository

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

sudo apt-add-repository "deb [arch=${ARCH}] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update
