# Changelog Utils Action

This GitHub action brings the [changelog-utils](https://github.com/MalteHerrmann/changelog-utils)
to your CI workflows.

It's using [reviewdog](https://github.com/reviewdog/reviewdog) to post comments on PR reviews that show any potential
problems with your changelogs.

## Supported Utils

Currently, the CI action supports:

- `clu lint`
- `clu check-diff`

## Example Workflow

### Linter

```yaml
name: Changelog Linter

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
      uses: MalteHerrmann/changelog-utils-action@v0.5.0
      with:
          command: check-diff
          github_token: ${{ secrets.GITHUB_TOKEN }}

    - name: Run changelog linter
      uses: MalteHerrmann/changelog-lint-action@v0.4.0
      with:
          command: lint
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
