#!/bin/bash

K_NS="mariadb-galera-ns"
M_NAME="mariadb-galera-helm"

echo "🗒️  Scaling deployment back up to 3 pods."
kubectl scale statefulset --replicas=3 "$M_NAME" -n "$K_NS"

echo "🗒️  Now check the README on how to continue."
