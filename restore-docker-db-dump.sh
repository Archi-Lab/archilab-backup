#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

host_name="$1"
stack_name="$2"
service_name="$3"
db_user="$4"
db_name="$5"
backup_date="$6"
instance_number=1
stack_service="${stack_name}_${service_name}"
stack_service_instance="${stack_service}.${instance_number}"
task_id="$(docker service ps ${stack_service} -q --no-trunc | head -n1)"
backup_dir="${HOME}/${host_name}/${stack_name}/${service_name}"

{
  docker exec -i "${stack_service_instance}.${task_id}" \
    psql --username "${db_user}" "${db_name}"
} <"${backup_dir}/${stack_service}_${backup_date}.sql"
