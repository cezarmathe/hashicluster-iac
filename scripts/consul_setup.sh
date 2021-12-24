#!/usr/bin/env bash

# hashicluster-iac - scripts/consul_setup.sh
#
# This script installs Consul.

set -exo pipefail

# if the variable is undefined, define it as empty
if [[ -z "${CONSUL_ENABLE}" ]]; then
    CONSUL_ENABLE=""
fi

set -u

# Directory where the script checks for config files.
CONSUL_SETUP_TMP_DIR="/tmp/consul-setup"

# install consul
sudo apt install --yes consul

# if the setup tmp dir exists
if [[ -d "/tmp/consul-setup" ]]; then
    # override the default configuration file
    echo "# Consul default config." | sudo tee /etc/consul.d/consul.hcl
    # and then install our own config files
    for config_file in $(ls /tmp/consul-setup/*.hcl); do
        sudo mv "${config_file}" /etc/consul.d/
        sudo chown consul:consul "${config_file}"
    done
fi

# enable the consul service if required
if [[ ! -z "${CONSUL_ENABLE}" ]]; then
    sudo systemctl enable consul
fi
