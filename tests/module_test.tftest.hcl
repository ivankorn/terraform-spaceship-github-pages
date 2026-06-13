mock_provider "github" {}
mock_provider "spaceship" {}

variables {
  domain                 = "testdomain.com"
  github_repository_name = "test-repo"
}

run "verify_module" {
  command = plan

  assert {
    condition     = github_repository.pages.name == "test-repo"
    error_message = "Repository name does not match expected."
  }

  assert {
    condition     = spaceship_dns_records.pages.domain == "testdomain.com"
    error_message = "DNS records domain does not match expected."
  }
}
