# Creating VPC network
resource "google_compute_network" "default" {
  name                    = "${var.web_server_name}-network"
  auto_create_subnetworks = false
}

# Subnet to include the backend compute engines.
resource "google_compute_subnetwork" "default" {
  name          = "${var.web_server_name}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}
