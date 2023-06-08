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
module.gke_cluster.data.google_client_config.current
module.gke_cluster.data.google_container_cluster.main
module.gke_cluster.google_container_cluster.this
module.gke_cluster.google_container_node_pool.this
module.tls_private_key.tls_private_key.this
module.gke_cluster.module.gke_auth.data.google_client_config.provider
module.gke_cluster.module.gke_auth.data.google_container_cluster.gke_cluster
```

4. Clone the infrastructure repository `flux-gitops`. Example how to use flux:
```bash
$ git clone https://github.com/${GITHUB_OWNER}/${FLUX_GITHUB_REPO}
$ cd ${FLUX_GITHUB_REPO}

$ mkdir clusters/demo && cd $_

$ cat <<EOF > ns.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo
EOF

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

$ git commit -am "Add kbot manifest" && git push

# Get list and status of components
$ flux get all

# Get logs
$ flux logs
```

5. Destroy all infrastructure:
```bash
$ terraform destroy -var-file=vars.tfvars
```