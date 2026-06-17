terraform {
  required_version = "1.15.6"

  required_providers {
    spaceship = {
      source  = "namecheap/spaceship"
      version = ">= 0.4.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}
