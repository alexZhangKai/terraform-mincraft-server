resource "google_cloud_scheduler_job" "stop-server" {
  attempt_deadline = "300s"
  name             = "trigger-tf-mc-server-stop"

  schedule  = "0 23 * * *"
  time_zone = "Australia/Melbourne"

  http_target {
    body        = "eyJjb21tYW5kIjogInN0b3AifQ=="
    http_method = "POST"
    uri         = google_cloudfunctions_function.trigger-mc-server.https_trigger_url

    oidc_token {
      service_account_email = var.service_account
    }
  }
}

resource "google_cloud_scheduler_job" "start-server" {
  attempt_deadline = "300s"
  name             = "trigger-tf-mc-server-start"

  schedule  = "0 12 * * *"
  time_zone = "Australia/Melbourne"

  http_target {
    body        = "eyJjb21tYW5kIjogInN0YXJ0In0="
    http_method = "POST"
    uri         = google_cloudfunctions_function.trigger-mc-server.https_trigger_url

    oidc_token {
      service_account_email = var.service_account
    }
  }
}
