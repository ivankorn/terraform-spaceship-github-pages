data "github_user" "current" {
  username = ""
}

locals {
  is_org = var.organization != ""
  owner  = local.is_org ? var.organization : (var.user != "" ? var.user : data.github_user.current.login)

  pages_ips = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]

  pages_ipv6_ips = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153"
  ]

  default_dns_records = concat(
    [
      for ip in local.pages_ips : {
        type    = "A"
        name    = "@"
        address = ip
        ttl     = var.dns_settings.ttl
      }
    ],
    [
      for ip in local.pages_ipv6_ips : {
        type    = "AAAA"
        name    = "@"
        address = ip
        ttl     = var.dns_settings.ttl
      }
    ],
    [{
      type  = "CNAME"
      name  = "www"
      cname = "${local.owner}.github.io"
      ttl   = var.dns_settings.ttl
    }]
  )

  # Combine default records with user-provided custom records
  all_dns_records = concat(local.default_dns_records, var.dns_settings.records)
}

resource "github_repository" "self" {
  name                        = var.name
  description                 = var.repository_settings.description
  visibility                  = var.repository_settings.visibility
  homepage_url                = var.repository_settings.homepage_url
  fork                        = var.repository_settings.fork
  source_owner                = var.repository_settings.source_owner
  source_repo                 = var.repository_settings.source_repo
  has_issues                  = var.repository_settings.has_issues
  has_discussions             = var.repository_settings.has_discussions
  has_projects                = var.repository_settings.has_projects
  has_wiki                    = var.repository_settings.has_wiki
  is_template                 = var.repository_settings.is_template
  allow_merge_commit          = var.repository_settings.allow_merge_commit
  allow_squash_merge          = var.repository_settings.allow_squash_merge
  allow_rebase_merge          = var.repository_settings.allow_rebase_merge
  allow_auto_merge            = var.repository_settings.allow_auto_merge
  allow_update_branch         = var.repository_settings.allow_update_branch
  allow_forking               = var.repository_settings.allow_forking
  squash_merge_commit_title   = var.repository_settings.allow_squash_merge ? var.repository_settings.squash_merge_commit_title : null
  squash_merge_commit_message = var.repository_settings.allow_squash_merge ? var.repository_settings.squash_merge_commit_message : null
  merge_commit_title          = var.repository_settings.allow_merge_commit ? var.repository_settings.merge_commit_title : null
  merge_commit_message        = var.repository_settings.allow_merge_commit ? var.repository_settings.merge_commit_message : null
  delete_branch_on_merge      = var.repository_settings.delete_branch_on_merge
  web_commit_signoff_required = var.repository_settings.web_commit_signoff_required
  auto_init                   = var.repository_settings.auto_init
  gitignore_template          = var.repository_settings.gitignore_template
  license_template            = var.repository_settings.license_template
  archived                    = var.repository_settings.archived
  archive_on_destroy          = var.repository_settings.archive_on_destroy
  topics                      = var.repository_settings.topics

  dynamic "template" {
    for_each = var.repository_settings.template != null ? [var.repository_settings.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  dynamic "security_and_analysis" {
    for_each = var.repository_settings.security_and_analysis != null ? [var.repository_settings.security_and_analysis] : []
    content {
      dynamic "advanced_security" {
        for_each = security_and_analysis.value.advanced_security != null ? [security_and_analysis.value.advanced_security] : []
        content {
          status = advanced_security.value.status
        }
      }
      dynamic "secret_scanning" {
        for_each = security_and_analysis.value.secret_scanning != null ? [security_and_analysis.value.secret_scanning] : []
        content {
          status = secret_scanning.value.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = security_and_analysis.value.secret_scanning_push_protection != null ? [security_and_analysis.value.secret_scanning_push_protection] : []
        content {
          status = secret_scanning_push_protection.value.status
        }
      }
      dynamic "secret_scanning_ai_detection" {
        for_each = security_and_analysis.value.secret_scanning_ai_detection != null ? [security_and_analysis.value.secret_scanning_ai_detection] : []
        content {
          status = secret_scanning_ai_detection.value.status
        }
      }
      dynamic "secret_scanning_non_provider_patterns" {
        for_each = security_and_analysis.value.secret_scanning_non_provider_patterns != null ? [security_and_analysis.value.secret_scanning_non_provider_patterns] : []
        content {
          status = secret_scanning_non_provider_patterns.value.status
        }
      }
    }
  }
}

resource "github_branch_default" "self" {
  repository = github_repository.self.name
  branch     = var.repository_settings.default_branch
  rename     = true
}


resource "time_sleep" "wait_for_dns" {
  depends_on      = [spaceship_dns_records.self]
  create_duration = "${var.dns_settings.ttl}s"
}


resource "github_repository_pages" "self" {
  repository     = github_repository.self.name
  build_type     = var.pages_settings.build_type
  cname          = var.domain
  public         = var.pages_settings.public
  https_enforced = var.domain != "" ? var.pages_settings.https_enforced : null

  dynamic "source" {
    for_each = var.pages_settings.build_type == "legacy" && var.pages_settings.source != null ? [var.pages_settings.source] : []
    content {
      branch = source.value.branch
      path   = source.value.path
    }
  }

  depends_on = [
    github_branch_default.self,
    time_sleep.wait_for_dns
  ]
}

resource "spaceship_dns_records" "self" {
  domain  = var.domain
  records = local.all_dns_records
}

resource "github_branch_protection" "self" {
  repository_id                   = github_repository.self.node_id
  pattern                         = var.branch_protection.pattern != null ? var.branch_protection.pattern : var.repository_settings.default_branch
  enforce_admins                  = var.branch_protection.enforce_admins
  require_signed_commits          = var.branch_protection.require_signed_commits
  required_linear_history         = var.branch_protection.required_linear_history
  require_conversation_resolution = var.branch_protection.require_conversation_resolution
  allows_deletions                = var.branch_protection.allows_deletions
  allows_force_pushes             = var.branch_protection.allows_force_pushes
  lock_branch                     = var.branch_protection.lock_branch
  force_push_bypassers            = local.is_org ? var.branch_protection.force_push_bypassers : null

  dynamic "required_status_checks" {
    for_each = var.branch_protection.required_status_checks != null ? [var.branch_protection.required_status_checks] : []
    content {
      strict   = required_status_checks.value.strict
      contexts = required_status_checks.value.contexts
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = var.branch_protection.required_pull_request_reviews != null ? [var.branch_protection.required_pull_request_reviews] : []
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      restrict_dismissals             = local.is_org ? required_pull_request_reviews.value.restrict_dismissals : false
      dismissal_restrictions          = local.is_org ? required_pull_request_reviews.value.dismissal_restrictions : null
      pull_request_bypassers          = local.is_org ? required_pull_request_reviews.value.pull_request_bypassers : null
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
    }
  }

  dynamic "restrict_pushes" {
    for_each = local.is_org && var.branch_protection.restrict_pushes != null ? [var.branch_protection.restrict_pushes] : []
    content {
      blocks_creations = restrict_pushes.value.blocks_creations
      push_allowances  = restrict_pushes.value.push_allowances
    }
  }

  depends_on = [github_branch_default.self]
}

resource "github_repository_vulnerability_alerts" "self" {
  count      = var.repository_settings.vulnerability_alerts ? 1 : 0
  repository = github_repository.self.id
}
