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

resource "github_repository_collaborator" "repository_collaborators" {
  for_each = {
    "az-tf-app" = "adyavanapalli"
  }

  repository = github_repository.repositories[each.key].name
  username   = github_membership.memberships[each.value].username
}

locals {
  repository_environments = {
    "az-tf-app" = {
      environments = ["Development", "Staging", "Production"]
      teams        = ["az-tf-pr-approvers", "gitops"]
      users        = ["adyavanapalli"]
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
  repository  = github_repository.repositories[each.value.repository].name

  reviewers {
    teams = [
      for team in each.value.teams :
      github_team.teams[team].id
    ]

    users = [
      for user in each.value.users :
      github_membership.memberships[user].id
    ]
  }

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }

  depends_on = [
    github_repository_collaborator.repository_collaborators
  ]
}
