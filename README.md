# ArchiLab Backup

This repository contains scripts to backup ArchiLab related data.

## Backup and Restore Postgres Database

All scripts make use of the \${HOME} environment variable. To make them work
this git repo has to be cloned to the home directory of the user running the
backups.

`backup-docker-db` connects to another host via SSH, creates a SQL dump file
from a Postgres database running inside a Docker swarm service and copies it to
our NAS via scp:

```bash
${HOME}/archilab-backup/backup-docker-db <HOST_NAME> <STACK_NAME> <SERVICE_NAME> <DB_USER> <DB_NAME>
```

Example:

```bash
${HOME}/archilab-backup/backup-docker-db prox-prod prox-project-service project-db project-service project-db
```

`restore-docker-db` copies a SQL dump file of a specific date from our NAS to
another host via scp, connects to the host via SSH and restores a Postgres
database running inside a Docker swarm service from the dump file:

```bash
${HOME}/archilab-backup/restore-docker-db <HOST_NAME> <STACK_NAME> <SERVICE_NAME> <DB_USER> <DB_NAME> <DATE>
```

Example:

```bash
${HOME}/archilab-backup/restore-docker-db prox-prod prox-project-service project-db project-service project-db 2019-09-25
```

## Automatic Backups

`crontab` contains scheduled backup tasks to automatically execute the backup
script for specific services. The keyword `@daily` executes the script daily at
00:00. The `crontab` file can be loaded by executing:

```bash
crontab ${HOME}/archilab-backup/crontab
```

## Backup User

The user `nas` on the `archilab-infra` host has a SSH configuration file that
allows him to connect to our NAS and to the hosts configured in the crontab by
their hostname. The crontab of that user is also already configured.
