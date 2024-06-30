#!/bin/sh
set -ex

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

clu lint | reviewdog -efm="%f:%l: %m" \
      -name="linter-name (clu)" \
      -reporter="github-pr-review" \
      -filter-mode="nofilter" \
      -fail-on-error="true"
