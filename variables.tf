variable "username" {
  description = "User name of the Kestra instance"
  type        = string
  sensitive   = true
}

variable "api_token" {
  description = "API token to the Service Account of the Kestra instance"
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Hostname of the Kestra instance"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID of the Kestra instance"
  type        = string
}