# Migration Guide: From Separate Repositories to Monorepo

## **🔄 Migration Overview**

This guide helps you migrate from the current separate repository structure to the recommended monorepo approach.

### **Current Structure (Separate Repositories)**
```
gcp-nginx-lb-dev/          # Separate repo for dev
├── environments/dev/
└── modules/

gcp-nginx-lb-prod/          # Separate repo for prod
├── environments/prod/
└── modules/
```

### **New Structure (Monorepo)**
```
terraform-infrastructure/    # Single monorepo
├── environments/
│   ├── dev/               # develop branch
│   ├── staging/           # staging branch
│   └── production/        # main branch
├── modules/               # Shared across environments
└── .github/workflows/
```

## **📋 Migration Steps**

### **Step 1: Create New Monorepo Repository**

```bash
# Create new repository on GitHub/GitLab
# Name: terraform-infrastructure
# Description: Terraform infrastructure for GCP NGINX load balancer
```

### **Step 2: Clone and Set Up New Repository**

```bash
# Clone the new repository
git clone <new-repo-url>
cd terraform-infrastructure

# Create the directory structure
mkdir -p environments/{dev,staging,production}
mkdir -p modules/{networking,compute,load-balancer,dns}
mkdir -p .github/workflows
mkdir -p docs
```

### **Step 3: Copy Modules from Existing Repositories**

```bash
# Copy modules from dev repository
cp -r ../gcp-nginx-lb-dev/modules/* modules/

# Verify modules are identical
diff -r ../gcp-nginx-lb-dev/modules/ ../gcp-nginx-lb-prod/modules/
```

### **Step 4: Set Up Environment Configurations**

```bash
# Copy dev environment
cp -r ../gcp-nginx-lb-dev/environments/dev/* environments/dev/

# Copy prod environment as production
cp -r ../gcp-nginx-lb-prod/environments/prod/* environments/production/

# Create staging environment (copy from dev and modify)
cp -r environments/dev/* environments/staging/
```

### **Step 5: Update Environment-Specific Configurations**

#### **Dev Environment (develop branch)**
```terraform
# environments/dev/terraform.tfvars
project_id = "your-dev-project-id"
nginx_machine_type = "e2-micro"
nginx_instance_count = 2
```

#### **Staging Environment (staging branch)**
```terraform
# environments/staging/terraform.tfvars
project_id = "your-staging-project-id"
nginx_machine_type = "e2-small"
nginx_instance_count = 3
```

#### **Production Environment (main branch)**
```terraform
# environments/production/terraform.tfvars
project_id = "your-prod-project-id"
nginx_machine_type = "e2-standard-2"
nginx_instance_count = 5
```

### **Step 6: Set Up Branching Strategy**

```bash
# Create main branch (production)
git checkout -b main
git add .
git commit -m "Initial monorepo setup"
git push origin main

# Create develop branch (dev environment)
git checkout -b develop
git push origin develop

# Create staging branch
git checkout -b staging
git push origin staging
```

### **Step 7: Configure Remote State**

#### **Update Backend Configuration**
```terraform
# environments/dev/main.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/dev"
  }
}

# environments/staging/main.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/staging"
  }
}

# environments/production/main.tf
terraform {
  backend "gcs" {
    bucket = "terraform-state-gcp-nginx-lb"
    prefix = "environments/production"
  }
}
```

### **Step 8: Set Up CI/CD Pipelines**

#### **Copy Existing Workflows**
```bash
cp ../gcp-nginx-lb-dev/.github/workflows/* .github/workflows/
```

#### **Update Workflow Triggers**
```yaml
# .github/workflows/terraform-dev.yml
on:
  push:
    branches: [ develop ]
    paths:
      - 'environments/dev/**'
      - 'modules/**'

# .github/workflows/terraform-production.yml
on:
  push:
    branches: [ main ]
    paths:
      - 'environments/production/**'
      - 'modules/**'
```

### **Step 9: Migrate Existing State**

#### **Backup Current State**
```bash
# Backup dev state
cd ../gcp-nginx-lb-dev/environments/dev
terraform state pull > dev-state-backup.tfstate

# Backup prod state
cd ../gcp-nginx-lb-prod/environments/prod
terraform state pull > prod-state-backup.tfstate
```

#### **Migrate State to New Structure**
```bash
# Initialize new environments
cd terraform-infrastructure/environments/dev
terraform init -migrate-state

cd ../staging
terraform init

cd ../production
terraform init -migrate-state
```

### **Step 10: Update Team Workflows**

#### **Development Workflow**
```bash
# Feature development
git checkout develop
git checkout -b feature/new-feature
# Make changes
git push origin feature/new-feature
# Create PR to develop
```

#### **Staging Deployment**
```bash
# Promote to staging
git checkout staging
git merge develop
git push origin staging
# CI/CD deploys to staging
```

#### **Production Deployment**
```bash
# Promote to production
git checkout main
git merge staging
git push origin main
# CI/CD deploys to production (with approval)
```

## **🔧 Configuration Changes**

### **Environment-Specific Settings**

#### **Dev Environment**
- **Project**: `dev-project`
- **Instance Type**: `e2-micro`
- **Instance Count**: 2
- **Network**: `nginx-vpc-dev`
- **DNS Zone**: `test-internal-zone-dev`

#### **Staging Environment**
- **Project**: `staging-project`
- **Instance Type**: `e2-small`
- **Instance Count**: 3
- **Network**: `nginx-vpc-staging`
- **DNS Zone**: `test-internal-zone-staging`

#### **Production Environment**
- **Project**: `prod-project`
- **Instance Type**: `e2-standard-2`
- **Instance Count**: 5
- **Network**: `nginx-vpc-prod`
- **DNS Zone**: `test-internal-zone-prod`

### **State File Organization**
```
gs://terraform-state-gcp-nginx-lb/
├── environments/
│   ├── dev/terraform.tfstate
│   ├── staging/terraform.tfstate
│   └── production/terraform.tfstate
```

## **✅ Benefits After Migration**

### **✅ Improved Collaboration**
- **Single source of truth** for all infrastructure
- **Shared modules** across environments
- **Consistent structure** and practices

### **✅ Better Deployment Process**
- **Clear promotion path**: Dev → Staging → Production
- **Environment isolation** with separate state files
- **Automated CI/CD** with approval gates

### **✅ Enhanced Security**
- **Manual approval** for production deployments
- **Security scanning** integrated into pipelines
- **Audit trail** for all changes

### **✅ Easier Maintenance**
- **No code duplication** between environments
- **Centralized documentation**
- **Simplified module updates**

## **🔄 Rollback Plan**

### **If Migration Fails**
```bash
# Revert to separate repositories
git clone <old-dev-repo>
git clone <old-prod-repo>

# Restore state from backups
terraform state push dev-state-backup.tfstate
terraform state push prod-state-backup.tfstate
```

### **Emergency Rollback**
```bash
# Revert to previous commit
git revert HEAD
git push origin main

# Or restore from backup
terraform state push backup.tfstate
terraform apply
```

## **📋 Migration Checklist**

### **Pre-Migration**
- [ ] Backup current state files
- [ ] Document current configurations
- [ ] Notify team about migration
- [ ] Schedule maintenance window

### **During Migration**
- [ ] Create new monorepo repository
- [ ] Copy and verify modules
- [ ] Set up environment configurations
- [ ] Configure remote state
- [ ] Set up CI/CD pipelines
- [ ] Test deployments in each environment

### **Post-Migration**
- [ ] Verify all environments are working
- [ ] Update team documentation
- [ ] Train team on new workflow
- [ ] Archive old repositories
- [ ] Monitor deployments for issues

## **🎯 Success Criteria**

- ✅ **All environments deploy successfully**
- ✅ **CI/CD pipelines work correctly**
- ✅ **Team can use new workflow**
- ✅ **No downtime during migration**
- ✅ **All functionality preserved**

This migration provides a **more scalable, maintainable, and secure** infrastructure management approach while preserving all existing functionality. 