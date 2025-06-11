# 🛠️ EKS Cluster Deployment with ArgoCD, Helm Charts, Cert-Manager, and ExternalDNS with Prometheus and Grafana monitoring 

# Overview
This project focuses on deploying a production-grade EKS (Elastic Kubernetes Service) cluster on AWS. It integrates essential Kubernetes tools like ArgoCD for GitOps, Helm Charts for app deployment, Cert-Manager for HTTPS, and ExternalDNS for automatic DNS updates. Monitoring is handled with Prometheus and Grafana to ensure visibility and performance tracking. The result is a secure, scalable, and fully automated infrastructure that follows modern DevOps best practices.
 

# Key Features
Amazon EKS: Managed Kubernetes service for running containerized applications at scale with high availability, security, and seamless AWS integration.
ArgoCD: Declarative GitOps continuous delivery tool for Kubernetes, enabling automatic application deployment from Git repositories.
Helm Charts: Simplifies the deployment and management of complex Kubernetes applications using reusable, version-controlled charts.
Cert-Manager: Automates the management and issuance of TLS/SSL certificates within Kubernetes, integrated with ACME for automated renewals.
ExternalDNS: Dynamically manages DNS records in AWS Route 53 based on Kubernetes resources, automating DNS record creation and updates.

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





























































