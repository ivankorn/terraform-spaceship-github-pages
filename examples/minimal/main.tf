module "spaceship_github_pages" {
  source = "../../"

  domain                 = "example-test.com"
  github_repository_name = "example-test-repo"
}
