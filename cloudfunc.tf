resource "google_storage_bucket" "cf-source" {
  name          = "mc-world-cloud-func-source"
  location      = "EU"
  force_destroy = true
}

resource "google_storage_bucket_object" "source-file" {
  name   = "index.zip"
  bucket = google_storage_bucket.cf-source.name
  source = "./cloud_function/index.zip"
}

resource "google_cloudfunctions_function" "trigger-mc-server" {
  name    = "trigger-mc-server"
  runtime = "nodejs8"
  region  = "asia-east2"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cf-source.name
  source_archive_object = google_storage_bucket_object.source-file.name
  trigger_http          = true
  timeout               = 300
  entry_point           = "stopServer"
}
