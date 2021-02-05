#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

current_date="$(date +%Y_%m_%d_%H_%M_%S)"

# Source Docker
source_data_docker="/var/opt/gitlab/backups/dump_gitlab_backup.tar"
source_configuration_docker="/etc/gitlab"

# Source
source_root_dir="/media/data/backups/tmp"
source_dir="${source_root_dir}/${current_date}"

# Target
target_dir="/volume1/homes/backup/archilab-gitlab"

# Hosts
gitlab_host="archilab-gitlab"
nas_host="archilab-nas"

# Delete old source
echo "Delete old source dir: ${source_root_dir}"
ssh "${gitlab_host}" "rm -rf ${source_root_dir}"

# Create source
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
scp -3 -r "${gitlab_host}:${source_dir}" "${nas_host}:${target_dir}"

echo "Saved backup to (NAS): ${target_dir}"

# Delete old backups
ssh "${nas_host}" << EOF
   current_year=\$(date +%Y | sed 's/^0*//')
   current_month=\$(date +%m | sed 's/^0*//')
   current_day=\$(date +%d | sed 's/^0*//')

   for file_path in "${target_dir}"/*;
   do
      file_name=\$(basename \$file_path)
      file_year=\$(echo "\$file_name" | cut -d'_' -f1 | sed 's/^0*//')
      file_month=\$(echo "\$file_name" | cut -d'_' -f2 | sed 's/^0*//')
      file_day=\$(echo "\$file_name" | cut -d'_' -f3 | sed 's/^0*//')

      year_diff=\$((current_year - file_year))
      month_diff=\$((current_month - file_month))
      day_diff=\$((current_day - file_day))

      diff=\$((372 * year_diff + 31 * month_diff + day_diff))
      if (( "\$diff" >= 7 ))
      then
         rm -r "\$file_path"
         echo "Deleted backup \$file_name"
      fi
   done
EOF
