resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "eks-admin-access"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "Group"
    name      = "admin" # MUST match your access_entries group
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [module.eks]
}
