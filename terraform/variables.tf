
variable "project_id" {
  type        = string
  description = "Project ID to deploy to"
  default     = "coffee-and-codey"
}

variable "location" {
  type        = string
  description = "Location (region) to deploy to"
  default     = "europe-west2"
}

variable "app_engine_location" {
  type        = string
  description = "Location to deploy App Engine and Firestore"
  default     = "eur3"
}

variable "service" {
  type        = string
  description = "Service Name"
  default     = "cymbal-coffee"
}
