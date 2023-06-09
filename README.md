# List of modules that have been used:
- [Terraform Flux Bootstrap Git Module](https://github.com/den-vasyliev/tf-fluxcd-flux-bootstrap/tree/main)
- [GitHub Repository Terraform Module](https://github.com/den-vasyliev/tf-github-repository)
- [TLS Private Key Terraform Module](https://github.com/den-vasyliev/tf-hashicorp-tls-keys)
- [Terraform module for kind cluster](https://github.com/den-vasyliev/tf-kind-cluster)

# Requirements

- [Install the terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)

- [Install the fluxcd](https://fluxcd.io/flux/installation)

- [Create GitHub token:](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

For personal access token (classic), I think the minimum I need for bootstrap to github is:
|         | 		   		         |		 							                    |
| ------: | :----------------- |:------------------------------------ |
| ✅      | `repo`             | Full control of private repositories |
| ✅      | `admin:public_key` | Full control of user public keys     |
|  		    |  		   		         |	    							                  |

- [Install kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-with-a-package-manager)
- Add all sensitive varibles to `vars.tfvars` file, see `vars.tfvars.sample`.

# Infrastructure deployment to local kind
1. Edit the `vars.tfvars` file, specifying the necessary values in accordance with the configuration
2. Clone repository
``` bash
$ git clone --branch test/kind --single-branch https://github.com/vanelin/tf-gcp-gke-cluster-flux.git
$ cd tf-gcp-gke-cluster-flux
```

3. Deploy a Kubernetes Cluster + Flux
```bash
$ terraform init
$ terraform validate
$ terraform plan -var-file=vars.tfvars
$ terraform apply -var-file=vars.tfvars

$ terraform state list
module.flux_bootstrap.flux_bootstrap_git.this
module.github_repository.github_repository.this
module.github_repository.github_repository_deploy_key.this
module.kind_cluster.kind_cluster.this
module.tls_private_key.tls_private_key.this
```
4. Configure the kind:
```bash
# List all the Kind clusters available on your system
$ kind get clusters
kind-cluster

# Export the configuration file for the Kind cluster you want to switch to
$ kind export kubeconfig --name kind-cluster

# Set the current context to the Kind cluster you just exported the configuration for
$ kubectl config use-context kind-kind-cluster

# Optionally, specify the namespace to use in the current context
$ kubectl config use-context kind-kind-cluster -n default

```

5. Clone the infrastructure repository `flux-gitops`. 

#### Example how to use flux:
```bash
# Clone the GitHub repository containing the Flux manifests
$ git clone https://github.com/vanelin/flux-gitops.git

# Change into the directory for the demo cluster and create a new directory for the namespace
$ cd flux-gitops
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
```

6. Destroy all infrastructure:
```bash
$ terraform destroy -var-file=vars.tfvars
```