#!/bin/bash


helm uninstall argocd --namespace argo-cd
helm uninstall cert-manager --namespace cert-manager
helm uninstall external-dns --namespace external-dns
helm uninstall nginx-ingress --namespace ingress-nginx




kubectl delete crd applications.argoproj.io \
  applicationsets.argoproj.io \
  appprojects.argoproj.io


kubectl delete crd certificaterequests.cert-manager.io \
  certificates.cert-manager.io \
  challenges.acme.cert-manager.io \
  clusterissuers.cert-manager.io \
  issuers.cert-manager.io \
  orders.acme.cert-manager.io

kubectl delete namespace argocd
kubectl delete namespace cert-manager
kubectl delete namespace external-dns
kubectl delete namespace ingress-nginx
kubectl delete namespace apps
