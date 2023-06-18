variable "GOOGLE_PROJECT" {
  type        = string
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "us-central1-c"
  description = "GCP region to use"
}

variable "GKE_MACHINE_TYPE" {
  type        = string
  default     = "e2-small"
  description = "Machine type"
}

variable "GKE_NUM_NODES" {
  type        = number
  default     = 3
  description = "GKE nodes number"
}

variable "GITHUB_OWNER" {
  type        = string
  description = "GitHub owner repository to use"
}

variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub personal access token"
  sensitive   = true
}

variable "FLUX_GITHUB_REPO" {
  type        = string
  default     = "gke-flux-gitops"
  description = "Flux GitOps repository"
}

variable "FLUX_GITHUB_TARGET_PATH" {
  type        = string
  default     = "clusters"
  description = "Flux manifests subdirectory"
}

variable "SECRET_DATA" {
  type        = string
  description = "Secret token for TELE_TOKEN"
  sensitive   = true
}

variable "SECRET_NAME" {
  type        = string
  default     = "TELE_TOKEN"
  description = "Secret name"
}
