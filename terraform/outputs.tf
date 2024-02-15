output "ui_instance_url" {
  value       =  google_cloud_run_service.ui.status.0.url
  description = "UI URL"
}

output "api_instance_url" {
  value       =  google_cloud_run_service.api.status.0.url
  description = "API URL"
}
