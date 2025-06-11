# EKS Cluster Deployment with GitOps, CI/CD, Security Scans, and Monitoring

## Overview  
This project delivers a production-ready EKS (Elastic Kubernetes Service) setup on AWS, emphasizing automation, security 🔒, and observability 📊. It combines GitOps workflows, secure CI/CD pipelines, infrastructure as code, and full monitoring.

Key components include GitOps with ArgoCD 🔁, Docker-based deployments to EKS 🐳, automated certificate and DNS management 🌐, and real-time monitoring with Prometheus and Grafana 📈. CI/CD pipelines are used to scan infrastructure and container images for security issues, build Docker images, and deploy applications to Kubernetes automatically.

This end-to-end setup reflects real-world production infrastructure aligned with modern DevOps best practices ✅.

## Key Features

- Amazon EKS  
  Fully managed Kubernetes service used to run containerized applications at scale ☁️ with built-in AWS integration, high availability, and auto-scaling.

- Terraform Infrastructure as Code  
  Modular and reusable Terraform code 📦 provisions the VPC, EKS cluster, IAM roles, and state management via S3 and DynamoDB for safe and repeatable deployments.

- CI/CD Pipelines  
  - Pipeline 1 automates Terraform validation, planning, and application with error handling ⚙️.
  - Pipeline 2 includes:
    - Checkov 🔍 scans for Terraform misconfigurations and security violations.
    - Docker image builds 🛠️ and pushes to Amazon ECR.
    - Trivy scans 🧪 for vulnerabilities in Docker containers.
    - Kubernetes deployment to EKS using manifests 🚀.

- ArgoCD (GitOps)  
  Automatically syncs application state from Git repositories to the EKS cluster, enabling declarative, version-controlled deployments 🔁.

- Helm Charts  
  Used for streamlined deployment and configuration of Kubernetes tools like ArgoCD, Prometheus, Grafana, and Cert-Manager 🧩.

- Cert-Manager  
  Issues and renews TLS/SSL certificates using Let’s Encrypt 🔐 and ACME protocols to ensure encrypted traffic across services.

- ExternalDNS  
  Dynamically updates Route 53 DNS records 🌍 based on Kubernetes ingress and service resources, reducing manual configuration effort.

- Prometheus and Grafana  
  Provides metrics scraping, alerting, and rich real-time dashboarding 📊 to monitor application health and infrastructure performance.



# Why This Setup Is Production-Ready
Streamlined GitOps with ArgoCD: I optimized deployments using ArgoCD to ensure every change is version-controlled, auditable, and automatically synced from Git—perfect for teams and CI/CD pipelines.

Scalable Architecture on EKS: The setup leverages Amazon EKS to handle workload scaling, high availability, and seamless AWS integration, making it ideal for production environments.

Built-in HTTPS Security: I integrated Cert-Manager to automate TLS certificate issuance and renewal, ensuring secure, encrypted traffic across all services with zero manual intervention.

Hands-Off DNS Automation: ExternalDNS automatically updates Route 53 records based on Kubernetes ingress changes, removing manual DNS management and reducing deployment friction.

Monitoring & Observability: I added Prometheus and Grafana to track application metrics, monitor cluster health, and create alerts—giving full visibility and control over the infrastructure.


# Infrastructure Components
VPC (Virtual Private Cloud): Provides a secure, isolated network environment for the cluster .
EKS (Elastic Kubernetes Service): Manages the Kubernetes control plane and worker nodes.
ArgoCD: Manages application deployments based on Git repositories.
Helm: Deploys and manages Kubernetes resources using Helm charts.
Cert-Manager: Handles SSL/TLS certificate issuance and renewal.
ExternalDNS: Automates DNS record updates in AWS Route 53.


# Setup instructions 

1. Clone the Repository
git clone [repo-url]
cd [repo-directory]

 2. Provision EKS Cluster with Terraform
terraform init
terraform plan
terraform apply


3. Configure kubectl
aws eks --region <region> update-kubeconfig --name <cluster-name>
kubectl get nodes


4. Configure argocd via helm
Add the ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

Install ArgoCD using your values file
helm install argocd argo/argo-cd \
  --namespace argo-cd \
  --values helm-values/argocd.yaml



5. Install cert-manager

```bash
# Create cert-manager namespace
kubectl create namespace cert-manager

# Add cert-manager Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager with CRDs
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --values helm-values/cert-manager.yaml \
  --set crds.enabled=true

# Wait for cert-manager pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s

# Create Let's Encrypt cluster issuer
kubectl apply -f helm-values/letsencrypt-clusterissuer.yaml

# Verify installation
kubectl get pods -n cert-manager
kubectl get clusterissuer letsencrypt-prod
```

**Expected output:**
- All cert-manager pods should be `Running`
- ClusterIssuer should show `READY: True`

**Get ArgoCD admin password:**
```bash
kubectl -n argo-cd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
```

**Access your applications:**
- ArgoCD: https://argocd.isaiahmichael.com (admin / password-from-above)
- Certificates will be automatically issued for all ingresses!

5. Install Prometheus and Grafana

```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus and Grafana stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values helm-values/prometheus.yaml

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s

# Apply ingresses for external access
kubectl apply -f apps/monitoring-ingress.yaml

# Verify installation
kubectl get pods -n monitoring
kubectl get ingresses -n monitoring
kubectl get certificates -n monitoring
```

**Expected output:**
- All monitoring pods should be `Running`
- Ingresses should have ADDRESS assigned
- Certificates should show `READY: True`

**Access your monitoring:**
- Grafana: https://grafana.argocd.isaiahmichael.com
  - Username: `admin`
  - Password: `admin123` (from your prometheus.yaml config)
- Prometheus: https://prometheus.argocd.isaiahmichael.com

**Verify certificates are working:**
```bash
# Check certificate status
kubectl get certificates -n monitoring

# Should show:
# grafana-tls      True    grafana-tls      
# prometheus-tls   True    prometheus-tls   
```
6. Install cert-manager

```bash
# Create cert-manager namespace
kubectl create namespace cert-manager

# Add cert-manager Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager with CRDs
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --values helm-values/cert-manager.yaml \
  --set crds.enabled=true

# Wait for cert-manager pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s

# Create Let's Encrypt cluster issuer
kubectl apply -f helm-values/letsencrypt-clusterissuer.yaml

# Verify installation
kubectl get pods -n cert-manager
kubectl get clusterissuer letsencrypt-prod
```

**Expected output:**
- All cert-manager pods should be `Running`
- ClusterIssuer should show `READY: True`

**Get ArgoCD admin password:**
```bash
kubectl -n argo-cd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo
```

**Access your applications:**
- ArgoCD: https://argocd.isaiahmichael.com (admin / password-from-above)
- Certificates will be automatically issued for all ingresses!


7. Install ExternalDNS

```bash
# Create external-dns namespace
kubectl create namespace external-dns

# Add ExternalDNS Helm repository
helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm repo update

# Install ExternalDNS for Cloudflare
helm install external-dns external-dns/external-dns \
  --namespace external-dns \
  --values helm-values/external-dns.yaml

# Verify installation
kubectl get pods -n external-dns
kubectl logs -n external-dns deployment/external-dns --tail=20
```

**Expected output:**
- ExternalDNS pod should be `Running`
- Logs should show DNS records being created/updated

**Result:** All ingresses will automatically get DNS records in Cloudflare! 🌐 
**Note:**  A cloudflare API key is required for External DNS via Cloudflare!



8. Clean up resources 

```bash

terraform destroy
```





























































