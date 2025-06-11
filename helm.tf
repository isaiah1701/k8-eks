resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = "ingress-nginx"
  create_namespace = true
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.14.4"

  namespace        = "cert-manager"
  create_namespace = true

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
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = "6.28.3"

  namespace        = "external-dns"
  create_namespace = true

  values = [
    file("helm-values/external-dns.yaml")
  ]
}

resource "helm_release" "argocd_deploy" {
  name       = "${var.helm_owner}-argocd"
  chart      = "${path.module}/helm-charts/argo-cd"
  version    = "8.0.16"

  namespace        = "argo-cd"
  create_namespace = true

  values = [
    file("helm-values/argocd.yaml")
  ]
}

resource "helm_release" "prometheus_stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  
  create_namespace = true
  
  values = [
    file("${path.module}/helm-values/prometheus.yaml")
  ]
  
  depends_on = [
    helm_release.argocd_deploy,     # CHANGED: Use correct resource name
    helm_release.nginx_ingress,
    helm_release.cert_manager
  ]
}
