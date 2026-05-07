variable "gcp_project_id" {
  type = string
}

variable "port_client_id" {
  type      = string
  sensitive = true
}

variable "port_client_secret" {
  type      = string
  sensitive = true
}

variable "environment_name" {
  type = string
}

variable "service_id" {
  type = string
}

variable "base_branch" {
  type    = string
  default = "main"
}

variable "ttl" {
  type    = string
  default = "8h"
}
