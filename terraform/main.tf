resource "github_membership" "memberships" {
  for_each = {
    "adyavanapalli" = "admin"
  }

  username = each.key
  role     = each.value
}

resource "github_repository" "repositories" {
  for_each = {
    "az-tf-app" = "Contains the Terraform configuration for the application on Azure."
  }
  name        = each.key
  description = each.value
}

resource "github_team" "teams" {
  for_each = {
    "az-tf-pr-approvers" = "Responsible for approving pull requests in repositories that hold Terraform configuration for Azure resources."
    "gitops"             = "Responsible for all gitops happening in this organization."
  }

  name        = each.key
  description = each.value
  privacy     = "closed"
}
