variable "name" {
  description = "Name of the GitHub repository to create"
  type        = string
}

variable "domain" {
  description = "The custom domain for GitHub Pages (e.g., example.com)"
  type        = string
}

variable "organization" {
  description = "Optional GitHub organization to create the repository in"
  type        = string
  default     = ""
}

variable "user" {
  description = "Optional GitHub user to create the repository under"
  type        = string
  default     = ""
}

variable "dns_settings" {
  description = "Additional custom DNS records for Spaceship"
  type = object({
    ttl = optional(number, 60)
    records = optional(list(object({
      type             = string
      name             = string
      address          = optional(string)
      alias_name       = optional(string)
      association_data = optional(string)
      cname            = optional(string)
      exchange         = optional(string)
      flag             = optional(number)
      matching         = optional(number)
      nameserver       = optional(string)
      pointer          = optional(string)
      port             = optional(string)
      port_number      = optional(number)
      preference       = optional(number)
      priority         = optional(number)
      protocol         = optional(string)
      scheme           = optional(string)
      selector         = optional(number)
      service          = optional(string)
      svc_params       = optional(string)
      svc_priority     = optional(number)
      tag              = optional(string)
      target           = optional(string)
      target_name      = optional(string)
      ttl              = optional(number)
      usage            = optional(number)
      value            = optional(string)
      weight           = optional(number)
    })), [])
  })
  default = {}

  validation {
    condition     = var.dns_settings.ttl == null ? true : (var.dns_settings.ttl >= 60 && var.dns_settings.ttl <= 3600)
    error_message = "The ttl value must be between 60 and 3600."
  }

  validation {
    condition = alltrue([
      for r in(var.dns_settings.records != null ? var.dns_settings.records : []) :
      r.ttl == null ? true : (r.ttl >= 60 && r.ttl <= 3600)
    ])
    error_message = "All custom record ttl values must be between 60 and 3600."
  }
}

variable "repository_settings" {
  description = "Detailed settings for the GitHub repository"
  type = object({
    description                 = optional(string, "GitHub Pages repository")
    visibility                  = optional(string, "private")
    homepage_url                = optional(string)
    fork                        = optional(bool, false)
    source_owner                = optional(string)
    source_repo                 = optional(string)
    has_issues                  = optional(bool, true)
    has_discussions             = optional(bool, false)
    has_projects                = optional(bool, false)
    has_wiki                    = optional(bool, false)
    is_template                 = optional(bool, false)
    allow_merge_commit          = optional(bool, false)
    allow_squash_merge          = optional(bool, false)
    allow_rebase_merge          = optional(bool, true)
    allow_auto_merge            = optional(bool, false)
    allow_update_branch         = optional(bool, true)
    allow_forking               = optional(bool, true)
    squash_merge_commit_title   = optional(string, "PR_TITLE")
    squash_merge_commit_message = optional(string, "PR_BODY")
    merge_commit_title          = optional(string)
    merge_commit_message        = optional(string)
    delete_branch_on_merge      = optional(bool, true)
    web_commit_signoff_required = optional(bool, true)
    auto_init                   = optional(bool, true)
    gitignore_template          = optional(string)
    license_template            = optional(string, "apache-2.0")
    default_branch              = optional(string, "master")
    archived                    = optional(bool, false)
    archive_on_destroy          = optional(bool, false)
    topics                      = optional(list(string), [])
    vulnerability_alerts        = optional(bool, true)
    template = optional(object({
      owner                = string
      repository           = string
      include_all_branches = optional(bool, false)
    }))
    security_and_analysis = optional(object({
      advanced_security = optional(object({
        status = string
      }))
      secret_scanning = optional(object({
        status = string
      }))
      secret_scanning_push_protection = optional(object({
        status = string
      }))
      secret_scanning_ai_detection = optional(object({
        status = string
      }))
      secret_scanning_non_provider_patterns = optional(object({
        status = string
      }))
    }))
  })
  default = {}
}

variable "pages_settings" {
  description = "Settings for the GitHub Pages configuration"
  type = object({
    build_type     = optional(string, "legacy")
    public         = optional(bool)
    https_enforced = optional(bool, true)
    source = optional(object({
      branch = string
      path   = optional(string, "/")
      }), {
      branch = "master"
      path   = "/"
    })
  })
  default = {}
}

variable "branch_protection" {
  description = "Settings for the GitHub branch protection"
  type = object({
    pattern                         = optional(string)
    enforce_admins                  = optional(bool, true)
    require_signed_commits          = optional(bool, true)
    required_linear_history         = optional(bool, true)
    require_conversation_resolution = optional(bool, true)
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    lock_branch                     = optional(bool, false)
    force_push_bypassers            = optional(list(string), [])
    required_status_checks = optional(object({
      strict   = optional(bool, true)
      contexts = optional(list(string), [])
    }))
    required_pull_request_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool, true)
      restrict_dismissals             = optional(bool, true)
      dismissal_restrictions          = optional(list(string), [])
      pull_request_bypassers          = optional(list(string), [])
      require_code_owner_reviews      = optional(bool, true)
      required_approving_review_count = optional(number, 2)
      require_last_push_approval      = optional(bool, false)
    }), {})
    restrict_pushes = optional(object({
      blocks_creations = optional(bool, true)
      push_allowances  = optional(list(string), [])
    }), {})
  })
  default = {}
}
