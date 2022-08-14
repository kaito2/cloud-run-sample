terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.31.0"
    }
  }

  backend "gcs" {
    bucket = "YOUR_BUCKET_NAME" // TODO: Replace this.
    prefix = "terraform/state"
  }
}