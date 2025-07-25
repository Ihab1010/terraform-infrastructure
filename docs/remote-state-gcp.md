# Remote State in Google Cloud Platform (GCP)

## Table of Contents
- [Overview](#overview)
- [What is Remote State?](#what-is-remote-state)
- [Why Use Remote State?](#why-use-remote-state)
- [GCS Backend Configuration](#gcs-backend-configuration)
- [State File Structure](#state-file-structure)
- [State Locking](#state-locking)
- [Best Practices](#best-practices)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Migration Guide](#migration-guide)

## Overview

Remote state in Terraform allows teams to store infrastructure state files in a shared, secure location (Google Cloud Storage) instead of locally on each developer's machine. This enables collaboration, state backup, and centralized state management.

## What is Remote State?

Remote state is Terraform's way of storing the current state of your infrastructure in a remote location rather than locally. The state file contains:

- **Resource metadata** (IDs, attributes, relationships)
- **Resource dependencies** (what depends on what)
- **Resource outputs** (values that other resources can reference)
- **Resource status** (created, updated, destroyed)

## Why Use Remote State?

### ✅ Benefits

| Benefit | Description |
|---------|-------------|
| **Team Collaboration** | Multiple developers can work on the same infrastructure |
| **State Locking** | Prevents concurrent modifications that could corrupt state |
| **State Backup** | Automatic versioning and backup in GCS |
| **Audit Trail** | Track who made changes and when |
| **Security** | Centralized access control and encryption |
| **Disaster Recovery** | State can be restored from backups |

### ❌ Problems with Local State

| Problem | Impact |
|---------|--------|
| **State Conflicts** | Multiple developers overwrite each other's changes |
| **No Backup** | State lost if local machine fails |
| **No Audit Trail** | Can't track who made changes |
| **Manual Sync** | Developers must manually share state files |

## GCS Backend Configuration

### Basic Configuration

```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/dev"
  }
}
```

### Advanced Configuration

```hcl
terraform {
  backend "gcs" {
    bucket      = "terraform-state-gcp-nginx-lb"
    prefix      = "environments/dev"
    encryption_key = "projects/my-project/locations/global/keyRings/terraform/cryptoKeys/state"
    enable_bucket_policy_only = true
  }
}
```

### Environment-Specific Configuration

**Development Environment:**
```hcl
# environments/dev/main.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/dev"
  }
}
```

**Staging Environment:**
```hcl
# environments/staging/main.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/staging"
  }
}
```

**Production Environment:**
```hcl
# environments/production/main.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/production"
  }
}
```

## State File Structure

### GCS Bucket Structure

```
gs://terraform-state-gcp-nginx-lb/
├── environments/
│   ├── dev/
│   │   ├── default.tfstate
│   │   ├── default.tfstate.backup
│   │   └── .terraform.tfstate.lock.info
│   ├── staging/
│   │   ├── default.tfstate
│   │   ├── default.tfstate.backup
│   │   └── .terraform.tfstate.lock.info
│   └── production/
│       ├── default.tfstate
│       ├── default.tfstate.backup
│       └── .terraform.tfstate.lock.info
└── shared/
    ├── modules/
    └── components/
```

### State File Contents

```json
{
  "version": 4,
  "terraform_version": "1.5.0",
  "serial": 1,
  "lineage": "abc123-def456-ghi789",
  "outputs": {
    "vpc_id": {
      "value": "projects/my-project/global/networks/nginx-vpc-dev",
      "type": "string"
    }
  },
  "resources": [
    {
      "module": "module.networking",
      "mode": "managed",
      "type": "google_compute_network",
      "name": "vpc",
      "provider": "provider[\"registry.opentofu.org/hashicorp/google\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "projects/my-project/global/networks/nginx-vpc-dev",
            "name": "nginx-vpc-dev",
            "auto_create_subnetworks": false
          }
        }
      ]
    }
  ]
}
```

## State Locking

### How State Locking Works

1. **Lock Acquisition**: Terraform attempts to acquire a lock before modifying state
2. **State Reading**: Reads current state from GCS
3. **Plan Execution**: Applies changes to infrastructure
4. **State Writing**: Writes new state to GCS
5. **Lock Release**: Releases the lock for other operations

### Lock File Structure

```json
{
  "ID": "abc123-def456-ghi789",
  "Operation": "OperationTypeApply",
  "Info": "",
  "Who": "user@example.com",
  "Version": "1.5.0",
  "Created": "2025-07-24 17:30:00.000000000 +0000 UTC",
  "Path": "gs://terraform-state-gcp-nginx-lb/environments/dev/default.tfstate"
}
```

### Handling Lock Conflicts

**When someone else is running Terraform:**
```bash
Error: Error acquiring the state lock

# Wait for the other operation to complete, or force unlock (be careful!)
terraform force-unlock LOCK_ID
```

## Best Practices

### 1. Environment Separation

✅ **Separate state per environment**
```hcl
# Good: Each environment has its own state
prefix = "environments/dev"
prefix = "environments/staging"
prefix = "environments/production"
```

❌ **Don't share state between environments**
```hcl
# Bad: All environments share the same state
prefix = "shared"
```

### 2. State File Organization

✅ **Organized by environment and component**
```
gs://terraform-state-gcp-nginx-lb/
├── environments/
│   ├── dev/
│   │   ├── networking/
│   │   ├── compute/
│   │   └── dns/
│   ├── staging/
│   └── production/
└── shared/
    ├── modules/
    └── components/
```

### 3. Access Control

✅ **Use IAM roles for access control**
```bash
# Grant minimal required permissions
gsutil iam ch serviceAccount:terraform@my-project.iam.gserviceaccount.com:objectViewer,objectCreator gs://terraform-state-gcp-nginx-lb
```

### 4. State Backup

✅ **Enable versioning for automatic backup**
```bash
# Enable versioning on the state bucket
gsutil versioning set on gs://terraform-state-gcp-nginx-lb
```

### 5. Encryption

✅ **Use customer-managed encryption keys**
```hcl
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/dev"
    encryption_key = "projects/my-project/locations/global/keyRings/terraform/cryptoKeys/state"
  }
}
```

## Security Considerations

### 1. Service Account Permissions

**Required Roles:**
- `Storage Object Viewer` - Read state files
- `Storage Object Creator` - Create/update state files
- `Storage Object Admin` - Delete state files (for cleanup)

### 2. Network Security

**VPC Service Controls:**
```hcl
# Restrict access to state bucket from specific VPCs
resource "google_access_context_manager_access_level" "terraform_state" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.policy.name}/accessLevels/terraform_state"
  title  = "terraform_state"
  
  basic {
    conditions {
      vpc_network_sources {
        vpc_subnetwork {
          network = "//compute.googleapis.com/projects/my-project/global/networks/terraform-vpc"
        }
      }
    }
  }
}
```

### 3. Audit Logging

**Enable audit logs:**
```bash
# Enable audit logging for the state bucket
gsutil logging set -b gs://terraform-state-gcp-nginx-lb -l gs://terraform-state-gcp-nginx-lb/logs
```

## Troubleshooting

### Common Issues

**1. Permission Denied**
```bash
Error: Failed to get existing workspaces

# Solution: Grant proper IAM roles
gsutil iam ch serviceAccount:terraform@my-project.iam.gserviceaccount.com:objectViewer gs://terraform-state-gcp-nginx-lb
```

**2. Bucket Not Found**
```bash
Error: Failed to get existing workspaces

# Solution: Create the bucket
gsutil mb gs://terraform-state-gcp-nginx-lb
```

**3. State Lock Error**
```bash
Error: Error acquiring the state lock

# Solution: Wait or force unlock
terraform force-unlock LOCK_ID
```

**4. Authentication Error**
```bash
Error: storage.NewClient() failed: dialing: google: could not find default credentials

# Solution: Set up authentication
gcloud auth application-default login
```

### Debugging Commands

```bash
# Check state file location
terraform state pull

# List all resources in state
terraform state list

# Show specific resource
terraform state show google_compute_network.vpc

# Move resource in state
terraform state mv 'old_name' 'new_name'

# Remove resource from state
terraform state rm google_compute_network.vpc
```

## Migration Guide

### From Local to Remote State

**1. Initialize remote backend:**
```bash
terraform init -migrate-state
```

**2. Verify migration:**
```bash
terraform state pull
```

**3. Test remote state:**
```bash
terraform plan
```

### From Remote to Local State

**1. Download state:**
```bash
terraform state pull > local.tfstate
```

**2. Initialize local backend:**
```bash
# Comment out backend configuration
terraform init -backend=false
```

**3. Import local state:**
```bash
terraform state push local.tfstate
```

## Conclusion

Remote state in GCP provides a robust, secure, and scalable solution for managing Terraform state files. By following the best practices outlined in this guide, you can ensure your infrastructure state is properly managed, backed up, and accessible to your team while maintaining security and compliance requirements.

### Key Takeaways

- ✅ **Use separate state files per environment**
- ✅ **Enable versioning for automatic backup**
- ✅ **Implement proper access controls**
- ✅ **Use state locking to prevent conflicts**
- ✅ **Monitor and audit state changes**
- ✅ **Plan for disaster recovery**

For more information, refer to the [Terraform GCS Backend Documentation](https://developer.hashicorp.com/terraform/language/settings/backends/gcs). 