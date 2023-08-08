# SFT Kind Helm MariaDB Galera Velero

This guide was created based on the following tutorials:
- https://velero.io/docs/v1.11/contributions/minio/
- https://docs.bitnami.com/tutorials/backup-restore-data-mariadb-galera-kubernetes/

1. Pre-requisites: install Go, Docker, and Kubernetes (kubectl)
2. `go install sigs.k8s.io/kind@v0.20.0`
3. Create cluster config file in directory:  (taken from [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#control-plane-ha))
```yaml
# config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
	role: control-plane
	role: worker
	role: worker
```

4. Run `kind create cluster --config config.yaml`
5. Install helm: `brew install helm`
6. Add bitnami helmchart repo:
   `helm repo add bitnami https://charts.bitnami.com/bitnami`
7. Create kubernetes namespace: `kubectl create namespace mariadb-galera`
8. Install mariadb galera helmchart: `helm install bitnami/mariadb-galera --generate-name --namespace mariadb-galera`
9. ❗add some data to mariaDB
```shell
    kubectl port-forward --namespace mariadb-galera svc/mariadb-galera-1690979388 3306:3306 &
    mysql -h 127.0.0.1 -P 3306 -uroot -p$(kubectl get secret --namespace mariadb-galera mariadb-galera-1690979388 -o jsonpath="{.data.mariadb-root-password}" | base64 -d) my_database
```
10. Add a table:
```sql
CREATE TABLE person(personId int, LastName varchar(255));
```
11. Insert a value:
```sql
INSERT INTO person(personId, LastName) VALUES (1, "testing");
```
and check:
```sql
SELECT * FROM person;
```
12. Follow Velero tutorial here: https://velero.io/docs/v1.11/contributions/minio/
13. Install Velero: `brew install velero`
14. Create credentials file:
```
[default]
aws_access_key_id = minio
aws_secret_access_key = minio123
```
15. Create `00-minio-deployment.yaml` file from Velero [examples](https://github.com/vmware-tanzu/velero/blob/main/examples/minio/00-minio-deployment.yaml)
```yaml
# Copyright 2017 the Velero contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

---
apiVersion: v1
kind: Namespace
metadata:
  name: velero

---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: velero
  name: minio
  labels:
    component: minio
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      component: minio
  template:
    metadata:
      labels:
        component: minio
    spec:
      volumes:
      - name: storage
        emptyDir: {}
      - name: config
        emptyDir: {}
      containers:
      - name: minio
        image: minio/minio:latest
        imagePullPolicy: IfNotPresent
        args:
        - server
        - /storage
        - --config-dir=/config
        env:
        - name: MINIO_ACCESS_KEY
          value: "minio"
        - name: MINIO_SECRET_KEY
          value: "minio123"
        ports:
        - containerPort: 9000
        volumeMounts:
        - name: storage
          mountPath: "/storage"
        - name: config
          mountPath: "/config"

---
apiVersion: v1
kind: Service
metadata:
  namespace: velero
  name: minio
  labels:
    component: minio
spec:
  # ClusterIP is recommended for production environments.
  # Change to NodePort if needed per documentation,
  # but only if you run Minio in a test/trial environment, for example with Minikube.
  type: ClusterIP
  ports:
    - port: 9000
      targetPort: 9000
      protocol: TCP
  selector:
    component: minio

---
apiVersion: batch/v1
kind: Job
metadata:
  namespace: velero
  name: minio-setup
  labels:
    component: minio
spec:
  template:
    metadata:
      name: minio-setup
    spec:
      restartPolicy: OnFailure
      volumes:
      - name: config
        emptyDir: {}
      containers:
      - name: mc
        image: minio/mc:latest
        imagePullPolicy: IfNotPresent
        command:
        - /bin/sh
        - -c
        - "mc --config-dir=/config config host add velero http://minio:9000 minio minio123 && mc --config-dir=/config mb -p velero/velero"
        volumeMounts:
        - name: config
          mountPath: "/config"
```
`kubectl apply -f 00-minio-deployment.yaml`
16. Install Velero in the cluster:
```shell
velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.7.1 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --use-volume-snapshots=false \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://minio.velero.svc:9000
```
17. Backup MariaDB:
    `velero backup create mariadb-galera --include-namespace mariadb-galera`
18. Simulate disaster: `kubectl delete namespace mariadb-galera`
19. Restore backup: `velero restore create --from-backup mariadb-galera`
