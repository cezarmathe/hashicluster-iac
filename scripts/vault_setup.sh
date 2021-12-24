#!/usr/bin/env bash

# hashicluster-iac - scripts/vault_setup.sh
#
# This script installs Vault.

set -exo pipefail

# if the variable is undefined, define it as empty
if [[ -z "${VAULT_ENABLE}" ]]; then
    VAULT_ENABLE=""
fi

set -u

# Directory where the script checks for config files.
VAULT_SETUP_TMP_DIR="/tmp/vault-setup"

# install vault
sudo apt install --yes vault

# if the setup tmp dir exists
if [[ -d "/tmp/vault-setup" ]]; then
    # override the default configuration file
    echo "# Vault default config." | sudo tee /etc/vault.d/vault.hcl
    # and then install our own config files
    for config_file in $(ls /tmp/vault-setup/*.hcl); do
        sudo mv "${config_file}" /etc/vault.d/
        sudo chown vault:vault "${config_file}"
    done
fi

# fix the vault service file so that it loads all config files from /etc/vault.d
# instead of loading just /etc/vault.d/vault.hcl
sudo cp /usr/lib/systemd/system/vault.service /etc/systemd/system/vault.service
sudo sed -i 's/\/etc\/vault.d\/vault.hcl/\/etc\/vault.d\//g' /etc/systemd/system/vault.service

# enable the vault service if required
if [[ ! -z "${VAULT_ENABLE}" ]]; then
    sudo systemctl enable vault
fi
