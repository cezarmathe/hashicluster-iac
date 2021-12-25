#!/usr/bin/env bash

# hashicluster-iac - scripts/nomad_setup.sh
#
# This script installs Nomad.

set -exo pipefail

# if the variable is undefined, define it as empty
if [[ -z "${NOMAD_ENABLE}" ]]; then
    NOMAD_ENABLE="1"
fi

set -u

# Directory where the script checks for config files.
NOMAD_SETUP_TMP_DIR="/tmp/nomad-setup"

# install nomad
sudo apt install --yes nomad

# if the setup tmp dir exists
if [[ -d "${NOMAD_SETUP_TMP_DIR}" ]]; then
    # override the default configuration file
    echo "# Nomad default config." | sudo tee /etc/nomad.d/nomad.hcl
    # and then install our own config files
    for config_file in $(ls ${NOMAD_SETUP_TMP_DIR}/*.hcl); do
        sudo mv "${config_file}" /etc/nomad.d/
    done
fi

# enable the nomad service if required
if [[ ! -z "${NOMAD_ENABLE}" ]]; then
    sudo systemctl enable nomad
fi
