# Changelog Utils Action

This GitHub action brings the [changelog-utils](https://github.com/MalteHerrmann/changelog-utils)
to your CI workflows.

It's using [reviewdog](https://github.com/reviewdog/reviewdog) to post comments on PR reviews that show any potential
problems with your changelogs.

## Supported Utils

Currently, the CI action supports:

- `clu lint`
- `clu check-diff`

The `command` input defaults to `lint`. `check-diff` requires a `pull_request`
event and a single-file changelog with an Unreleased entry for that PR. The action
fetches the base branch and missing history automatically. With `clu` v1.6.1,
the PR's head and base branches must have different names.

Upstream `check-diff` only searches the first 30 open PRs and identifies PRs by
head branch name, not fork owner. The PR must be in that first page, and its head
branch name must be unique across open PRs (including forks).

The display name has changed, but the repository remains `changelog-lint-action`.

## Example Workflow

```yaml
name: Changelog Utils

on:
  pull_request:

permissions:
  pull-requests: write
  contents: read

jobs:
  lint-changelog:
    runs-on: ubuntu-latest

    steps:
    - name: Check out the repository
      uses: actions/checkout@v4

    - name: Check changelog diff
      uses: MalteHerrmann/changelog-lint-action@v0.5.0
      with:
          command: check-diff
          github_token: ${{ secrets.GITHUB_TOKEN }}

    - name: Run changelog linter
      uses: MalteHerrmann/changelog-lint-action@v0.5.0
      with:
          command: lint
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
