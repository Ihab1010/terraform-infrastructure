# =============================================================================
# DNS MODULE VARIABLES
# =============================================================================

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "dns_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
  default     = "test-internal-zone"
}

variable "dns_zone_dns_name" {
  description = "DNS name for the private zone"
  type        = string
  default     = "test.internal."
}

variable "dns_record_ttl" {
  description = "TTL for DNS records in seconds"
  type        = number
  default     = 300
}

variable "core_load_balancer_ip" {
  description = "IP address of the core load balancer"
  type        = string
}

variable "nginx_load_balancer_ip" {
  description = "IP address of the NGINX load balancer"
  type        = string
  default     = ""
}

variable "create_nginx_dns_record" {
  description = "Whether to create DNS record for NGINX load balancer"
  type        = bool
  default     = false
}

variable "create_core_instances_dns_record" {
  description = "Whether to create DNS record for core instances"
  type        = bool
  default     = false
}

variable "core_instances_ips" {
  description = "List of IP addresses for core instances"
  type        = list(string)
  default     = []
} 