resource "google_project_service" "api_services" {
  project = var.project_id
  for_each = toset(
    [
      "iam.googleapis.com",
      "compute.googleapis.com",
      "cloudresourcemanager.googleapis.com",
    ]
  )
  service                    = each.key
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_service_account" "airbyte" {
  account_id   = "airbyte"
  display_name = "airbyte"
  description  = "Authorisation to use with Airbyte and Compute Engine VM"
  depends_on   = [google_project_service.api_services]
}

resource "google_project_iam_member" "airbyte-service-account-iam" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/run.admin",
    "roles/logging.admin",
    "roles/bigquery.jobUser",
    "roles/bigquery.dataEditor"
  ])
  role       = each.value
  project    = var.project_id
  member     = "serviceAccount:${google_service_account.airbyte.email}"
  depends_on = [google_project_service.api_services]
}

resource "google_compute_instance" "airbyte-instance" {
  name                    = "${var.project_id}-airbyte-instance"
  zone                    = var.zone
  machine_type            = "e2-micro"
  metadata_startup_script = file("./sh_scripts/airbyte.sh")

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20230206"
    }
  }
  network_interface {
    network    = "default"
    subnetwork = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  service_account {
    scopes = [
      "cloud-platform",
    ]
    email = google_service_account.airbyte.email
  }

  depends_on = [google_project_service.api_services]
}
