data "google_client_config" "provider" {}

provider "google" {
  project = var.project_id
  region  = var.region
}
