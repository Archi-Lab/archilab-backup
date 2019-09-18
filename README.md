# ArchiLab Backup

This repository contains scripts to backup ArchiLab related data.

## Backup and restore Postgres database

`dump-docker-db` creates a SQL dump file from a Postgres database running inside a Docker swarm service:

```bash
./dump-docker-db <STACK_NAME> <SERVICE_NAME> <DB_USER> <DB_NAME>
```

Example:

```bash
./dump-docker-db prox-project-service project-db project-service project-db
```

`restore-docker-db` restores a Postgres database running inside a Docker swarm service from a SQL dump file:

```bash
./restore-docker-db <STACK_NAME> <SERVICE_NAME> <DB_USER> <DB_NAME>
```

Example:

```bash
./restore-docker-db prox-project-service project-db project-service project-db
```
