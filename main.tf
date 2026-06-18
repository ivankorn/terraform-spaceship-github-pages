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

resource "spaceship_dns_records" "this" {
  domain  = var.domain
  records = local.all_dns_records
}

resource "github_repository" "this" {
  name         = var.name
  description  = var.repository_settings.description
  visibility   = var.repository_settings.visibility
  homepage_url = var.repository_settings.homepage_url
  fork         = var.repository_settings.fork
  source_owner = var.repository_settings.source_owner
  source_repo  = var.repository_settings.source_repo
  has_issues   = var.repository_settings.has_issues
  # Note: This attribute is deprecated in the provider, but currently required to satisfy security and analysis checks.
  vulnerability_alerts        = var.repository_settings.vulnerability_alerts
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

  dynamic "pages" {
    for_each = var.repository_settings.pages != null ? [var.repository_settings.pages] : []
    content {
      build_type = pages.value.build_type
      cname      = pages.value.cname
      dynamic "source" {
        for_each = pages.value.source != null ? [pages.value.source] : []
        content {
          branch = source.value.branch
          path   = source.value.path
        }
      }
    }
  }
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.repository_settings.default_branch
  rename     = true
}


resource "github_repository_pages" "this" {
  repository = github_repository.this.name
  build_type = var.pages_settings.build_type
  # Note: 'cname' is temporarily disabled due to GitHub provider bug #3450. A local-exec provisioner handles this.
  # cname          = var.domain
  public = var.pages_settings.public
  # Note: 'https_enforced' is temporarily disabled due to GitHub provider bug #3450. A local-exec provisioner handles this.
  # https_enforced = var.domain != "" ? var.pages_settings.https_enforced : null

  dynamic "source" {
    for_each = var.pages_settings.build_type == "legacy" && var.pages_settings.source != null ? [var.pages_settings.source] : []
    content {
      branch = source.value.branch
      path   = source.value.path
    }
  }

  depends_on = [
    github_branch_default.this,
    spaceship_dns_records.this
  ]
}

# This is a temporarily workaround for GitHub provider bug #3450
resource "null_resource" "configure_cname_enforce_https" {
  provisioner "local-exec" {
    when        = create
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      #!/usr/bin/env bash
      set -e

      if [ -z "$${GITHUB_TOKEN}" ]; then
        echo "GITHUB_TOKEN is not set. Skipping GitHub Pages configuration."
        exit 0
      fi

      API_URL="https://api.github.com/repos/${local.owner}/${github_repository.this.name}/pages"
      HEADERS=(
        "-H" "Accept: application/vnd.github+json"
        "-H" "Authorization: Bearer $${GITHUB_TOKEN}"
        "-H" "X-GitHub-Api-Version: 2026-03-10"
      )

      echo "Waiting up to 10 minutes for GitHub Pages to be built..."
      for i in {1..60}; do
        STATUS=$(curl -sL "$${HEADERS[@]}" "$${API_URL}" | jq -r '.status // empty')
        if [ "$${STATUS}" == "built" ]; then
          echo "Pages built successfully."
          break
        fi
        echo "Current status: $${STATUS:-unknown}. Waiting..."
        sleep 10
      done

      if [ "$${STATUS}" != "built" ]; then
        echo "Warning: GitHub Pages failed to build within 10 minutes."
      fi

      echo "Adding CNAME ${var.domain}..."
      for i in {1..60}; do
        curl -sL -X PUT "$${HEADERS[@]}" "$${API_URL}" -d "{\"cname\":\"${var.domain}\"}" > /dev/null

        CURRENT_CNAME=$(curl -sL "$${HEADERS[@]}" "$${API_URL}" | jq -r '.cname // empty')
        if [ "$CURRENT_CNAME" == "${var.domain}" ]; then
          echo "CNAME accepted successfully."
          break
        fi
        echo "CNAME not yet accepted (DNS might still be propagating). Waiting..."
        sleep 10
      done

      if [ "${try(var.pages_settings.https_enforced, true)}" == "true" ]; then
        echo "Waiting up to 20 minutes for HTTPS certificate approval..."
        for i in {1..120}; do
          CERT_STATE=$(curl -sL "$${HEADERS[@]}" "$${API_URL}" | jq -r '.https_certificate.state // empty')
          if [ "$${CERT_STATE}" == "approved" ]; then
            echo "HTTPS certificate approved."
            break
          fi
          echo "Current certificate state: $${CERT_STATE:-unknown}. Waiting..."
          sleep 10
        done

        if [ "$${CERT_STATE}" == "approved" ]; then
          echo "Enforcing HTTPS..."
          curl -sL -X PUT "$${HEADERS[@]}" \
            "$${API_URL}" \
            -d "{\"cname\":\"${var.domain}\", \"https_enforced\": true}" > /dev/null
        else
          echo "Warning: HTTPS certificate was not approved within 20 minutes. While the API promise is 15 minutes."
        fi
      fi
    EOT
  }

  depends_on = [
    github_repository_pages.this,
  ]
}

resource "github_branch_protection" "this" {
  repository_id                   = github_repository.this.node_id
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

  depends_on = [null_resource.configure_cname_enforce_https]
}

