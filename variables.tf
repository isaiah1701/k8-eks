variable "helm_owner" {
  description = "The identifier used to prefix Helm release names"
  type        = string
}

variable "argocd_values_file" {
  description = "Path to the ArgoCD Helm values file"
  type        = string
  default     = "helm-values/argocd.yaml"
}

variable "external_dns_values_file" {
  description = "Path to the ExternalDNS Helm values file"
  type        = string
  default     = "helm-values/external-dns.yaml"
}

variable "cert_manager_values_file" {
  description = "Path to the Cert-Manager Helm values file"
  type        = string
  default     = "helm-values/cert-manager.yaml"
}

variable "iam_user_arn" {
  description = "IAM user ARN to grant access to the EKS cluster"
  type        = string
}

variable "iam_user_name" {
  description = "IAM username to grant access to the EKS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
  default     = "eu-west-2"
}

##variables user can customise 