resource "google_dns_managed_zone" "tld" {
  name        = "paas-monitor-tld"
  dns_name    = "${var.domain-name}."
  description = "top level domain name for the paas-monitor ${var.domain-name}"
  depends_on  = ["google_project_service.dns"]
}

resource "google_project_service" "dns" {
  service = "dns.googleapis.com"
}

output "tld-name-servers" {
  value = "${google_dns_managed_zone.tld.name_servers}"
}
