# Backend Configuration
#
# Uses GitLab managed Terraform state.
# Initialize with: just tofu-init bates-ils-runners

terraform {
  backend "http" {}
}
