#!/bin/sh
set -e

# Git writes must remain writable by subsequent steps on the host runner.
if [ "$(id -u)" = 0 ] && [ "$(stat -c %u .)" != 0 ]; then
  exec su-exec "$(stat -c '%u:%g' .)" "$0"
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
export GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ "$INPUT_COMMAND" = "lint" ]; then
  output=$(mktemp)
  trap 'rm -f "$output"' EXIT
  status=0
  clu lint > "$output" || status=$?
  reviewdog -efm="%f:%l: %m" \
    -name="changelog-utils" \
    -reporter="github-pr-review" \
    -filter-mode="nofilter" \
    -fail-on-error="true" < "$output"
  exit "$status"
elif [ "$INPUT_COMMAND" = "check-diff" ]; then
  if [ -z "$GITHUB_HEAD_REF" ] || [ -z "$GITHUB_BASE_REF" ]; then
    echo 'Error: check-diff requires a pull_request event.' >&2
    exit 1
  fi
  if [ "$GITHUB_HEAD_REF" = "$GITHUB_BASE_REF" ]; then
    echo 'Error: clu v1.6.1 requires different head and base branch names.' >&2
    exit 1
  fi
  if [ "$(git rev-parse --is-shallow-repository)" = true ]; then
    git fetch --no-tags --unshallow origin "$(git rev-parse HEAD)"
  fi
  git fetch --no-tags origin "$GITHUB_BASE_REF"
  git branch -f "$GITHUB_BASE_REF" FETCH_HEAD
  git checkout -B "$GITHUB_HEAD_REF" HEAD
  clu "$INPUT_COMMAND"
else
  echo "Error: Invalid command '$INPUT_COMMAND'. Valid options are 'lint' or 'check-diff'." >&2
  exit 1
fi
