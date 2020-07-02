#!/usr/bin/env bash

current_date="$(date +%Y-%m-%d)"

# Docker
gitlab_container_name="gitlab_gitlab.1.n5qmwhqevd6yfm8lmeonht2n8"

# Source
source_data="\${HOME}/var/opt/gitlab/backups/dump_gitlab_backup.tar" # TODO Copy file out of docker container
source_configuration="\${HOME}/etc/gitlab" 

# Target
target_backup_dir="\${HOME}/archilab-gitlab"  
target_data_backup_dir="${target_backup_dir}/data/${current_date}" 
target_configuration_backup_dir="${target_backup_dir}/configuration/${current_date}" 

# Hosts
gitlab_host="archilab-gitlab"
nas_host="archilab-nas"

# Create backup.tar
ssh "${gitlab_host}" <<EOF
    sudo docker exec -t "${gitlab_container_name}" gitlab-backup create STRATEGY=copy BACKUP=dump
EOF

# Create target dirs
ssh "${nas_host}" "mkdir --parents ${target_data_backup_dir}"
ssh "${nas_host}" "mkdir --parents ${target_configuration_backup_dir}"

# Copy Backup files
scp -3 "${gitlab_host}:${source_data}" "${nas_host}:${target_data_backup_dir}"
scp -3 "${gitlab_host}:${source_configuration}" "${nas_host}:${target_configuration_backup_dir}"

# Delete backup.tar
ssh "${gitlab_host}" "rm --force ${source_data}"
