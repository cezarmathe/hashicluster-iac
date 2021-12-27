#!/usr/bin/env bash

# hashicluster-iac - scripts/tools_setup.sh
#
# This script installs commonly-used tools.

set -euxo pipefail

sudo apt-get update
sudo apt-get install --yes ranger jq
