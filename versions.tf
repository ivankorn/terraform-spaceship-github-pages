terraform {
  required_version = ">= 1.11.0"

  required_providers {
    spaceship = {
      source  = "namecheap/spaceship"
      version = ">= 0.4.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
