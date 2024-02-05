# Base folder
resource "google_folder" "base" {
  display_name = var.folder_name
  parent       = var.folder_parent
}

## Create bootstrap project
resource "google_project" "project" {
  name            = var.project_id
  project_id      = var.project_id
  billing_account = var.billing_id
  folder_id       = google_folder.base.name
  lifecycle {
    ignore_changes = [
      labels
    ]
  }
}

## Configure Project APIs
resource "google_project_service" "apis" {
  for_each           = toset(local.apis)
  project            = google_project.project.project_id
  service            = each.value
  disable_on_destroy = false
}

# Artifact Registry
resource "google_artifact_registry_repository" "repo" {
  location      = var.location
  repository_id = google_project.project.project_id
  description   = "Container for Containers"
  format        = "DOCKER"
  project       = google_project.project.project_id
  depends_on = [
    google_project_service.apis
  ]
}

### Provision the Firestore database instance.
resource "google_firestore_database" "customer_db" {
  project     = google_project.project.project_id
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
  project      = google_project.project.project_id
}

# IAM bindings
resource "google_project_iam_member" "api" {
  for_each = toset(local.cloud_run_iam_roles)
  project  = google_project.project.project_id
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

# Configure policy to allow any user to access bond service
resource "google_cloud_run_service_iam_policy" "api" {
  # Depend on cloud run being allowed unauthenticated
  depends_on = [google_org_policy_policy.cloud_run_no_auth]
  location   = google_cloud_run_service.api.location
  project    = google_cloud_run_service.api.project
  service    = google_cloud_run_service.api.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# Configure policy to allow any user to access bond service
resource "google_cloud_run_service_iam_policy" "ui" {
  depends_on = [google_org_policy_policy.cloud_run_no_auth]
  # Depend on cloud run being allowed unauthenticated
  location = google_cloud_run_service.ui.location
  project  = google_cloud_run_service.ui.project
  service  = google_cloud_run_service.ui.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# Allow Cloud Run services to be deployed without authentication
resource "google_org_policy_policy" "cloud_run_no_auth" {
  depends_on = [
    google_project_service.apis,
  ]

  name   = "projects/${google_project.project.project_id}/policies/iam.allowedPolicyMemberDomains"
  parent = "projects/${google_project.project.project_id}"

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
  project                    = google_project.project.project_id
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
          value = google_project.project.project_id
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
  project                    = google_project.project.project_id
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
          value = google_project.project.project_id
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

## Configure a network for various functions
resource "google_compute_network" "network" {
  project                 = google_project.project.project_id
  name                    = "vpc-${var.project_id}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project       = google_project.project.project_id
  region        = var.location
  name          = "sn-${var.project_id}"
  network       = google_compute_network.network.id
  ip_cidr_range = var.subnet

  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}

# Allow Workstations to have an external IP address
resource "google_org_policy_policy" "external_ips" {
  depends_on = [
    google_project_service.apis
  ]

  name   = "projects/${var.project_id}/policies/compute.vmExternalIpAccess"
  parent = "projects/${var.project_id}"

  spec {
    inherit_from_parent = false
    rules {
      # Change to allow all
      allow_all = "TRUE"
    }
  }
}

resource "google_workstations_workstation_cluster" "default" {
  provider               = google-beta
  workstation_cluster_id = var.workstation_cluster_id
  network                = google_compute_network.network.id
  subnetwork             = google_compute_subnetwork.subnet.id
  location               = var.location
  project                = google_project.project.project_id
}

resource "google_workstations_workstation_config" "default" {
  provider               = google-beta
  workstation_config_id  = "workstation-config"
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = var.location
  project                = google_project.project.project_id

  host {
    gce_instance {
      machine_type                = "e2-standard-4"
      boot_disk_size_gb           = 35
      disable_public_ip_addresses = false
    }
  }
}

resource "google_workstations_workstation" "default" {
  provider               = google-beta
  workstation_id         = var.workstation_name
  workstation_config_id  = google_workstations_workstation_config.default.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.default.workstation_cluster_id
  location               = var.location
  project                = google_project.project.project_id

  labels = {
    "label" = "key"
  }

  env = {
    name = "foo"
  }

  annotations = {
    label-one = "value-one"
  }
}
