#!/usr/bin/env bash

backup_date="$1"
backup_dir="\${HOME}/vault"
backup_file="${backup_dir}/vault_${backup_date}.tar.gz"
vault_host="archilab-vault"
nas_host="archilab-nas"

ssh "${vault_host}" "mkdir -p ${backup_dir}"

scp -3 "${nas_host}:${backup_file}" "${vault_host}:${backup_file}"

ssh "${vault_host}" << EOF
    sudo systemctl stop vault vault-unseal
    sudo rm -rf /var/lib/vault
    cd /
    sudo tar --extract --preserve-permissions --file="${backup_file}" --verbose
    sudo systemctl start vault vault-unseal
    rm -rf ${backup_dir}
EOF
