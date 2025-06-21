## used to deploy kubernetes services using helm charts
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.4"

  namespace        = "cert-manager"
  create_namespace = true                      ###deploys cert manager to its own namespace  for automated TLS                                    ## cert man for automated TLS Certificates
  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [
    file("helm-values/cert-manager.yaml")
  ]
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"  ## Deploys external DNS to manage DNS records in cloudflare
  chart      = "external-dns"
  version    = "6.28.3"

  namespace        = "external-dns"
  create_namespace = true                     ### deploys external DNS to its own namespace for managing DNS records

  values = [
    file("helm-values/external-dns.yaml")
  ]
}

resource "helm_release" "argocd_deploy" {
  name       = "${var.helm_owner}-argocd"
  chart      = "${path.module}/helm-charts/argo-cd"       ## Deploys ArgoCD for GitOps
  version    = "8.0.16"

  namespace        = "argo-cd"         ## deploys ArgoCD to its own namespace for GitOps
  create_namespace = true

  values = [
    file("helm-values/argocd.yaml")
  ]
}

resource "helm_release" "prometheus_stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"    ## Deploys Prometheus stack for monitoring
  chart      = "kube-prometheus-stack"    ## Prometheus stack includes Prometheus, Grafana, and Alertmanager
  namespace  = "monitoring"  ##all in same namespace for monitoring
  
  create_namespace = true
  
  values = [
    file("${path.module}/helm-values/prometheus.yaml")
  ]
  
  depends_on = [
    helm_release.argocd_deploy,
    helm_release.cert_manager
    # Removed nginx_ingress since it already exists
  ]
}
