resource "google_endpoints_service" "paas-monitor" {
  service_name   = "paas-monitor.endpoints.${var.project}.cloud.goog"
  openapi_config = "${data.template_file.open-api-specification.rendered}"
  depends_on     = ["google_project_service.endpoints"]
}

data "template_file" "open-api-specification" {
  template = "${file("paas-monitor-api.yaml")}"

  vars {
    service_name = "paas-monitor.endpoints.${var.project}.cloud.goog"
    ip_address = "${google_compute_global_address.paas-monitor.address}"
  }
}

resource "google_project_service" "endpoints" {
  service = "endpoints.googleapis.com"
}

