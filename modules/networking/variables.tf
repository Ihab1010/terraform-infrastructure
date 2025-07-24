# =============================================================================
# NETWORKING MODULE VARIABLES
# =============================================================================

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "nginx-vpc"
}

variable "public_subnet_cidr" {
  description = "CIDR range for public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR range for private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "proxy_subnet_cidr" {
  description = "CIDR range for proxy-only subnet"
  type        = string
  default     = "10.0.2.0/24"
} 