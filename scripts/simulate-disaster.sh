#!/bin/bash

K_NS="mariadb-galera-ns"

echo "🗒️  Simulating disaster by deleting $K_NS namespace."
kubectl delete namespace "$K_NS"

echo "🗒️  Delete persistent volumes."
kubectl delete persistentvolumes mariadb-pv{0,1,2}

echo "🗒️  Now check the README on how to continue."
