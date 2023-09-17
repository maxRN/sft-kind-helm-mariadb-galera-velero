#!/bin/bash

set -e

K_NS="mariadb-galera-ns"
M_NAME="mariadb-galera-helm"
BACKUP="galera-backup"

echo "🗒️  Create port forward"
kubectl port-forward --namespace "$K_NS" svc/"$M_NAME" 3306:3306 &

echo "🗒️  Install Minio"
kubectl apply -f "../configFiles/00-minio-deployment.yaml"

echo "🗒️  Install Velero"
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.2.1 \
    --bucket velero \
    --secret-file "../configFiles/credentials-velero" \
    --use-volume-snapshots=false \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.velero.svc:9000

echo "🗒️  Writing dummy test data to database"
mysql -h 127.0.0.1 -P 3306 -uroot -p$(kubectl get secret --namespace "$K_NS" \
    "$M_NAME" -o jsonpath="{.data.mariadb-root-password}" | base64 -d) \
    my_database < ../configFiles/dummy-db.sql

echo "🗒️  Scale down to one replica"
kubectl scale statefulset --replicas=1 "$M_NAME" -n "$K_NS"

echo "🗒️  Waiting for 10 seconds to ensure scaling is finished..."
sleep 10

echo "🗒️  Backup DB"
velero backup create "$BACKUP" --include-namespaces "$K_NS"

echo "🗒️  Now check the README on how to continue".
