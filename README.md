[![infracost](https://img.shields.io/endpoint?url=https://dashboard.api.infracost.io/shields/json/cb47d17f-446d-4a9a-9d83-2819f55066c9/repos/a51f4d3f-031e-4131-8d26-c14214c62c21/branch/d5f1f48d-d27f-4a39-bc49-5c63798969d9/vanelin%252Ftf-gcp-gke-cluster-flux)](https://dashboard.infracost.io/org/vano3231/repos/a51f4d3f-031e-4131-8d26-c14214c62c21)

# List of modules that have been used:
- [Terraform Flux Bootstrap Git Module](https://github.com/den-vasyliev/tf-fluxcd-flux-bootstrap/tree/main)
- [GitHub Repository Terraform Module](https://github.com/den-vasyliev/tf-github-repository)
- [TLS Private Key Terraform Module](https://github.com/den-vasyliev/tf-hashicorp-tls-keys)
- [Google Kubernetes Engine (GKE) Cluster Terraform module](https://github.com/vanelin/tf-google-gke-cluster/tree/main)
- [Google Secret Manager for Terraform](https://github.com/GoogleCloudPlatform/terraform-google-secret-manager)

# Requirements

- [Install the terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)

- [Install the fluxcd](https://fluxcd.io/flux/installation)

- [Create GitHub token:](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

For personal access token (classic), I think the minimum I need for bootstrap to github is:
|         | 		   		   |		 							                          |
| ------: | :----------------- |:------------------------------------ |
| ✅      | `repo`             | Full control of private repositories |
| ✅      | `admin:public_key` | Full control of user public keys     |
|  		    |  		   		         |	    							                  |

- [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)
  - `gcloud auth login`
  - `gcloud auth application-default login`
- Add all sensitive varibles to `vars.tfvars` file, see `vars.tfvars.sample`.

# Infrastructure deployment to GKE
1. Edit the `vars.tfvars` file, specifying the necessary values in accordance with the configuration
2. Create a Google Storage Bucket:
```bash
$ gcloud storage buckets create gs://385711-bucket-tfstate --project=<PROJECT_ID> --default-storage-class=STANDARD --location=US --uniform-bucket-level-access
```
3. Clone repository
``` bash
$ git clone https://github.com/vanelin/tf-gcp-gke-cluster-flux.git
$ cd tf-gcp-gke-cluster-flux
```

4. Deploy a Kubernetes Cluster + Flux
  ```bash
 $ terraform init
 $ terraform validate
 $ terraform plan -var-file=vars.tfvars
 $ terraform apply -var-file=vars.tfvars

$ terraform state list
module.flux_bootstrap.flux_bootstrap_git.this
module.github_repository.github_repository.this
module.github_repository.github_repository_deploy_key.this
module.gke_cluster.data.google_client_config.current
module.gke_cluster.data.google_container_cluster.main
module.gke_cluster.google_container_cluster.this
module.gke_cluster.google_container_node_pool.this
module.tls_private_key.tls_private_key.this
module.gke_cluster.module.gke_auth.data.google_client_config.provider
module.gke_cluster.module.gke_auth.data.google_container_cluster.gke_cluster
  ```

5. Fetch credentials for a running cluster.
```bash
$ gcloud container clusters get-credentials main --zone ${GOOGLE_REGION} --project ${GOOGLE_PROJECT}

```

6. Clone the infrastructure repository `flux-gitops`.
#### Example how to use flux:
```bash
# Clone the GitHub repository containing the Flux manifests
$ git clone https://github.com/${GITHUB_OWNER}/${FLUX_GITHUB_REPO}

# Change into the directory for the demo cluster and create a new directory for the namespace
$ cd ${FLUX_GITHUB_REPO}
$ mkdir clusters/demo && cd $_

# Create a Kubernetes Namespace for the demo
$ cat <<EOF > ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo
EOF

# Create a GitRepository custom resource for the kbot repository
$ cat <<EOF > kbot-gr.yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: kbot
  namespace: demo
spec:
  interval: 1m0s
  ref:
    branch: main
  url: https://github.com/vanelin/kbot
EOF

# Create a HelmRelease custom resource for the kbot chart
$ cat <<EOF > kbot-hr.yaml
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kbot
  namespace: demo
spec:
  chart:
    spec:
      chart: ./helm
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: GitRepository
        name: kbot
  interval: 1m0s
EOF

# Commit the changes and push to the Git repository
$ git commit -am "Add kbot manifest" && git push

# Get a list of all the components managed by Flux and their status
$ flux get all

# Get flux logs
$ flux logs

# Manual pass varible TELE_TOKEN to pod
$ cat <<EOF > secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: kbot
type: Opaque
data:
  token: "<YOUR-TOKEN>"
EOF

$ kubectl apply -f secret.yaml

$ kubectl get po,secrets        
NAME                        READY   STATUS
pod/kbot-6bb874fd54-6jwhh   1/1     Running

NAME                                TYPE
secret/kbot                         Opaque
secret/sh.helm.release.v1.kbot.v1   helm.sh/release.v1
```

7. Destroy all infrastructure:
```bash
$ terraform destroy -var-file=vars.tfvars
```