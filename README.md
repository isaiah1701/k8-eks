# 🛠️ Kubernetes EKS Platform Deployment with Terraform

This repository contains an end-to-end infrastructure deployment of a cloud-native Kubernetes application using **Amazon EKS**, **Terraform**, and **CI/CD pipelines**. It includes:

- EKS provisioning via Terraform modules  
- CI/CD with GitHub Actions and ArgoCD  
- Monitoring with Prometheus and Grafana  
- HTTPS with Cert-Manager  
- Dynamic DNS registration  
- App hub (Flask + Redis)  
- Infrastructure state locking using S3 and DynamoDB  

---

## 🔧 Tech Stack

- **AWS EKS** (Elastic Kubernetes Service)  
- **Terraform** (Infrastructure as Code)  
- **Helm & Helm Charts**  
- **ArgoCD** (GitOps CD tool)  
- **Prometheus + Grafana** (Monitoring stack)  
- **Cert-Manager** (TLS & HTTPS automation)  
- **Redis + Flask** (Application backend)  
- **External-DNS** (Cloudflare DNS automation)  

---

## 📁 Folder Structure

.
├── .github/workflows # CI/CD GitHub Actions
├── apps # Flask + Redis app config
├── argo-cd # ArgoCD manifests and CRDs
├── cert-man # Cert-Manager setup
├── dockerFolder # Docker setup for the app
├── helm-charts/argo-cd # Helm chart overrides for ArgoCD
├── helm-values # Helm values for Prometheus/Grafana
├── k8-eks.git # Working app hub resources
├── scripts # Utility scripts
├── *.tf / *.json # Terraform configs & DNS records



🔒 Security & HTTPS
Cert-Manager issues and renews TLS certs automatically

Cloudflare + External-DNS manage DNS records dynamically

RBAC is applied to restrict access for ArgoCD and GitHub pipelines

📌 Notes
ExternalDNS works with Cloudflare, ensure CNAME records point to your ingress.

App hub is a containerized Flask + Redis app with port fixes for stable ingress.

HTTPS is enabled with valid certs through Let’s Encrypt.

🙌 Credits
Maintained by isaiah1701
