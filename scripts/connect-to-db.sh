#!/bin/bash

K_NS="mariadb-galera-ns"
M_NAME="mariadb-galera-helm"

echo "🗒️  Connecting to database. After connection is established, type 'SELECT * FROM cool_stuff;' to check if database was initialized propertly."
kubectl run mariadb-galera-helm-client --rm --tty -i --restart='Never' -n "$K_NS" --image docker.io/bitnami/mariadb-galera:11.0.3-debian-11-r7 --command \
      -- mysql -h "$M_NAME" -P 3306 -uroot -p$(kubectl get secret -n "$K_NS" "$M_NAME" -o jsonpath="{.data.mariadb-root-password}" | base64 -d) my_database

echo "🗒️  Now check README to see how to continue."
