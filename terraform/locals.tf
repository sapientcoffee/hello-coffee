locals {
  # Google Cloud APIs to enable
  apis = [
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "firestore.googleapis.com",
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "workstations.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "orgpolicy.googleapis.com",
    #"identitytoolkit.googleapis.com",
    #"firebase.googleapis.com",
    #"firebaserules.googleapis.com",
    #"firebasehosting.googleapis.com",
  ]
  # API IAM Roles
  cloud_run_iam_roles = [
    "roles/cloudprofiler.agent",
    "roles/cloudtrace.agent",
    "roles/datastore.user",
  ]
  # URL for Artifact Registry
  container_repo = "${google_artifact_registry_repository.repo.location}-docker.pkg.dev/${google_artifact_registry_repository.repo.project}/${google_artifact_registry_repository.repo.name}"

#   # Cloud Build SA
#   build_sa = "service-${google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
#   other_build_sa = "${google_project.project.number}@cloudbuild.gserviceaccount.com"
#   build_roles = [
#     "roles/owner",
#     "roles/iam.serviceAccountUser",
#     "roles/secretmanager.secretAccessor",
#   ]
}
