resource "google_compute_global_forwarding_rule" "paas-monitor" {
  name       = "paas-monitor-port-80"
  target     = "${google_compute_target_http_proxy.paas-monitor.self_link}"
  ip_address = "${google_compute_global_address.paas-monitor.address}"
  port_range = "80"
  depends_on = ["google_compute_global_address.paas-monitor"]
}

resource "google_compute_target_http_proxy" "paas-monitor" {
  name    = "paas-monitor"
  url_map = "${google_compute_url_map.paas-monitor.self_link}"
}

resource "google_compute_url_map" "paas-monitor" {
  name = "paas-monitor"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_bucket.paas-monitor.self_link}"

    path_rule {
      paths   = ["/environment", "/status", "/header", "/health", "/toggle-health", "/request", "/stop"]
      service = "${google_compute_backend_service.paas-monitor.self_link}"
    }
  }

  default_service = "${google_compute_backend_bucket.paas-monitor.self_link}"
}

resource "google_compute_global_address" "paas-monitor" {
  name = "paas-monitor"
}

resource "google_dns_record_set" "paas-monitor" {
  name = "paas-monitor.${google_dns_managed_zone.tld.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.tld.name}"

  rrdatas = ["${google_compute_global_address.paas-monitor.address}"]
}

output "ip-address" {
  value = "${google_compute_global_address.paas-monitor.address}"
}
