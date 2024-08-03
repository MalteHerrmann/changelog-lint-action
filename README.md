# Changelog Lint Action

This GitHub action brings the linter from the [changelog-utils](https://github.com/MalteHerrmann/changelog-utils)
to your CI workflows.

It's using [reviewdog](https://github.com/reviewdog/reviewdog) to post comments on PR reviews that show any potential
problems with your changelogs.

## Example Workflow

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

    - name: Run changelog linter
      uses: MalteHerrmann/changelog-lint-action@v0.2.0
      with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
