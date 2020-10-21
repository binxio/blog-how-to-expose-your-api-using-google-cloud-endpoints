resource "google_storage_bucket" "paas-monitor" {
  name          = "paas-monitor-${var.project}-static-content"
  location      = "EU"
  storage_class = "MULTI_REGIONAL"

  website {
    main_page_suffix = "index.html"
  }
}

resource "google_storage_bucket_acl" "paas-monitor" {
  bucket = "paas-monitor-${var.project}-static-content"

  default_acl    = "publicread"
  predefined_acl = "publicread"
}

resource "google_compute_backend_bucket" "paas-monitor" {
  name        = "paas-monitor"
  bucket_name = google_storage_bucket.paas-monitor.name

  enable_cdn = true
}

resource "google_storage_bucket_iam_binding" "paas-monitor" {
  bucket = "paas-monitor-${var.project}-static-content"
  role   = "roles/storage.objectViewer"

  members    = ["allUsers"]
  depends_on = [google_storage_bucket.paas-monitor]
}

resource "google_storage_bucket_object" "index" {
  name          = "index.html"
  source        = "./public/index.html"
  bucket        = "paas-monitor-${var.project}-static-content"
  cache_control = "public, max-age=300"
  depends_on    = [google_storage_bucket.paas-monitor]
}

resource "google_storage_bucket_object" "monitor-controller-js" {
  name          = "monitor-controller.js"
  source        = "./public/monitor-controller.js"
  bucket        = "paas-monitor-${var.project}-static-content"
  cache_control = "public, max-age=300"
  depends_on    = [google_storage_bucket.paas-monitor]
}

resource "google_storage_bucket_object" "style-css" {
  name          = "style.css"
  source        = "./public/style.css"
  content_type  = "text/css"
  bucket        = "paas-monitor-${var.project}-static-content"
  cache_control = "public, max-age=300"
  depends_on    = [google_storage_bucket.paas-monitor]
}

resource "google_storage_bucket_object" "favicon" {
  name         = "favicon.ico"
  source       = "./public/favicon.ico"
  content_type = "image/vnd.microsoft.icon"
  bucket       = "paas-monitor-${var.project}-static-content"
  depends_on   = [google_storage_bucket.paas-monitor]
}
