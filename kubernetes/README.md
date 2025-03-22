# Kubernetes Datadog Demo

## Get started

### Cluster

Deploy cluster with Minikube

```bash
minikube start --driver=podman --mount=true --mount-string=/Users/nicolas.narbais/projects/dataiker-class/kubernetes:/app --nodes=3
```

(optional)

```bash
kubectl label node <node_name> node-role.kubernetes.io/worker=worker
kubectl label nodes <node_name> role=worker
```

Setup tunnel to connect with services from the cluster

```bash
minikube tunnel
```

Other worthy commands

```bash
# https://minikube.sigs.k8s.io/docs/handbook/mount/
minikube ip
minikube mount /Users/nicolas.narbais/projects/dataiker-class:/app --ip=$(minikube ip)   
minikube ssh
minikube delete --all --purge
```

### Deploy Datadog Operator

Follow instructions from https://app.datadoghq.com/account/settings/agent/latest?platform=kubernetes. *Make sure to edit the beginning of the URL with app.datadoghq.eu or others*.

Deploy the operator

```bash
kubectl apply -f kubernetes/datadog-agent.yaml
```

### Deploy the multi-container app

Install node dependencies for product_catalog and frontend

```bash
cd product_catalog
npm install
cd ..
cd frontend
npm install
cd ..
```

Install python dependencies for user-manager

```bash
cd user-manager
python3 -m venv venv
source venv/bin/activate
python -m pip install -r requirements.txt
pip list
cd ..
```

```bash
kubectl apply -f kubernetes/app_deployment
```

### Generate load

Install python dependencies for loadgenerator

```bash
cd loadgenerator
python3 -m venv venv
source venv/bin/activate
python -m pip install -r requirements.txt
pip list
cd ..
```

```bash
```
