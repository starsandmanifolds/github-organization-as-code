resource "github_repository" "repository" {
  name        = "az-tf-app"
  description = "Contains the Terraform configuration for the application on Azure."
}

resource "github_team" "teams" {
  for_each = {
    "az-tf-pr-approvers" = "Responsible for approving pull requests in repositories that hold Terraform configuration for Azure resources."
    "gitops"             = "Responsible for all gitops happening in this organization."
  }

  name        = each.key
  description = each.value
}
