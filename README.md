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
fetches the base branch and missing history automatically. With `clu` v1.7.0,
the PR's head and base branches must have different names.

Upstream `check-diff` searches all open PRs and identifies PRs by head branch
name, not fork owner. The head branch name must be unique across open PRs
(including forks).

The display name has changed, but the repository remains `changelog-lint-action`.

## Check for an entry and lint the changelog

Copy the following into `.github/workflows/changelog.yml`. It first requires a
new Unreleased entry for the current PR, then checks changelog formatting and
reports lint problems through reviewdog. Using the action without `command:
check-diff` only runs the linter; linting alone does not require a new entry.

Before enabling the workflow, initialize the project's changelog configuration
with `clu init` if needed (`clu init --yes` for non-interactive use). Commit
`.clconfig.json` with `target_repo` set to your repository's GitHub URL and
`changelog_path` pointing to your changelog. Only single-file changelogs are
supported. For existing configurations, run `clu config migrate` to upgrade to
configuration version 2 and remove retired settings such as `mode` and
`changelog_dir`. Entries must follow that configuration and link to their PR.
The upstream limitations above still apply.

```yaml
name: Changelog Utils

on:
  pull_request:

# Grant permissions only to the job that needs them.
permissions: {}

jobs:
  changelog:
    name: Changelog checks
    runs-on: ubuntu-latest
    permissions:
      contents: read       # Check out the repository and fetch the base branch.
      pull-requests: write # Read PR metadata and post reviewdog review comments.

    steps:
      - name: Check out the repository
        uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1

      - name: Require a changelog entry for this PR
        uses: MalteHerrmann/changelog-lint-action@ae12b0e92ac8f465f3056ca01ad9c47c6bf3d451 # v0.6.0
        with:
          command: check-diff
          github_token: ${{ github.token }}

      - name: Lint the changelog
        uses: MalteHerrmann/changelog-lint-action@ae12b0e92ac8f465f3056ca01ad9c47c6bf3d451 # v0.6.0
        with:
          command: lint
          github_token: ${{ github.token }}
```

### Token permissions and security

The `permissions` keys control the automatic, short-lived `GITHUB_TOKEN` for this
job. You do not need to create a personal access token or add a repository secret.
The action defaults to `${{ github.token }}`; the example passes it explicitly to
make the authentication clear.

- `contents: read` allows checkout and the base-branch fetch. No repository write
  access is needed. Leave checkout's `persist-credentials` enabled (the default)
  so authenticated fetches also work in private repositories.
- `pull-requests: write` allows reviewdog to post PR review comments. If you only
  use `check-diff`, remove the lint step and reduce this to `pull-requests: read`.
  No `checks: write` or `issues: write` permission is required.
- Action references are pinned to full commit SHAs to prevent tag changes from
  silently changing the code your workflow runs. The comments identify their
  versions. On self-hosted runners, checkout's authenticated Git operations in
  Docker actions require Actions Runner v2.329.0 or later; GitHub-hosted
  `ubuntu-latest` runners provide this support.

GitHub normally restricts tokens for fork and Dependabot PRs to read-only access,
even when the workflow requests write access. Reviewdog may therefore be unable
to post review comments for those PRs. Keep the `pull_request` trigger: do **not**
switch to `pull_request_target` or grant untrusted fork workflows write tokens
just to enable comments.

### Block merges when an entry is missing

A missing matching Unreleased entry makes the `check-diff` step and the job fail.
To enforce this before merging, select **Changelog checks** as a required status
check in your branch protection rule or repository ruleset after its first run.
Do not add `continue-on-error: true` to the step or job. Move entries into a
versioned release section after the PR merges, because `check-diff` requires the
entry to remain Unreleased while the PR is open.
