module "spaceship_github_pages" {
  source = "../../"

  domain                        = "example-complete.com"
  github_repository_name        = "example-complete-repo"
  github_repository_description = "A complete example repository"
  github_repository_visibility  = "private"
  github_organization           = "my-org"
  license_template              = "apache-2.0"
  ttl                           = 1800
}
