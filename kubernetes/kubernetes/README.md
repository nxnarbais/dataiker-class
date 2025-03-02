Kubernetes Architecture
=======================

## Kubernetes Cluster

### Local (Kind)

```
# Create cluster
kind create cluster --config=k8s_kind.yaml

# Delete all Kind clusters
kind get clusters | xargs -t -n1 kind delete cluster --name
```

### Local Minikube

```
# Start cluster
minikube start --nodes=3 --mount --mount-string="<your_local_folder>:/app/myapps"

# For instance:
minikube start --nodes=3 --mount --mount-string="/Users/nicolas.narbais/pproject/myapps_deployment:/app/datadog-sandbox"
```

```
# Visualize minikube dashboard
minikube dashboard

# Redirect traffic to localhost
minikube tunnel --clean
```

## Deploy

### Prep: App

1. Make sure you have NodeJS installed
1. Run `npm i` to install dependencies on each folder `frontend` and `product_catalog`
1. Run `npm run start` to start the app in each folder to see if things are working well
  1. Run `curl localhost:3000` to check that everything is working
  1. Stop the app with `CTRL-C`

### Prep: Deploy Datadog

#### Optional - Create secrets
1. Copy and edit the `datadog_secret.yaml.example`: `cp datadog_secret.yaml.example datadog_secret.yaml`
    1. Add the encoded secrets
1. Deploy the secrets: `kubectl apply -f datadog_secret.yaml`

#### Operator

[Datadog doc](https://docs.datadoghq.com/getting_started/containers/datadog_operator/)

```
helm repo add datadog https://helm.datadoghq.com
helm install my-datadog-operator datadog/datadog-operator
kubectl create secret generic datadog-secret --from-literal api-key=<DATADOG_API_KEY>

# https://github.com/DataDog/datadog-operator/tree/main/examples/datadogagent/v2alpha1
kubectl apply -f datadog-agent.yaml
```

To delete
```
kubectl delete datadogagent datadog
helm delete my-datadog-operator
```

### Deploy the app

```
# Deploy
kubectl apply -f app_deployment

# Delete
kubectl delete -f app_deployment
```

### Deploy Vector

```
helm install vector vector/vector --values values-vector.yaml
```