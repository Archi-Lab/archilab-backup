#!/usr/bin/env bash

host_name="$1"
stack_name="$2"
service_name="$3"
db_user="$4"
db_name="$5"
backup_dir="\${HOME}/${host_name}/${stack_name}/${service_name}"

ssh "${host_name}" "mkdir -p \${HOME}/bin"

scp "${HOME}/archilab-backup/dump-docker-db.sh" "${host_name}:\${HOME}/bin/"

ssh "${host_name}" "\${HOME}/bin/dump-docker-db.sh" "${host_name}" "${stack_name}" "${service_name}" "${db_user}" "${db_name}"

ssh "archilab-nas" "mkdir -p ${backup_dir}"

scp -3 -r "${host_name}:${backup_dir}/*" "archilab-nas:${backup_dir}/"

ssh "${host_name}" "rm ${backup_dir}/*"
