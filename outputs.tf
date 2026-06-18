output "domain" {
  description = "The configured custom domain"
  value       = var.domain
}

output "pages_url" {
  description = "URL of the GitHub Pages site"
  value       = "https://${var.domain}"
}

output "repository_name" {
  description = "Name of the created GitHub repository"
  value       = github_repository.this.name
}

output "repository_url" {
  description = "URL of the created GitHub repository"
  value       = github_repository.this.html_url
}
