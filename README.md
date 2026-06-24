# terraform-spaceship-github-pages

[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://vshymanskyy.github.io/StandWithUkraine/)

A Terraform/OpenTofu module to provision a GitHub repository with GitHub Pages enabled, and to configure the necessary DNS A and CNAME records using the [Spaceship provider](https://registry.terraform.io/providers/namecheap/spaceship/latest).

## Features

- Creates a new GitHub repository with an initial commit.
- Automatically enables GitHub Pages on the `master` branch.
- Sets the repository's custom domain to your desired domain name.
- Connects to the `spaceship` provider and creates the 4 standard GitHub Pages A records and the `www` CNAME record for the domain.

> [!WARNING]
> GitHub Pages requires the repository to be public for GitHub Free accounts.
> According to the [official documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/what-is-github-pages), "GitHub Pages is available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise."
> Keep this in mind since the default `repository_settings.visibility` is set to `"private"`!
> For personal use on a free GitHub account, you need to set the `repository_settings.visibility` to `"public"`!
>
> **Provider Bug #3450 Workaround:** Due to a [known bug](https://github.com/integrations/terraform-provider-github/issues/3450) in the GitHub Terraform Provider, the `cname` and `https_enforced` settings cannot be reliably managed by the `github_repository_pages` resource. This module uses a `null_resource` with a `local-exec` provisioner to configure these settings via the GitHub REST API. This workaround has specific requirements:
> - **System Dependencies:** You must have `bash`, `curl`, and `jq` installed on the system where Terraform is executed.

## Authentication

This module requires authentication with both GitHub and Spaceship:

1. **GitHub**: You must set the `GITHUB_TOKEN` environment variable. While Terraform can authenticate using the GitHub CLI (`gh auth login`), the `local-exec` provisioner script used for the GitHub Pages workaround *requires* the `GITHUB_TOKEN` environment variable to be explicitly set to interact directly with the GitHub API.
   - **Note for Deletion**: If you plan to destroy the repository using Terraform, you must have the `delete_repo` scope on your token.
2. **Spaceship**: You must provide your Spaceship API credentials by setting the `SPACESHIP_API_KEY` and `SPACESHIP_API_SECRET` environment variables.

## Usage Example

```hcl
module "spaceship_github_pages" {
  source = "../"

  domain = "example-test.com"
  name   = "example-test-repo"
}
```

See the [examples/](examples/) directory for more use cases.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.15.6 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_spaceship"></a> [spaceship](#requirement\_spaceship) | >= 0.4.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.12.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.0 |
| <a name="provider_spaceship"></a> [spaceship](#provider\_spaceship) | 0.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_branch_default.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_branch_protection.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_pages.this](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_pages) | resource |
| [null_resource.configure_cname_enforce_https](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [spaceship_dns_records.this](https://registry.terraform.io/providers/namecheap/spaceship/latest/docs/resources/dns_records) | resource |
| [github_user.current](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_branch_protection"></a> [branch\_protection](#input\_branch\_protection) | Settings for the GitHub branch protection | <pre>object({<br/>    pattern                         = optional(string)<br/>    enforce_admins                  = optional(bool, true)<br/>    require_signed_commits          = optional(bool, true)<br/>    required_linear_history         = optional(bool, true)<br/>    require_conversation_resolution = optional(bool, true)<br/>    allows_deletions                = optional(bool, false)<br/>    allows_force_pushes             = optional(bool, false)<br/>    lock_branch                     = optional(bool, false)<br/>    force_push_bypassers            = optional(list(string), [])<br/>    required_status_checks = optional(object({<br/>      strict   = optional(bool, true)<br/>      contexts = optional(list(string), [])<br/>    }))<br/>    required_pull_request_reviews = optional(object({<br/>      dismiss_stale_reviews           = optional(bool, true)<br/>      restrict_dismissals             = optional(bool, true)<br/>      dismissal_restrictions          = optional(list(string), [])<br/>      pull_request_bypassers          = optional(list(string), [])<br/>      require_code_owner_reviews      = optional(bool, true)<br/>      required_approving_review_count = optional(number, 2)<br/>      require_last_push_approval      = optional(bool, false)<br/>    }), {})<br/>    restrict_pushes = optional(object({<br/>      blocks_creations = optional(bool, true)<br/>      push_allowances  = optional(list(string), [])<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_dns_settings"></a> [dns\_settings](#input\_dns\_settings) | Additional custom DNS records for Spaceship | <pre>object({<br/>    ttl = optional(number, 60)<br/>    records = optional(list(object({<br/>      type             = string<br/>      name             = string<br/>      address          = optional(string)<br/>      alias_name       = optional(string)<br/>      association_data = optional(string)<br/>      cname            = optional(string)<br/>      exchange         = optional(string)<br/>      flag             = optional(number)<br/>      matching         = optional(number)<br/>      nameserver       = optional(string)<br/>      pointer          = optional(string)<br/>      port             = optional(string)<br/>      port_number      = optional(number)<br/>      preference       = optional(number)<br/>      priority         = optional(number)<br/>      protocol         = optional(string)<br/>      scheme           = optional(string)<br/>      selector         = optional(number)<br/>      service          = optional(string)<br/>      svc_params       = optional(string)<br/>      svc_priority     = optional(number)<br/>      tag              = optional(string)<br/>      target           = optional(string)<br/>      target_name      = optional(string)<br/>      ttl              = optional(number)<br/>      usage            = optional(number)<br/>      value            = optional(string)<br/>      weight           = optional(number)<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The custom domain for GitHub Pages (e.g., example.com) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the GitHub repository to create | `string` | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Optional GitHub organization to create the repository in | `string` | `""` | no |
| <a name="input_pages_settings"></a> [pages\_settings](#input\_pages\_settings) | Settings for the GitHub Pages configuration | <pre>object({<br/>    build_type = optional(string, "legacy")<br/>    public     = optional(bool)<br/>    # Note: 'https_enforced' is temporarily disabled due to GitHub provider bug #3450. A local-exec provisioner handles this.<br/>    https_enforced = optional(bool, true)<br/>    source = optional(object({<br/>      branch = string<br/>      path   = optional(string, "/")<br/>      }), {<br/>      branch = "master"<br/>      path   = "/"<br/>    })<br/>  })</pre> | `{}` | no |
| <a name="input_repository_settings"></a> [repository\_settings](#input\_repository\_settings) | Detailed settings for the GitHub repository | <pre>object({<br/>    description                 = optional(string, "GitHub Pages repository")<br/>    visibility                  = optional(string, "private")<br/>    homepage_url                = optional(string)<br/>    fork                        = optional(bool, false)<br/>    source_owner                = optional(string)<br/>    source_repo                 = optional(string)<br/>    has_issues                  = optional(bool, true)<br/>    has_discussions             = optional(bool, false)<br/>    has_projects                = optional(bool, false)<br/>    has_wiki                    = optional(bool, false)<br/>    is_template                 = optional(bool, false)<br/>    allow_merge_commit          = optional(bool, false)<br/>    allow_squash_merge          = optional(bool, false)<br/>    allow_rebase_merge          = optional(bool, true)<br/>    allow_auto_merge            = optional(bool, false)<br/>    allow_update_branch         = optional(bool, true)<br/>    allow_forking               = optional(bool, true)<br/>    squash_merge_commit_title   = optional(string, "PR_TITLE")<br/>    squash_merge_commit_message = optional(string, "PR_BODY")<br/>    merge_commit_title          = optional(string)<br/>    merge_commit_message        = optional(string)<br/>    delete_branch_on_merge      = optional(bool, true)<br/>    web_commit_signoff_required = optional(bool, true)<br/>    auto_init                   = optional(bool, true)<br/>    gitignore_template          = optional(string)<br/>    license_template            = optional(string, "apache-2.0")<br/>    default_branch              = optional(string, "master")<br/>    archived                    = optional(bool, false)<br/>    archive_on_destroy          = optional(bool, false)<br/>    topics                      = optional(list(string), [])<br/>    # Note: This attribute is deprecated in the provider, but currently required to satisfy security and analysis checks.<br/>    vulnerability_alerts = optional(bool, true)<br/>    template = optional(object({<br/>      owner                = string<br/>      repository           = string<br/>      include_all_branches = optional(bool, false)<br/>    }))<br/>    security_and_analysis = optional(object({<br/>      advanced_security = optional(object({<br/>        status = string<br/>      }))<br/>      secret_scanning = optional(object({<br/>        status = string<br/>      }))<br/>      secret_scanning_push_protection = optional(object({<br/>        status = string<br/>      }))<br/>      secret_scanning_ai_detection = optional(object({<br/>        status = string<br/>      }))<br/>      secret_scanning_non_provider_patterns = optional(object({<br/>        status = string<br/>      }))<br/>    }))<br/>    # Note: The inline pages configuration is deprecated. It is retained here for backwards compatibility, but pages_settings should be preferred.<br/>    pages = optional(object({<br/>      build_type = optional(string)<br/>      # Note: 'cname' is temporarily disabled due to GitHub provider bug #3450. A local-exec provisioner handles this.<br/>      cname = optional(string)<br/>      source = optional(object({<br/>        branch = string<br/>        path   = optional(string)<br/>      }))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_user"></a> [user](#input\_user) | Optional GitHub user to create the repository under | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_domain"></a> [domain](#output\_domain) | The configured custom domain |
| <a name="output_pages_url"></a> [pages\_url](#output\_pages\_url) | URL of the GitHub Pages site |
| <a name="output_repository_name"></a> [repository\_name](#output\_repository\_name) | Name of the created GitHub repository |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | URL of the created GitHub repository |
<!-- END_TF_DOCS -->

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/korn-systems/terraform-spaceship-github-pages/issues/new) section.

Full contributing [guidelines are covered here](.github/CONTRIBUTING.md).

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.

## Security

If you discover any security related issues, please email `ivan.kornienko@gmail.com` instead of using the issue tracker. All security vulnerabilities will be promptly addressed.
