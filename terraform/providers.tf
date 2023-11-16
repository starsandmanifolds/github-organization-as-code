terraform {
  cloud {
    organization = "starsandmanifolds"

    workspaces {
      name = "github-organization-as-code"
    }
  }

  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

provider "github" {}
