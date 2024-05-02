# VPC
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

# reserved IP address - required for external load balancer.
resource "google_compute_global_address" "default" {
  name     = "${var.web_server_name}-static-ip"
}

# forwarding rule - Our fowarding rule sends all requests to the node group
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.web_server_name}-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "${var.web_server_name}-target-http-proxy"
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "${var.web_server_name}-url-map"
  default_service = google_compute_backend_service.default.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
  name                    = "${var.web_server_name}-backend-service"
  protocol                = "HTTP"
  port_name               = "web"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  enable_cdn              = false
  health_checks           = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  name         = "${var.web_server_name}-mig-template"
  machine_type = "e2-small"
  tags         = ["allow-health-check"]

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    access_config {}
  }
  disk {
    source_image = "centos-cloud/centos-7"
    auto_delete  = true
    boot         = true
  }
  # metadata_startup_script = "sudo yum install -y python3 git; pip3 install flask; mkdr /opt/apester; git clone https://github.com/asafaven/pmo.git /opt/apester/${var.web_server_name}; cd /opt/apester/${var.web_server_name}/web-flask; python3 web.py"
  # metadata = {
  #   startup-script = <<-EOF
  #     #! /bin/bash
  #     sudo yum install -y python3 git
  #     pip3 install flask
  #     mkdir /opt/apester 
  #     git clone ${var.git_repo} /opt/apester/pmo
  #     cd /opt/apester/pmo/web-flask
  #     python3 web.py
  #   EOF
  # }
  lifecycle {
    create_before_destroy = true
  }
}

# health check
resource "google_compute_health_check" "default" {
  name     = "${var.web_server_name}-hc"
  http_health_check {
    port_specification = "USE_NAMED_PORT"
    port_name = "web"
  }
}

# MIG
resource "google_compute_region_instance_group_manager" "default" {
  name                      = "${var.web_server_name}-mig1"
  region                    = var.region
  distribution_policy_zones = var.zones
  named_port {
    name = "web"
    port = var.port_number
  }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "${var.web_server_name}-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}