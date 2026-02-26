# Runner Dashboard Module - RBAC
#
# ServiceAccount for the dashboard pod + ClusterRole with read access
# to runner namespaces (pods, deployments, HPAs, events) and ARC CRDs.

# =============================================================================
# ServiceAccount
# =============================================================================

resource "kubernetes_service_account" "dashboard" {
  metadata {
    name      = var.name
    namespace = local.namespace_name

    labels = local.labels
  }
}

# =============================================================================
# ClusterRole - Read access to runner resources + ARC CRDs
# =============================================================================

resource "kubernetes_cluster_role" "dashboard_reader" {
  metadata {
    name = "${var.name}-reader"

    labels = local.labels
  }

  # Pods - list, get, watch for status display
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "events", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  # Deployments - list, get for runner deployment status
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  # HPA - list, get for autoscaler status
  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }

  # PDB - list, get for disruption budget status
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["get", "list", "watch"]
  }

  # Helm releases (if needed for runner status)
  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = []
    verbs          = ["list"]
  }

  # Metrics (if metrics-server is available)
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }

  # ARC CRDs - read access to GitHub Actions runner resources
  rule {
    api_groups = ["actions.github.com"]
    resources  = ["autoscalingrunnersets", "ephemeralrunnersets", "ephemeralrunners"]
    verbs      = ["get", "list", "watch"]
  }
}

# =============================================================================
# ClusterRoleBinding - Bind to runners namespace
# =============================================================================

resource "kubernetes_cluster_role_binding" "dashboard_reader" {
  metadata {
    name = "${var.name}-reader"

    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dashboard_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = local.namespace_name
  }
}

# =============================================================================
# RoleBinding - Scoped read access to GitLab runners namespace
# =============================================================================

resource "kubernetes_role_binding" "runners_reader" {
  metadata {
    name      = "${var.name}-reader"
    namespace = var.runners_namespace

    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dashboard_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = local.namespace_name
  }
}

# =============================================================================
# RoleBindings - Scoped read access to ARC namespaces
# =============================================================================

resource "kubernetes_role_binding" "arc_reader" {
  for_each = toset(var.arc_namespaces)

  metadata {
    name      = "${var.name}-reader"
    namespace = each.value

    labels = local.labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dashboard_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = local.namespace_name
  }
}
