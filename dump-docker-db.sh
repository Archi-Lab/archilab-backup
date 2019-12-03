#!/usr/bin/env bash

host_name="$1"
stack_name="$2"
service_name="$3"
db_user="$4"
db_name="$5"
instance_number=1
stack_service="${stack_name}_${service_name}"
stack_service_instance="${stack_service}.${instance_number}"
task_id="$(docker service ps ${stack_service} -q --no-trunc | head -n1)"
current_date="$(date +%Y-%m-%d)"
backup_dir="${HOME}/${host_name}/${stack_name}/${service_name}"

mkdir -p "${backup_dir}"

{
  docker exec "${stack_service_instance}.${task_id}" pg_dump -U "${db_user}" -c "${db_name}"
} > "${backup_dir}/${stack_service}_${current_date}.sql"