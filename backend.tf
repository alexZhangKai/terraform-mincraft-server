terraform {
  required_version = "~> 0.12.23"

  required_providers {
    google = "~> 3.0"
  }

  backend "gcs" {
    bucket = "mc-server-tf-state"
    prefix = "terraform/state"
  }
}
