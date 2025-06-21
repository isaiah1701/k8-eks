resource "kubernetes_cluster_role_binding" "admin" {
  metadata {
    name = "eks-admin-access"  # Name of the role binding
  }

  # References the built-in cluster-admin role (full permissions)
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"  # Kubernetes built-in admin role
  }

  # Binds the role to the "admin" group
  subject {
    kind      = "Group"
    name      = "admin"  # Must match the group in EKS access entries
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [module.eks]  # Wait for EKS cluster to be created
}
