

data "github_user" "current" {
  username = ""
}

locals {
  github_owner = var.github_organization != "" ? var.github_organization : (var.github_user != "" ? var.github_user : try(data.github_user.current.login, "unknown-user"))

  github_pages_ips = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}

resource "github_repository" "pages" {
  name             = var.github_repository_name
  description      = var.github_repository_description
  visibility       = "public"
  auto_init        = true
  license_template = var.license_template

  pages {
    source {
      branch = "master"
      path   = "/"
    }
    cname = var.domain
  }
}

resource "spaceship_dns_records" "pages" {
  domain = var.domain

  records = toset([
    {
      type    = "A"
      name    = "@"
      address = local.github_pages_ips[0]
      ttl     = var.ttl
    },
    {
      type    = "A"
      name    = "@"
      address = local.github_pages_ips[1]
      ttl     = var.ttl
    },
    {
      type    = "A"
      name    = "@"
      address = local.github_pages_ips[2]
      ttl     = var.ttl
    },
    {
      type    = "A"
      name    = "@"
      address = local.github_pages_ips[3]
      ttl     = var.ttl
    },
    {
      type  = "CNAME"
      name  = "www"
      cname = "${local.github_owner}.github.io"
      ttl   = var.ttl
    }
  ])
}
