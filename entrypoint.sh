#!/bin/sh
set -ex

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ "$INPUT_COMMAND" = "lint" ]; then
  clu "$INPUT_COMMAND" | reviewdog -efm="%f:%l: %m" \
    -name="changelog-utils" \
    -reporter="github-pr-review" \
    -filter-mode="nofilter" \
    -fail-on-error="true"
elif [ "$INPUT_COMMAND" = "check-diff" ]; then
  clu "$INPUT_COMMAND"
else
  echo "Error: Invalid command '$INPUT_COMMAND'. Valid options are 'lint' or 'check-diff'." >&2
  exit 1
fi
