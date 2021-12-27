#!/usr/bin/env bash

# hashicluster-iac - scripts/consul_setup.sh
#
# This script installs Consul.

set -exo pipefail

# if the variable is undefined, define it as empty
if [[ -z "${CONSUL_ENABLE}" ]]; then
    CONSUL_ENABLE="1"
fi

set -u

# Directory where the script checks for config files.
CONSUL_SETUP_TMP_DIR="/tmp/consul-setup"

# install consul
sudo apt-get install --yes consul

# if the setup tmp dir exists
if [[ -d "${CONSUL_SETUP_TMP_DIR}" ]]; then
    # override the default configuration file
    echo "# Consul default config." | sudo tee /etc/consul.d/consul.hcl
    # then install our own config files
    for config_file in $(ls ${CONSUL_SETUP_TMP_DIR}/*.hcl); do
        sudo mv "${config_file}" /etc/consul.d/
    done
    # and update ownership
    sudo chown -R consul:consul /etc/consul.d/
fi

# enable the consul service if required
if [[ ! -z "${CONSUL_ENABLE}" ]]; then
    sudo systemctl enable consul
fi
