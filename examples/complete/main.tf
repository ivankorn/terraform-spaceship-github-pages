module "spaceship_github_pages" {
  source = "../../"

  domain       = "example-complete.com"
  name         = "example-complete-repo"
  organization = "my-org"

  repository_settings = {
    description      = "A complete example repository"
    visibility       = "public"
    license_template = "apache-2.0"
  }

  dns_settings = {
    ttl = 1800
  }

  branch_protection = {
    pattern                         = "main"
    enforce_admins                  = true
    require_signed_commits          = true
    required_linear_history         = true
    require_conversation_resolution = true
    required_pull_request_reviews = {
      required_approving_review_count = 2
      require_code_owner_reviews      = true
      dismiss_stale_reviews           = true
      restrict_dismissals             = true
    }
  }
}
