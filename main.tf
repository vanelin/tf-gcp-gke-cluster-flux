# https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "385711-bucket-tfstate"
    # bucket = "local"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.GOOGLE_PROJECT
  region  = var.GOOGLE_REGION
}

module "gke_cluster" {
  source           = "github.com/vanelin/tf-google-gke-cluster"
  GOOGLE_REGION    = var.GOOGLE_REGION
  GOOGLE_PROJECT   = var.GOOGLE_PROJECT
  GKE_NUM_NODES    = 2
  GKE_MACHINE_TYPE = var.GKE_MACHINE_TYPE
}
