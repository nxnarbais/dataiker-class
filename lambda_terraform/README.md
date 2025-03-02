# Kubernetes Lambda Terraform Demo

## Get started

### Deploy the lambda

1. Copy and fill the tfvars `cp terraform.tfvars.example terraform.tfvars`
1. `tf init`
1. `tf apply`

### Test the lambda

```bash
curl -X GET https://<lambda_id>.execute-api.<region>.amazonaws.com/beta/ -v
curl -X GET https://<lambda_id>.execute-api.<region>.amazonaws.com/beta/with-datadog -v
```

The first command will trigger a lambda without the enhanced metrics. The second command will trigger a lambda with the Datadog layer that capture logs, traces and Datadog metrics