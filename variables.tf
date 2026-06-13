variable "domain" {
  description = "The custom domain for GitHub Pages (e.g., example.com)"
  type        = string
}

variable "github_organization" {
  description = "Optional GitHub organization to create the repository in"
  type        = string
  default     = ""
}

variable "github_repository_description" {
  description = "Description for the GitHub repository"
  type        = string
  default     = "GitHub Pages repository"
}

variable "github_repository_name" {
  description = "Name of the GitHub repository to create"
  type        = string
}

variable "github_user" {
  description = "Optional GitHub user to create the repository under"
  type        = string
  default     = ""
}

variable "license_template" {
  description = "License template for the GitHub repository"
  type        = string
  default     = "apache-2.0"
}

variable "ttl" {
  description = "TTL for the DNS records"
  type        = number
  default     = 3600
}
