#!/bin/bash

set -e  # Exit on error

echo "🔐 Creating clusterrolebinding for admin access..."
kubectl create clusterrolebinding isaiah4748-admin-binding \
  --clusterrole=cluster-admin \
  --user=arn:aws:iam::282378667097:user/isaiah4748 || true

echo "📦 Creating namespaces..."
kubectl create namespace argo-cd || true
kubectl create namespace cert-manager || true
kubectl create namespace external-dns || true
kubectl create namespace nginx-ingress || true
kubectl create namespace apps || true

echo "🚀 Adding Helm repos..."
helm repo add jetstack https://charts.jetstack.io || true
helm repo add argo https://argoproj.github.io/argo-helm || true
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update

echo "🔄 Uninstalling previous conflicting ArgoCD release (if any)..."
helm uninstall argocd --namespace argo-cd || true
kubectl delete crd applications.argoproj.io || true
kubectl delete namespace argo-cd || true
kubectl create namespace argo-cd || true

echo "🔐 Installing Cert Manager..."
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true

echo "🎯 Installing ArgoCD cleanly..."
helm install isaiah4748-argocd argo/argo-cd \
  --namespace argo-cd \
  --version 8.0.16 \
  --create-namespace \
  --set server.extraArgs="{--insecure}" \
  --set server.ingress.enabled=true \
  --set server.ingress.ingressClassName=nginx \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/ssl-redirect"="false" \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/force-ssl-redirect"="false" \
  --set server.ingress.annotations."nginx\.ingress\.kubernetes\.io/backend-protocol"="HTTP" \
  --set server.ingress.annotations."nginx\.org/hsts"="false" \
  --set server.ingress.hosts[0]="argocd.isaiahmichael.com"

echo "🌐 Installing External DNS..."
helm install external-dns bitnami/external-dns \
  --namespace external-dns \
  --create-namespace \
  --set provider=aws \
  --set aws.zoneType=public \
  --set policy=sync \
  --set registry=txt \
  --set txtOwnerId=isaiah4748 \
  --set serviceAccount.create=true

echo "🌐 Installing NGINX Ingress..."
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace nginx-ingress \
  --create-namespace

echo "✅ Done. Now configure Cloudflare DNS or wait for ExternalDNS to sync."
