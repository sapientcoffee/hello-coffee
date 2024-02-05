output "project_id" {
  value       =  google_project.project.project_id
  description = "Project ID Created"
}

output "ui_instance_url" {
  value       =  google_cloud_run_service.ui.status.0.url
  description = "UI URL"
}

output "api_instance_url" {
  value       =  google_cloud_run_service.api.status.0.url
  description = "API URL"
}
