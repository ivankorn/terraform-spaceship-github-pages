module "spaceship_github_pages" {
  source = "../../"

  domain = "example-test.com"
  name   = "example-test-repo"

  repository_settings = {
    visibility = "private"
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
