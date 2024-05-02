# Creates output of loadbalancer's external IP
output "lb_external_ip" {
    value = google_compute_global_address.default.address
}