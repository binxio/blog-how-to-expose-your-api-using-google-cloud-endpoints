variable "region" {}
variable "project" {}

resource "google_compute_region_instance_group_manager" "paas-monitor" {
  name = "paas-monitor-${var.region}"

  base_instance_name = "paas-monitor-${var.region}"
  region             = var.region

  version {
    name              = "v1"
    instance_template = google_compute_instance_template.paas-monitor.self_link
  }

  named_port {
    name = "paas-monitor"
    port = 1337
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.paas-monitor.self_link
    initial_delay_sec = 30
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 3
    min_ready_sec                = 60
  }
}

resource "google_compute_instance_template" "paas-monitor" {
  description = "the paas-monitor backend application."

  tags = ["paas-monitor"]

  instance_description = "paas-monitor backend"
  machine_type         = "g1-small"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  disk {
    source_image = data.google_compute_image.cos_image.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = ""
    }
  }

  metadata = {
    startup-script = data.template_file.startup-script.rendered
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "startup-script" {
  template = file("${path.module}/startup-script.sh")

  vars = {
    region       = var.region
    service_name = "paas-monitor.endpoints.${var.project}.cloud.goog"
  }
}

resource "google_compute_region_autoscaler" "paas-monitor" {
  name   = "paas-monitor-${var.region}"
  target = google_compute_region_instance_group_manager.paas-monitor.self_link

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }

  region = var.region
}

resource "google_compute_http_health_check" "paas-monitor" {
  name         = "paas-monitor-${var.region}"
  request_path = "/health"

  timeout_sec        = 5
  check_interval_sec = 5
  port               = 1337

  lifecycle {
    create_before_destroy = true
  }
}

data "google_compute_image" "cos_image" {
  family  = "cos-stable"
  project = "cos-cloud"
}

output "instance_group_manager" {
  value = google_compute_region_instance_group_manager.paas-monitor.instance_group
}

output "health_check" {
  value = google_compute_http_health_check.paas-monitor.self_link
}
