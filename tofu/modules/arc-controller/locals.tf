# ARC Controller Module - Local Variables

locals {
  common_labels = {
    "app.kubernetes.io/name"       = "arc-controller"
    "app.kubernetes.io/instance"   = var.release_name
    "app.kubernetes.io/managed-by" = "opentofu"
    "app.kubernetes.io/component"  = "runner-controller"
  }
}
