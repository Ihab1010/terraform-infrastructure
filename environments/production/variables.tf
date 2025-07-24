# =============================================================================
# DEV ENVIRONMENT VARIABLES
# =============================================================================

# GCP Configuration
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

# Network Configuration
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "nginx-vpc-dev"
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

# NGINX Instance Configuration
variable "nginx_machine_type" {
  description = "Machine type for NGINX instances"
  type        = string
  default     = "e2-micro"
}

variable "nginx_source_image" {
  description = "Source image for NGINX instances"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-11"
}

variable "nginx_disk_size_gb" {
  description = "Disk size in GB for NGINX instances"
  type        = number
  default     = 10
}

variable "nginx_instance_count" {
  description = "Number of NGINX instances"
  type        = number
  default     = 2
}

variable "nginx_startup_script" {
  description = "Startup script for NGINX instances"
  type        = string
  default     = <<-EOT
#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx
  EOT
}

# Core Instance Configuration
variable "core_machine_type" {
  description = "Machine type for core instances"
  type        = string
  default     = "e2-micro"
}

variable "core_source_image" {
  description = "Source image for core instances"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-11"
}

variable "core_disk_size_gb" {
  description = "Disk size in GB for core instances"
  type        = number
  default     = 10
}

variable "core_instance_count" {
  description = "Number of core instances"
  type        = number
  default     = 2
}

variable "core_startup_script" {
  description = "Startup script for core instances"
  type        = string
  default     = <<-EOT
#!/bin/bash
echo "Core Service - Private Instance" > /var/www/html/index.html
cd /var/www/html
python3 -m http.server 80 &
echo "Web server started on port 80"
  EOT
}

# Load Balancer Configuration
variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 5
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 2
}

variable "session_affinity" {
  description = "Session affinity for backend services"
  type        = string
  default     = "NONE"
}

variable "backend_timeout_sec" {
  description = "Backend service timeout in seconds"
  type        = number
  default     = 30
}

# DNS Configuration
variable "dns_zone_name" {
  description = "Name of the private DNS zone"
  type        = string
  default     = "test-internal-zone-dev"
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