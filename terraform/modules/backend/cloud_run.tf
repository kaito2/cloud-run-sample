resource "google_service_account" "runner" {
  project = var.project_id

  account_id   = "${local.product_name}-runner"
  display_name = "Runner of web Cloud Run (Managed by Terraform)"
}

resource "google_project_iam_member" "runner" {
  project = var.project_id

  // TODO: Change to weaker permissions.
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_cloud_run_service" "main" {
  project = var.project_id

  name     = local.product_name
  location = "asia-northeast1"
  template {
    spec {
      service_account_name = google_service_account.runner.email
      containers {
        ports {
          container_port = 3000
        }
        // NOTE: 初回作成時のみ latest でデプロイ
        image = "asia.gcr.io/${var.project_id}/${local.product_name}:latest"
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = 10
      }
    }
  }

  autogenerate_revision_name = true

  lifecycle {
    ignore_changes = [
      // NOTE: イメージは CI で更新するので Terraform では管理しない
      template[0].spec[0].containers[0].image
    ]
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

// NOTE: 認証自体は別の IDaaS を使うので Cloud Run ネイティブの認証は使わない
resource "google_cloud_run_service_iam_policy" "noauth" {
  project = google_cloud_run_service.main.project

  location    = google_cloud_run_service.main.location
  service     = google_cloud_run_service.main.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
