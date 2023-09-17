# SFT Kind Helm MariaDB Galera Velero

This guide was created based on the following tutorials:
- https://velero.io/docs/v1.11/contributions/minio/
- https://docs.bitnami.com/tutorials/backup-restore-data-mariadb-galera-kubernetes/

0. This guide assumes that you have the following tools installed:
    - Go
    - Docker
    - Kubernets (kubectl)
    - velero
    - helm
    - mysql CLI

1. Change to the `scripts` directory.
2. Run `./setup.sh`.
3. Check if pods are ready with `kubectl get pods`
4. Run `./fill-db-and-backup.sh`.
5. Run `./connect-to-db.sh` to check if database contains the right data.
6. Run `./simulate-disaster.sh`.
7. Check that pods and persistent volumes are gone.
8. Run `./restore-backup.sh`.
9. Wait until all pods are running again.
10. Run `./scale-up.sh`.
11. Wait until pods are back up.
12. Run `./connect-to-db.sh` to check if backup was restored correctly.
