#!/bin/bash

K_NS="mariadb-galera-ns"
M_NAME="mariadb-galera-helm"
BACKUP="galera-backup"

echo "🗒️  Restoring backup with velero"
velero restore create --from-backup "$BACKUP"

echo "🗒️  Backup restored, now check the README on how to continue."
