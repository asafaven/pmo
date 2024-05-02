# reserved IP address - required to set external ddd ip for the external load balancer.
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

# backend service
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
