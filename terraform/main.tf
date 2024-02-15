## Configure Project APIs
resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Artifact Registry
resource "google_artifact_registry_repository" "repo" {
  location      = var.location
  repository_id = var.service
  description   = "Container for Containers"
  format        = "DOCKER"
  project       = var.project_id
  depends_on = [
    google_project_service.apis
  ]
}

### Provision the Firestore database instance.
resource "google_firestore_database" "customer_db" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.app_engine_location

  # "FIRESTORE_NATIVE" is required to use Firestore with Firebase SDKs,
  # authentication, and Firebase Security Rules.
  type             = "FIRESTORE_NATIVE"
  concurrency_mode = "OPTIMISTIC"

  depends_on = [
    google_project_service.apis
  ]
}

## API Service
# Service Account
resource "google_service_account" "api" {
  account_id   = "api-service"
  display_name = "API Service running in Cloud Run"
  project      = var.project_id
}

# IAM bindings
resource "google_project_iam_member" "api" {
  for_each = toset(local.cloud_run_iam_roles)
  project  = var.project_id
  role     = each.key
  member   = "serviceAccount:${google_service_account.api.email}"
}

# Allow requests without auth
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

# Allow Cloud Run services to be deployed without authentication
resource "google_org_policy_policy" "cloud_run_no_auth" {
  depends_on = [
    google_project_service.apis,
  ]

  name   = "projects/${var.project_id}/policies/iam.allowedPolicyMemberDomains"
  parent = "projects/${var.project_id}"

  spec {
    inherit_from_parent = false
    rules {
      allow_all = "TRUE"
    }
  }
}


## API Service
resource "google_cloud_run_service" "api" {
  name                       = "api"
  location                   = var.location
  project                    = var.project_id
  autogenerate_revision_name = true
  template {
    spec {
      service_account_name = google_service_account.api.email
      containers {
        # Deploy empty container for now - allow cloud build trigger to replace later
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        # 512mb RAM / 1 CPU  
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        env {
          name  = "GCP_PROJECT"
          value = var.project_id
        }
        env {
          name  = "GCP_REGION"
          value = var.location
        }
      }
    }
  }
  metadata {
    annotations = {
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].spec[0].containers[0].resources,
      metadata[0].labels,
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }
}


## API Service
resource "google_cloud_run_service" "ui" {
  name                       = "ui"
  location                   = var.location
  project                    = var.project_id
  autogenerate_revision_name = true
  template {
    spec {
      service_account_name = google_service_account.api.email
      containers {
        # Deploy empty container for now - allow cloud build trigger to replace later
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        # 512mb RAM / 1 CPU  
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        env {
          name  = "GCP_PROJECT"
          value = var.project_id
        }
        env {
          name  = "API_SERVICE"
          value = google_cloud_run_service.api.status.0.url
        }
      }
    }
  }
  metadata {
    annotations = {
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  lifecycle {
    ignore_changes = [
      template[0].spec[0].containers[0].image,
      template[0].spec[0].containers[0].resources,
      metadata[0].labels,
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }
}
