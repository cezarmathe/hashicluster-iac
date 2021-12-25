#!/usr/bin/env bash

# hashicluster-iac - scripts/vault_setup.sh
#
# This script installs Vault.

set -exo pipefail

# if the variable is undefined, define it as empty
if [[ -z "${VAULT_ENABLE}" ]]; then
    VAULT_ENABLE="1"
fi

set -u

# Directory where the script checks for config files.
VAULT_SETUP_TMP_DIR="/tmp/vault-setup"

# install vault
sudo apt install --yes vault

# if the setup tmp dir exists
if [[ -d "${VAULT_SETUP_TMP_DIR}" ]]; then
    # override the default configuration file
    echo "# Vault default config." | sudo tee /etc/vault.d/vault.hcl
    # then install our own config files
    for config_file in $(ls ${VAULT_SETUP_TMP_DIR}/*.hcl); do
        sudo mv "${config_file}" /etc/vault.d/
    done
    # and update ownership
    sudo chown -R vault:vault /etc/vault.d/
fi

# fix the vault service file so that it loads all config files from /etc/vault.d
# instead of loading just /etc/vault.d/vault.hcl
sudo cp /usr/lib/systemd/system/vault.service /etc/systemd/system/vault.service
sudo sed -i 's/-config=\/etc\/vault.d\/vault.hcl/-config=\/etc\/vault.d\//g' /etc/systemd/system/vault.service
sudo systemctl daemon-reload

# enable the vault service if required
if [[ ! -z "${VAULT_ENABLE}" ]]; then
    sudo systemctl enable vault
fi
