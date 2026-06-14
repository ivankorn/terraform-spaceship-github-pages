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
> Keep this in mind since the default `github_repository_visibility` is set to `"private"`!
> For personal use on a free GitHub account, you need to set the `github_repository_visibility` to `"public"`!

## Usage Example

```hcl
module "spaceship_github_pages" {
  source = "../"

  domain                 = "example-test.com"
  github_repository_name = "example-test-repo"
}
```

See the [examples/](examples/) directory for more use cases.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.15.6 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |
| <a name="requirement_spaceship"></a> [spaceship](#requirement\_spaceship) | >= 0.4.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_github"></a> [github](#provider\_github) | 6.12.1 |
| <a name="provider_spaceship"></a> [spaceship](#provider\_spaceship) | 0.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [github_branch_protection.master](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.pages](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_pages.pages](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_pages) | resource |
| [spaceship_dns_records.pages](https://registry.terraform.io/providers/namecheap/spaceship/latest/docs/resources/dns_records) | resource |
| [github_user.current](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_domain"></a> [domain](#input\_domain) | The custom domain for GitHub Pages (e.g., example.com) | `string` | n/a | yes |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | Optional GitHub organization to create the repository in | `string` | `""` | no |
| <a name="input_github_repository_description"></a> [github\_repository\_description](#input\_github\_repository\_description) | Description for the GitHub repository | `string` | `"GitHub Pages repository"` | no |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | Name of the GitHub repository to create | `string` | n/a | yes |
| <a name="input_github_repository_visibility"></a> [github\_repository\_visibility](#input\_github\_repository\_visibility) | Visibility of the GitHub repository (public or private) | `string` | `"private"` | no |
| <a name="input_github_user"></a> [github\_user](#input\_github\_user) | Optional GitHub user to create the repository under | `string` | `""` | no |
| <a name="input_license_template"></a> [license\_template](#input\_license\_template) | License template for the GitHub repository | `string` | `"apache-2.0"` | no |
| <a name="input_ttl"></a> [ttl](#input\_ttl) | TTL for the DNS records | `number` | `3600` | no |

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
