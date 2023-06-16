
resource "github_actions_secret" "wif-sa-email" {
  repository      = var.FLUX_GITHUB_REPO
  secret_name     = "SA_EMAIL"
  plaintext_value = google_service_account.github_actions.email
  depends_on      = [module.github_repository]
}

resource "github_actions_secret" "wif-pool" {
  repository      = var.FLUX_GITHUB_REPO
  secret_name     = "WIF_POOL"
  plaintext_value = google_iam_workload_identity_pool_provider.github.name
  depends_on      = [module.github_repository]
}

resource "github_actions_secret" "gcp-project" {
  repository      = var.FLUX_GITHUB_REPO
  secret_name     = "GCP_PROJECT"
  plaintext_value = var.GOOGLE_PROJECT
  depends_on      = [module.github_repository]
}
