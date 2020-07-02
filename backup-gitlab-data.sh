#!/usr/bin/env bash

current_date="$(date +%Y_%m_%d_%H_%M_%S)"

# Source Docker
source_data_docker="/var/opt/gitlab/backups/dump_gitlab_backup.tar"
source_configuration_docker="/etc/gitlab" 

# Source
source_dir="/media/data/backups/${current_date}"

# Target
target_dir="/homes/backup/archilab-gitlab"  

# Hosts
gitlab_host="gitlab" #"archilab-gitlab"
nas_host="archilab-nas"

# Create source dir
echo "Create source dir: ${source_dir}"
ssh "${gitlab_host}" "mkdir --parents ${source_dir}"

# Docker
gitlab_container_hash=$(ssh "${gitlab_host}" "docker service ps -f "name=gitlab_gitlab.1" gitlab_gitlab -q --no-trunc | head -n1")
gitlab_container_name="gitlab_gitlab.1.${gitlab_container_hash}"
echo "Docker Gitlab container name: ${gitlab_container_name}"

echo "Start creating backup"
# Create backup.tar and copy configuration files
ssh "${gitlab_host}" <<EOF
    docker exec "${gitlab_container_name}" gitlab-backup create STRATEGY=copy BACKUP=dump
    docker cp "${gitlab_container_name}":"${source_configuration_docker}" "${source_dir}"
    docker cp "${gitlab_container_name}":"${source_data_docker}" "${source_dir}"
EOF

echo "Saved backup to (Gitlab host): ${source_dir}"

# Copy Backup files
#scp -3 "${gitlab_host}:${source_dir}" "${nas_host}:${target_dir}"

echo "Saved backup to (NAS): ${target_dir}"

# Delete source dir
ssh "${gitlab_host}" "rm -r ${source_dir}"

echo "Deleted (Gitlab host): ${source_dir}"
