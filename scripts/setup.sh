#!/bin/bash

set -e

K_NS="mariadb-galera-ns"
M_NAME="mariadb-galera-helm"

echo "🗒️  Installing kind"
go install sigs.k8s.io/kind@v0.20.0

echo "🗒️  Setting up kind cluster"
kind create cluster --config "../configFiles/kind-config-3-nodes.yaml"

echo "🗒️  Add bitnami chart repo"
helm repo add bitnami https://charts.bitnami.com/bitnami

echo "🗒️  Creating namespace $K_NS"
kubectl create namespace "$K_NS"

echo "🗒️  Creating new local storage class"
kubectl apply -f "../configFiles/storage-class.yaml" -n "$K_NS"

echo "🗒️  Creating persistent volumes"
kubectl apply -f "../configFiles/pv.yaml" -n "$K_NS"

echo "🗒️  Install MariaDB Galera helm chart with name $M_NAME in namespace $K_NS"
helm install "$M_NAME" bitnami/mariadb-galera --namespace "$K_NS" --set persistence.storageClass=mariadb-local-storage

echo "🗒️  Now wait until all pods are ready before continuing with the next script (see README)"
