# GitHub Actions CI/CD for Terraform Infrastructure

## Table of Contents
- [Overview](#overview)
- [Why GitHub Actions?](#why-github-actions)
- [Current Project Architecture](#current-project-architecture)
- [Workflow Structure](#workflow-structure)
- [Environment Strategy](#environment-strategy)
- [Security & Compliance](#security--compliance)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Advanced Features](#advanced-features)

## Overview

This project uses GitHub Actions as the primary CI/CD tool for deploying Terraform infrastructure across multiple environments (dev, staging, production). The workflow integrates with AWX for application deployment, creating a complete infrastructure and application deployment pipeline.

## Why GitHub Actions?

### ✅ Advantages for This Project

| Advantage | Description |
|-----------|-------------|
| **Native GitHub Integration** | Seamless integration with your repository |
| **Free Tier** | 2000 minutes/month for private repos |
| **Terraform Support** | Official HashiCorp actions available |
| **Security Features** | Secrets management, branch protection |
| **Environment Management** | Built-in environment approvals |
| **AWX Integration** | Easy REST API calls to trigger AWX |
| **Cost Effective** | No additional infrastructure needed |

### 🆚 Comparison with Other Tools

| Tool | Pros | Cons |
|------|------|------|
| **GitHub Actions** | ✅ Native integration, free tier, easy setup | ❌ Limited to GitHub ecosystem |
| **GitLab CI/CD** | ✅ Advanced pipelines, built-in security | ❌ Requires GitLab migration |
| **Jenkins** | ✅ Highly customizable, enterprise features | ❌ Complex setup, maintenance overhead |
| **Azure DevOps** | ✅ Enterprise features, Microsoft ecosystem | ❌ Cost, vendor lock-in |

## Current Project Architecture

### Infrastructure Deployment Flow

```
Feature Branch → Dev → Staging → Production
     ↓           ↓        ↓         ↓
  GitHub    GitHub   GitHub   GitHub
  Actions   Actions  Actions  Actions
     ↓           ↓        ↓         ↓
  Terraform  Terraform Terraform Terraform
     ↓           ↓        ↓         ↓
    AWX        AWX       AWX       AWX
     ↓           ↓        ↓         ↓
  Application Application Application Application
```

### Repository Structure

```
terraform-infrastructure/
├── .github/
│   └── workflows/
│       ├── infrastructure-deployment.yml
│       ├── dev.yml
│       ├── staging.yml
│       └── production.yml
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── load-balancer/
│   └── dns/
└── docs/
    ├── remote-state-gcp.md
    └── github-actions-ci-cd.md
```

## Workflow Structure

### Main Infrastructure Deployment Workflow

```yaml
# .github/workflows/infrastructure-deployment.yml
name: Terraform Infrastructure Deployment

on:
  push:
    branches: [dev, staging, main]
  pull_request:
    branches: [dev, staging, main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
          - production

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Validate
        run: |
          cd environments/${{ github.ref_name }}
          terraform init -backend=false
          terraform validate

  plan:
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Configure GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}
      - name: Terraform Plan
        run: |
          cd environments/${{ github.ref_name }}
          terraform init
          terraform plan -out=tfplan

  deploy:
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'push' || github.event_name == 'workflow_dispatch'
    environment: ${{ github.event.inputs.environment || github.ref_name == 'main' && 'production' || github.ref_name }}
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Configure GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}
      - name: Terraform Apply
        run: |
          cd environments/${{ github.event.inputs.environment || github.ref_name }}
          terraform init
          terraform apply -auto-approve
      - name: Trigger AWX
        run: |
          curl -X POST ${{ secrets.AWX_WEBHOOK_URL }} \
            -H "Content-Type: application/json" \
            -d "{\"environment\": \"${{ github.event.inputs.environment || github.ref_name }}\"}"
```

### Environment-Specific Workflows

**Development Environment (Auto-deploy):**
```yaml
# .github/workflows/dev.yml
name: Dev Environment

on:
  push:
    branches: [dev]

jobs:
  deploy-dev:
    runs-on: ubuntu-latest
    environment: dev  # Auto-approval
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Configure GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_DEV_CREDENTIALS }}
      - name: Deploy Infrastructure
        run: |
          cd environments/dev
          terraform init
          terraform apply -auto-approve
      - name: Trigger AWX
        run: |
          curl -X POST ${{ secrets.AWX_WEBHOOK_URL }} \
            -H "Content-Type: application/json" \
            -d '{"environment": "dev"}'
```

**Staging Environment (Manual Approval):**
```yaml
# .github/workflows/staging.yml
name: Staging Environment

on:
  push:
    branches: [staging]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging  # Requires manual approval
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Configure GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_STAGING_CREDENTIALS }}
      - name: Deploy Infrastructure
        run: |
          cd environments/staging
          terraform init
          terraform apply -auto-approve
      - name: Trigger AWX
        run: |
          curl -X POST ${{ secrets.AWX_WEBHOOK_URL }} \
            -H "Content-Type: application/json" \
            -d '{"environment": "staging"}'
```

**Production Environment (Enhanced Security):**
```yaml
# .github/workflows/production.yml
name: Production Environment

on:
  push:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          format: sarif
          out: results.sarif
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif

  deploy-production:
    runs-on: ubuntu-latest
    needs: security-scan
    environment: production  # Requires manual approval + security review
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Configure GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_PROD_CREDENTIALS }}
      - name: Deploy Infrastructure
        run: |
          cd environments/production
          terraform init
          terraform apply -auto-approve
      - name: Trigger AWX
        run: |
          curl -X POST ${{ secrets.AWX_WEBHOOK_URL }} \
            -H "Content-Type: application/json" \
            -d '{"environment": "production"}'
      - name: Notify Success
        run: |
          curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
            -H "Content-Type: application/json" \
            -d '{"text": "Production infrastructure deployed successfully!"}'
```

## Environment Strategy

### Branch Protection Rules

**Development Branch (`dev`):**
```yaml
# Settings → Branches → Add rule for dev
✓ Require status checks to pass before merging
✓ Allow force pushes (for rapid development)
✓ Include administrators
```

**Staging Branch (`staging`):**
```yaml
# Settings → Branches → Add rule for staging
✓ Require a pull request before merging
✓ Require approvals: 1 reviewer
✓ Require status checks to pass before merging
✓ Require branches to be up to date before merging
```

**Production Branch (`main`):**
```yaml
# Settings → Branches → Add rule for main
✓ Require a pull request before merging
✓ Require approvals: 2 reviewers
✓ Dismiss stale PR approvals when new commits are pushed
✓ Require status checks to pass before merging
✓ Require branches to be up to date before merging
✓ Include administrators
✓ Restrict pushes that create files larger than 100 MB
```

### Environment Approvals

**GitHub Environments Setup:**
1. Go to Settings → Environments
2. Create: `dev`, `staging`, `production`
3. Configure protection rules:

**Dev Environment:**
- ✅ No restrictions (auto-approval)

**Staging Environment:**
- ✅ Required reviewers: 1
- ✅ Required status checks
- ✅ Restrict pushes

**Production Environment:**
- ✅ Required reviewers: 2
- ✅ Required status checks
- ✅ Restrict pushes
- ✅ Include administrators

## Security & Compliance

### Required GitHub Secrets

```bash
# GCP Credentials (per environment)
GCP_DEV_CREDENTIALS=your-dev-service-account-key
GCP_STAGING_CREDENTIALS=your-staging-service-account-key
GCP_PROD_CREDENTIALS=your-production-service-account-key

# AWX Integration
AWX_WEBHOOK_URL=https://your-awx-instance.com/api/v2/webhook_job_templates/123/
AWX_TOKEN=your-awx-api-token

# Notifications (optional)
SLACK_WEBHOOK=https://hooks.slack.com/services/your-webhook
```

### Security Scanning

**Terraform Security Scanning:**
```yaml
# .github/workflows/security-scan.yml
name: Security Scan

on:
  pull_request:
    branches: [main, staging]

jobs:
  tfsec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tfsec
        uses: aquasecurity/tfsec-action@v1.0.0
        with:
          format: sarif
          out: results.sarif
      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: results.sarif
```

**Checkov Security Scanning:**
```yaml
# .github/workflows/checkov.yml
name: Checkov Security Scan

on:
  pull_request:
    branches: [main, staging]

jobs:
  checkov:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: environments/
          framework: terraform
          output_format: sarif
          output_file: checkov.sarif
```

### Cost Estimation

```yaml
# .github/workflows/cost-estimate.yml
name: Cost Estimation

on:
  pull_request:
    branches: [main, staging]

jobs:
  cost:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Infracost
        uses: infracost/actions/comment@v1
        with:
          path: environments/
          token: ${{ secrets.INFRACOST_TOKEN }}
```

## Best Practices

### 1. Workflow Organization

✅ **Separate workflows per environment**
✅ **Reusable workflow components**
✅ **Clear naming conventions**
✅ **Proper error handling**

### 2. Security

✅ **Use environment secrets**
✅ **Implement branch protection**
✅ **Enable security scanning**
✅ **Audit all changes**

### 3. Performance

✅ **Cache Terraform providers**
✅ **Use matrix builds for multiple environments**
✅ **Optimize workflow steps**
✅ **Monitor execution times**

### 4. Monitoring

✅ **Set up notifications**
✅ **Track deployment metrics**
✅ **Monitor costs**
✅ **Log all activities**

## Troubleshooting

### Common Issues

**1. Authentication Errors**
```bash
Error: storage.NewClient() failed: dialing: google: could not find default credentials

# Solution: Check GCP credentials in secrets
# Verify service account has proper permissions
```

**2. State Lock Errors**
```bash
Error: Error acquiring the state lock

# Solution: Wait for other operations to complete
# Or force unlock if necessary (be careful!)
```

**3. AWX Integration Failures**
```bash
Error: Failed to trigger AWX job

# Solution: Check AWX webhook URL and token
# Verify AWX job template exists
```

**4. Workflow Failures**
```bash
Error: Workflow failed

# Solution: Check logs in GitHub Actions
# Verify all required secrets are set
```

### Debugging Commands

```bash
# Check workflow status
gh run list

# View workflow logs
gh run view RUN_ID

# Re-run failed workflow
gh run rerun RUN_ID

# Download workflow artifacts
gh run download RUN_ID
```

## Advanced Features

### 1. Manual Deployment

**Workflow Dispatch:**
```yaml
# Trigger manual deployment from GitHub UI
workflow_dispatch:
  inputs:
    environment:
      description: 'Environment to deploy'
      required: true
      default: 'dev'
      type: choice
      options:
        - dev
        - staging
        - production
```

### 2. Rollback Capability

```yaml
# .github/workflows/rollback.yml
name: Infrastructure Rollback

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to rollback'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
          - production

jobs:
  rollback:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
      - uses: actions/checkout@v3
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Configure GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}
      - name: Rollback Infrastructure
        run: |
          cd environments/${{ github.event.inputs.environment }}
          terraform init
          terraform destroy -auto-approve
```

### 3. Multi-Environment Deployment

```yaml
# Deploy to multiple environments simultaneously
jobs:
  deploy-environments:
    strategy:
      matrix:
        environment: [dev, staging]
    runs-on: ubuntu-latest
    environment: ${{ matrix.environment }}
    
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to ${{ matrix.environment }}
        run: |
          cd environments/${{ matrix.environment }}
          terraform init
          terraform apply -auto-approve
```

## Conclusion

GitHub Actions provides an excellent CI/CD solution for this Terraform infrastructure project. The combination of native GitHub integration, robust security features, and seamless AWX integration creates a powerful deployment pipeline.

### Key Benefits

- ✅ **Native GitHub Integration** - No additional infrastructure needed
- ✅ **Security First** - Built-in secrets management and branch protection
- ✅ **Environment Management** - Proper approval workflows per environment
- ✅ **AWX Integration** - Complete infrastructure and application deployment
- ✅ **Cost Effective** - Free tier covers most use cases
- ✅ **Scalable** - Easy to add new environments and workflows

### Next Steps

1. **Set up GitHub Secrets** with your GCP credentials
2. **Configure Environments** with proper protection rules
3. **Test the Workflows** with a development deployment
4. **Monitor and Optimize** based on usage patterns

For more information, refer to the [GitHub Actions Documentation](https://docs.github.com/en/actions) and [Terraform GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions). 