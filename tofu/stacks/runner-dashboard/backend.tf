# Backend Configuration
#
# Uses GitLab managed Terraform state.
# Initialize with: just init

terraform {
  backend "http" {}
}
