# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Pull Request Process

1. Update the README.md with details of changes including example hcl blocks and [example files](../examples) if appropriate.
2. Run pre-commit hooks `pre-commit run -a`.
3. Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release. The maintainers take care of updating the CHANGELOG as they merge.

## Checklists for contributions

- [ ] Add [semantics prefix](#semantic-pull-requests) to your PR or Commits (at least one of your commit groups)
- [ ] CI tests are passing
- [ ] README.md has been updated after any changes to variables and outputs.
- [ ] Run pre-commit hooks `pre-commit run -a`

## Semantic Pull Requests

To generate changelog, Pull Requests or Commits must have semantic and must follow conventional specs below:

- `feat:` for new features
- `fix:` for bug fixes
- `improvement:` for enhancements
- `docs:` for documentation and examples
- `refactor:` for code refactoring
- `test:` for tests
- `ci:` for CI purpose
- `chore:` for chores stuff

The `chore` prefix is skipped during changelog generation. It can be used for `chore: update changelog` commit message by example.

## Development Process

### Dependencies
To develop this module locally, you need the following dependencies installed:
- [Terraform](https://www.terraform.io/downloads)
- [pre-commit](https://pre-commit.com/#install)
- [terraform-docs](https://terraform-docs.io/user-guide/installation/)
- [tflint](https://github.com/terraform-linters/tflint#installation)
- [trivy](https://trivy.dev/docs/latest/getting-started/installation/)
- [checkov](https://github.com/bridgecrewio/checkov/tree/main#installation)
- [tfupdate](https://github.com/minamijoyo/tfupdate#install)
- [terrascan](https://github.com/tenable/terrascan#install)

To install the system dependencies required by these pre-commit tools (`python3`, `pip3`, `go`, and `curl`), run:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y python3 python3-pip golang-go curl

# Fedora/CentOS/RHEL (using dnf)
sudo dnf install -y python3 python3-pip golang-bin curl

# openSUSE/SUSE (using zypper)
sudo zypper install -y python3 python3-pip golang-bin curl

# macOS (using Homebrew)
brew install python go curl
```

### Linting and Doc Generation
Run the [pre-commit](https://pre-commit.com/#install) checks to ensure code formatting, linting, and documentation generation are applied automatically.

To manually run the checks on all files:
```bash
pre-commit run -a
```

To update the documentation:
```bash
terraform-docs markdown table --output-file README.md --output-mode inject .
```

### Running Tests
To run the module tests, execute:
```bash
terraform test
```
