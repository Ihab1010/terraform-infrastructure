# =============================================================================
# COMPUTE MODULE VARIABLES
# =============================================================================

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
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

variable "nginx_health_check_id" {
  description = "Health check ID for NGINX instances"
  type        = string
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

variable "core_health_check_id" {
  description = "Health check ID for core instances"
  type        = string
} 