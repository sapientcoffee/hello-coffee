variable "folder_name" {
  type        = string
  description = "Folder name for projects"
  default     = "mattsday"
}
variable "folder_parent" {
  type        = string
  description = "Location for the folder parent"
  default     = "organizations/694643552517"
}
variable "project_id" {
  type        = string
  description = "Project ID to deploy to"
  default     = "butter-robot-demo"
}
variable "billing_id" {
  type        = string
  description = "Billing ID for the all projects"
  default     = "01EBD5-5DADB4-689289"
}
variable "location" {
  type        = string
  description = "Location (region) to deploy to"
  default     = "europe-west1"
}

variable "app_engine_location" {
  type        = string
  description = "Location to deploy App Engine and Firestore"
  default     = "eur3"
}

variable "subnet" {
  type        = string
  description = "VPC Subnet for default location"
  default     = "10.5.0.0/16"
}

variable "workstation_name" {
  type        = string
  description = "Name for the default workstation to be deployed"
  default     = "workstation"
}
variable "workstation_cluster_id" {
  type        = string
  description = "Name for the workstation cluster to be deployed"
  default     = "workstation-cluster"
}
