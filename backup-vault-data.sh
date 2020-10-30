#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

current_date="$(date +%Y-%m-%d)"
backup_dir="\${HOME}/vault"
backup_file="${backup_dir}/vault_${current_date}.tar.gz"
vault_host="archilab-vault"
nas_host="archilab-nas"

ssh "${vault_host}" <<EOF
    mkdir -p "${backup_dir}"
    sudo systemctl stop vault vault-unseal
    sudo tar --create --preserve-permissions --file="${backup_file}" --gzip \
        --verbose /var/lib/vault
    sudo systemctl start vault vault-unseal
EOF

ssh "${nas_host}" "mkdir --parents ${backup_dir}"

scp -3 "${vault_host}:${backup_file}" "${nas_host}:${backup_file}"

ssh "${vault_host}" "rm --recursive --force ${backup_dir}"
