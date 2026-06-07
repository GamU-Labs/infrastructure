variable "do_token" {
  description = "DigitalOcean personal access token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "capstone"
}

variable "environment" {
  description = "Deployment environment (production, staging)"
  type        = string
  default     = "production"
}

variable "region" {
  description = "DigitalOcean region slug"
  type        = string
  default     = "sgp1"
}

variable "droplet_size" {
  description = "Droplet size slug (see: doctl compute size list)"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "ssh_key_name" {
  description = "Name of the SSH key registered in DigitalOcean"
  type        = string
}

variable "do_project_id" {
  description = "DigitalOcean project ID to assign resources to (leave empty if not used)"
  type        = string
  default     = ""
}
