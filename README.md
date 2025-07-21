# EKS Cluster Infrastructure Deployment with GitOps, CI/CD, Security, and Monitoring

## Overview  
This project provisions a production-grade Kubernetes cluster on AWS using EKS (Elastic Kubernetes Service) to deploy and manage a Flask-based web application. The app was hosted at `app.argocd.isaiahmichael.com` and included multiple endpoints such as `/deployment`, `/api`, and `/health`.

The infrastructure was built using Terraform, GitHub Actions, and ArgoCD for GitOps-based deployment. It includes automated TLS certificates, DNS management, RBAC access control, and a full observability stack using Prometheus and Grafana.

The goal was to build a secure, scalable, and fully automated environment that reflects real-world DevOps workflows used in production teams.

> **Note:** The live application is now decommissioned. Screenshots and configuration files serve as evidence of functionality.  
> Source code available at: [github.com/isaiah1701/k8-eks](https://github.com/isaiah1701/k8-eks)



---

## Key Features

- Amazon EKS  
  A fully managed Kubernetes platform on AWS ☁️, used here to run the web application with built-in scaling, high availability, and native AWS service integration.

- Terraform Infrastructure as Code  
  Modular Terraform code 📦 provisions all infrastructure components — including VPC, IAM roles, EKS cluster — with remote state stored in S3 and locking via DynamoDB.

- CI/CD Pipelines  
  - Pipeline 1 validates, plans, and applies Terraform configurations with automated error handling ⚙️.  
  - Pipeline 2 handles:
    - Checkov 🔍 for static analysis of Terraform security and compliance.
    - Docker image builds 🛠️ and publishing to Amazon ECR.
    - Trivy 🧪 to scan images for vulnerabilities.
    - Deployment to EKS using Kubernetes manifests 🚀.

- GitOps with ArgoCD  
  ArgoCD syncs application state from Git to the cluster 🔁. This powers consistent, version-controlled updates to the website with no manual intervention.

- Helm Charts  
  Used to install and configure Kubernetes tools like ArgoCD, Cert-Manager, Prometheus, and Grafana 🧩 — making the environment easy to reproduce.

- Cert-Manager  
  Handles HTTPS certificate issuance and renewal automatically 🔐 via Let’s Encrypt, securing public-facing services without manual effort.

- ExternalDNS  
  Automatically manages DNS records in AWS Route 53 🌍 based on Kubernetes ingress resources — keeping domain routing up to date during deployments.

- Prometheus and Grafana  
  Delivers observability 📊 with real-time metrics collection and dashboards tracking pod health, resource usage, and system performance.

- RBAC (Role-Based Access Control)  
  Access to the cluster is restricted 🛡️ using namespace-level and cluster-wide permissions, following least privilege principles.

---



# Architecture 

## System Overview
![System Architecture](images/architectureDiagramEKS.png)

The overall architecture shows the complete EKS deployment with GitOps, monitoring, and security components integrated across AWS services.

## Component Diagrams

### ArgoCD GitOps Management
![ArgoCD Architecture](images/argocdDiagramEKS.png)
Illustrates how ArgoCD manages application deployments through Git-based workflows, automatically syncing repository changes to the EKS cluster.

### Application Website & Components
![App Architecture](images/app.argocdDiagramEKS.png)
Shows the main Flask application architecture hosted at app.argocd.isaiahmichael.com with its various components and microservices.

![Component Architecture](images/component.app.argocdDiagramEKS.png)
Details the individual components that make up the application stack, including backend services, databases, and API endpoints.

### Application Deployment Pipeline
![Deployment Flow](images/deployment.app.argocdDiagramEKS.png)
Shows the CI/CD pipeline flow from code commit through security scanning, Docker image building, and Kubernetes deployment for the Flask application and its subdomains (/deployment, /api, etc.).

### Monitoring Infrastructure

![Grafana Dashboard](images/grafanaDiagramEKS.png)
Displays the monitoring architecture with Grafana providing real-time dashboards for application and infrastructure metrics collected by Prometheus.

![Prometheus Architecture](images/prometheusDiagramEKS.png)
Shows how Prometheus scrapes metrics from various Kubernetes components, the Flask application, and infrastructure to provide comprehensive observability.

### Application Architecture & Infrastructure
![App Infrastructure](images/architecture.app.argocdDiagramEKS.png)
Comprehensive view of how the Flask application integrates with the EKS infrastructure, including load balancers, ingress controllers, and backend services.

### Key Architectural Components

**Control Plane (AWS Managed)**
- EKS master nodes managed by AWS
- API server, etcd, scheduler, and controller manager

**Data Plane (Customer Managed)**
- EC2 worker nodes in private subnets
- Flask application pods and system components
- Load balancers and ingress controllers

**Application Layer**
- Flask web application at app.argocd.isaiahmichael.com
- Multiple endpoints and subdomains (/deployment, /api, /health)
- Docker containerized microservices

**GitOps Layer**
- ArgoCD for declarative deployments
- Git repositories as single source of truth
- Automated synchronization and rollback capabilities

**Security & Access**
- IAM roles and service accounts (IRSA)
- RBAC for fine-grained permissions
- Network policies and security groups

**Observability Stack**
- Prometheus for metrics collection from Flask app and infrastructure
- Grafana for visualization and application monitoring
- Centralized logging and performance tracking

**Automation & DNS**
- Cert-Manager for automatic SSL/TLS certificates
- ExternalDNS for dynamic DNS record management
- Helm for package management and application deployments

# Why This Setup Adds Real Value in a Production Environment

ArgoCD for Reliable, Versioned Deployments  
ArgoCD enables consistent, auditable deployments directly from Git. It reduces manual errors, supports rollback, and fits cleanly into CI/CD workflows for team-based delivery.

EKS for Scalability and AWS Integration  
Using Amazon EKS provides a managed, production-grade Kubernetes environment. It handles scaling and availability out of the box, while integrating with other AWS services like IAM, VPC, and CloudWatch.

HTTPS and Access Control Built In  
Cert-Manager automates certificate management using Let’s Encrypt, removing the need for manual renewal or provisioning. RBAC is used to control access at both the namespace and cluster level.

CI/CD Pipelines with Security Checks  
Pipelines are set up to:
- Scan Terraform code with Checkov for misconfigurations  
- Build and push Docker images to ECR  
- Scan those images with Trivy before deployment  
- Deploy to EKS via Kubernetes manifests  
This approach helps catch security issues early and keeps deployments consistent.

Automated DNS with ExternalDNS  
ExternalDNS integrates with Route 53 to update DNS records automatically based on Kubernetes ingress changes. It removes the need for manual updates and speeds up deployments.

Monitoring with Prometheus and Grafana  
Prometheus collects application and infrastructure metrics, and Grafana displays them in real-time dashboards. This makes it easier to track performance and catch issues before they impact users.



# Infrastructure Components
VPC (Virtual Private Cloud): Provides a secure, isolated network environment for the cluster .
EKS (Elastic Kubernetes Service): Manages the Kubernetes control plane and worker nodes.
ArgoCD: Manages application deployments based on Git repositories.
Helm: Deploys and manages Kubernetes resources using Helm charts.
Cert-Manager: Handles SSL/TLS certificate issuance and renewal.
ExternalDNS: Automates DNS record updates in AWS Route 53.


# CI/CD Pipeline Architecture

This project implements two complementary GitHub Actions workflows that automate infrastructure provisioning, security scanning, and application deployment.

## Pipeline 1: Infrastructure Validation & Deployment
**File:** `.github/workflows/terraformValidate.yaml`

### What it does:
This pipeline handles the **infrastructure layer** - creating and managing your EKS cluster and AWS resources.

### Workflow Steps:
1. **Security Scanning with Checkov** 🔍
   - Scans Terraform code for misconfigurations and security violations
   - Checks for AWS best practices (encrypted storage, proper IAM, etc.)
   - **Continues deployment even if issues found** (warnings only)

2. **Terraform Infrastructure Management** 🏗️
   - **Validates** Terraform syntax and configuration
   - **Plans** changes to show what will be created/modified
   - **Applies** changes to provision EKS cluster, VPC, IAM roles, etc.
   - Uses **S3 backend** for state management with **DynamoDB locking**

3. **Error Handling** ⚠️
   - Gracefully handles existing resources
   - Continues workflow even if some steps fail
   - Provides detailed status summaries

### Triggers:
- Pushes to `main` or `addCICD` branches
- Changes to any Terraform files

---

## Pipeline 2: Application Build & Deployment
**File:** `.github/workflows/dockerDeploy.yaml`

### What it does:
This pipeline handles the **application layer** - building, scanning, and deploying your Flask web application.

### Workflow Steps:
1. **Docker Image Build** 🐳
   - Builds Docker image from `dockerFolder/`
   - Tags with commit SHA for version tracking
   - Pushes to **Amazon ECR** (Elastic Container Registry)

2. **Security Scanning with Trivy** 🧪
   - Scans Docker images for vulnerabilities
   - Checks for known CVEs in dependencies
   - Reports **CRITICAL, HIGH, MEDIUM, LOW** severity issues
   - **Never blocks deployment** (security awareness, not gates)

3. **Kubernetes Deployment** 🚀
   - Updates Kubernetes manifests with new image tag
   - Applies manifests directly to EKS cluster
   - Forces pod restart to pull new image
   - Waits for successful rollout

### Triggers:
- Pushes to `main` branch
- **Only when files in `dockerFolder/` change**

---

## Pipeline Integration Flow

```mermaid
graph TD
    A[Code Push] --> B{Which Files Changed?}
    B -->|Terraform Files| C[Pipeline 1: Infrastructure]
    B -->|dockerFolder Files| D[Pipeline 2: Application]
    
    C --> E[Checkov Scan]
    E --> F[Terraform Apply]
    F --> G[EKS Cluster Ready]
    
    D --> H[Build Docker Image]
    H --> I[Trivy Security Scan]
    I --> J[Deploy to EKS]
    J --> K[App Live at app.argocd.isaiahmichael.com]
```

## Key Pipeline Features

### Security-First Approach 🔒
- **Checkov** scans infrastructure code for AWS security best practices
- **Trivy** scans container images for known vulnerabilities
- Both tools provide **warnings without blocking** deployment

### Automated State Management 📊
- Terraform state stored in **S3** with **DynamoDB locking**
- Prevents concurrent modifications and state corruption
- Enables team collaboration on infrastructure

### Direct Deployment (Not GitOps) ⚡
- Pipeline 2 uses **direct kubectl deployment**
- Updates manifests and applies immediately
- **Note:** This bypasses ArgoCD - could be converted to GitOps by committing manifest changes instead

### Environment Isolation 🏗️
- Each pipeline has specific triggers and permissions
- Infrastructure and application deployments are independent
- Supports different development workflows

### Production Considerations 🚀
In a production environment, you might want to:
- Convert Pipeline 2 to GitOps (commit manifest changes for ArgoCD to sync)
- Add approval gates for production deployments
- Implement vulnerability thresholds that block deployment
- Add comprehensive testing stages

This dual-pipeline approach provides **infrastructure-as-code automation** with **continuous application deployment**, while maintaining security visibility throughout the process.


## Future Improvements
- Convert app deployment pipeline to full GitOps model (ArgoCD-based sync)
- Add unit/integration testing stage in CI/CD
- Set up centralized logging with Loki or ELK stack
- Implement autoscaling and multi-AZ node groups for full HA


# Setup Instructions

## Prerequisites
- AWS CLI configured with appropriate permissions
- kubectl installed
- Helm 3.x installed
- Terraform installed
- Valid domain name with Cloudflare DNS management

---

## 1. Repository Setup

```bash
git clone [repo-url]
cd k8s-advanced-lab
```

## 2. Infrastructure Provisioning

```bash
# Initialize and apply Terraform configuration
terraform init
terraform plan
terraform apply

# Configure kubectl to connect to your new cluster
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify cluster connectivity
kubectl get nodes
```

## 3. ArgoCD Installation

```bash
# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD with custom configuration
kubectl create namespace argo-cd
helm install argocd argo/argo-cd \
  --namespace argo-cd \
  --values helm-values/argocd.yaml

# Get initial admin password
kubectl -n argo-cd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## 4. Certificate Management

```bash
# Install cert-manager for automatic SSL certificates
helm repo add jetstack https://charts.jetstack.io
helm repo update

kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --values helm-values/cert-manager.yaml \
  --set crds.enabled=true

# Configure Let's Encrypt certificate issuer
kubectl apply -f helm-values/letsencrypt-clusterissuer.yaml

# Verify installation
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s
kubectl get clusterissuer letsencrypt-prod
```

## 5. Monitoring Stack

```bash
# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values helm-values/prometheus.yaml

# Configure ingress for external access
kubectl apply -f apps/monitoring-ingress.yaml

# Verify deployment
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
kubectl get certificates -n monitoring
```

## 6. DNS Automation

```bash
# Install ExternalDNS for automatic DNS record management
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

kubectl create namespace external-dns
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  --values helm-values/external-dns.yaml

# Verify DNS automation is working
kubectl logs -n external-dns deployment/external-dns --tail=20
```

---

## Verification & Access

Once all components are deployed, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **ArgoCD** | https://argocd.isaiahmichael.com | admin / [password from step 3] |
| **Grafana** | https://grafana.argocd.isaiahmichael.com | admin / admin123 |
| **Prometheus** | https://prometheus.argocd.isaiahmichael.com | - |

### Health Checks

```bash
# Verify all pods are running
kubectl get pods --all-namespaces

# Check certificate status
kubectl get certificates --all-namespaces

# Verify ingress configurations
kubectl get ingress --all-namespaces
```

---

## Cleanup

To tear down the entire infrastructure:

```bash
# Remove Kubernetes resources first
helm uninstall external-dns -n external-dns
helm uninstall monitoring -n monitoring
helm uninstall cert-manager -n cert-manager
helm uninstall argocd -n argo-cd

# Destroy AWS infrastructure
terraform destroy
```

---

## Troubleshooting

**Common Issues:**

- **Certificate not ready**: Wait 2-3 minutes for Let's Encrypt validation
- **DNS records not created**: Verify Cloudflare API token permissions
- **Pod startup failures**: Check resource limits and node capacity
- **Access denied**: Verify RBAC configuration and AWS IAM permissions

**Useful Commands:**

```bash
# Check pod logs
kubectl logs -f <pod-name> -n <namespace>

# Describe resources for troubleshooting
kubectl describe <resource-type> <resource-name> -n <namespace>

# Check cluster events
kubectl get events --sort-by='.lastTimestamp' -A
```

## Incident Response & Postmortem

### Summary
On **2025-06-13 at 19:00 UTC**, the website became completely unavailable to end users due to a DNS resolution failure caused by misconfiguration of the ExternalDNS service in the EKS cluster. The incident was detected via alerting and resolved after approximately 15 minutes by correcting the Cloudflare API token in the ExternalDNS deployment configuration.

### Impact
- Website returned HTTP **502 Backend Error** for all endpoints during the incident window.
- No users were able to access the website during this time.
- Availability SLOs were violated (specific SLOs not yet defined).
- No data loss occurred.

### Timeline
| Time (UTC) | Event |
|------------|-------|
| 19:00      | Alert triggered: website unavailable |
| 19:05      | Investigated: ExternalDNS pod observed running via `kubectl describe pod` |
| 19:07      | Checked logs of ExternalDNS pod: no errors observed |
| 19:10      | Determined Cloudflare API key was missing from ExternalDNS manifest |
| 19:12      | Applied updated `external-dns.yaml` with correct API key |
| 19:15      | DNS records updated and service restored |

### Root Cause Analysis
- HTTP 502 errors occurred because backend service endpoints were unreachable via DNS.
- DNS resolution failed because ExternalDNS was not updating DNS records in Cloudflare.
- ExternalDNS failed because the required Cloudflare API token was not configured.
- No automated validation caught the missing token before deployment.

### Mitigation & Recovery
- Updated `external-dns.yaml` manifest to include the correct Cloudflare API token.
- Applied manifest to the cluster, triggering ExternalDNS to update records.
- Monitored endpoints until DNS records propagated and service became reachable.

### Action Items & Lessons Learned
- Define and document clear availability SLOs for the service.
- Implement automated checks (e.g., CI pipeline lint or pre-deploy hook) to verify required secrets are present.
- Store and reference the Cloudflare API token securely as a Kubernetes Secret in manifests.
- Create a deployment checklist for EKS covering critical configuration items such as DNS credentials.

