# n8n Datadog Demo

## Get started

### Cluster

Deploy cluster with Minikube

```bash
minikube start --driver=podman --mount=true --mount-string=/Users/nicolas.narbais/projects/dataiker-class/n8n:/app --nodes=1
```

Setup tunnel to connect with services from the cluster

```bash
minikube tunnel
```

### Deploy Datadog Operator

Follow instructions from https://app.datadoghq.com/account/settings/agent/latest?platform=kubernetes. *Make sure to edit the beginning of the URL with app.datadoghq.eu or others*.

Deploy the operator

```bash
kubectl apply -f kubernetes/datadog-agent.yaml
```

### Prometheus - Generate OpenMetrics Scraping

```bash
kubectl apply -f kubernetes/prom.yaml
```
