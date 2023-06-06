[![infracost](https://img.shields.io/endpoint?url=https://dashboard.api.infracost.io/shields/json/cb47d17f-446d-4a9a-9d83-2819f55066c9/repos/a51f4d3f-031e-4131-8d26-c14214c62c21/branch/d5f1f48d-d27f-4a39-bc49-5c63798969d9/vanelin%252Ftf-gcp-gke-cluster-flux)](https://dashboard.infracost.io/org/vano3231/repos/a51f4d3f-031e-4131-8d26-c14214c62c21)

# Infrastructure deployment
1. Edit the `vars.tfvars` file, specifying the necessary values in accordance with the configuration
2. Create a Google Storage Bucket:
```bash
gcloud storage buckets create gs://385711-bucket-tfstate --project=minikube-385711 --default-storage-class=STANDARD --location=US --uniform-bucket-level-access
```
3. Deploy a Kubernetes Cluster
  ```bash
  terraform init
  terraform validate
  terraform plan -var-file=vars.tfvars
  terraform apply -var-file=vars.tfvars
  ```