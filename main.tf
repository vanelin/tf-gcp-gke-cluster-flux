# # Use if you want crate new GitHub repository for Flux
# module "github_repository" {
#   source                   = "github.com/den-vasyliev/tf-github-repository"
#   github_owner             = var.GITHUB_OWNER
#   github_token             = var.GITHUB_TOKEN
#   repository_name          = var.FLUX_GITHUB_REPO
#   public_key_openssh       = module.tls_private_key.public_key_openssh
#   public_key_openssh_title = "flux"
# }

# Use if you want to use already existing GitHub repository for Flux
resource "github_repository_deploy_key" "deploy_key" {
  title      = "flux"
  repository = var.FLUX_GITHUB_REPO
  key        = module.tls_private_key.public_key_openssh
  read_only  = false
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
}

module "gke_cluster" {
  source           = "github.com/vanelin/tf-google-gke-cluster?ref=gke_auth"
  GOOGLE_REGION    = var.GOOGLE_REGION
  GOOGLE_PROJECT   = var.GOOGLE_PROJECT
  GKE_NUM_NODES    = var.GKE_NUM_NODES
  GKE_MACHINE_TYPE = var.GKE_MACHINE_TYPE
}

module "flux_bootstrap" {
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap?ref=gke_auth"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  github_token      = var.GITHUB_TOKEN
  config_host       = module.gke_cluster.config_host
  config_token      = module.gke_cluster.config_token
  config_ca         = module.gke_cluster.config_ca
}

module "gke-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.GOOGLE_PROJECT
  location            = var.GOOGLE_REGION
  cluster_name        = "main"
  annotate_k8s_sa     = true
  use_existing_k8s_sa = true
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
}

module "kms" {
  source          = "github.com/den-vasyliev/terraform-google-kms"
  project_id      = var.GOOGLE_PROJECT
  location        = "global"
  keyring         = "sops-flux-1"
  keys            = ["sops-key-flux-1"]
  prevent_destroy = false
}
