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

locals {
  repository_environments = {
    "az-tf-app" = {
      environments = ["Development", "Staging", "Production"]
      teams        = ["gitops"]
    }
  }
}

resource "github_repository_environment" "repository_environments" {
  for_each = merge(
    [
      for repository, info in local.repository_environments :
      {
        for environment in info.environments :
        "${repository} - ${environment}" => {
          repository  = repository
          environment = environment
          teams       = info.teams
        }
      }
    ]...
  )

  environment = each.value.environment
  repository  = github_repository.github_repositories[each.value.repository].name

  reviewers {
    teams = [
      for team in each.value.teams :
      github_team.teams[team].id
    ]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
