#!/usr/bin/env bash
# Give the current GitHub Actions job read access to the private QuantumLeap package.
# The token is attached to git through a job-scoped extra header for the QuantumLeap URL only,
# via GIT_CONFIG_* variables in $GITHUB_ENV. Nothing is written to ~/.netrc, ~/.gitconfig or the
# credential helper, so nothing outlives the job. The token is never printed.
set -euo pipefail

: "${GITHUB_ENV:?this script runs inside GitHub Actions}"

if [ -z "${QUANTUMLEAP_READ_TOKEN:-}" ]; then
  echo "::error title=QUANTUMLEAP_READ_TOKEN is not set::Add the repository secret QUANTUMLEAP_READ_TOKEN (a token with read-only contents access to qtmleap/QuantumLeap only). QuantumLeap is private and the package cannot be resolved without it."
  exit 1
fi

credential=$(printf 'x-access-token:%s' "$QUANTUMLEAP_READ_TOKEN" | base64 | tr -d '\n')
echo "::add-mask::$credential"

{
  echo "GIT_CONFIG_COUNT=2"
  echo "GIT_CONFIG_KEY_0=http.https://github.com/qtmleap/QuantumLeap.extraheader"
  echo "GIT_CONFIG_VALUE_0=AUTHORIZATION: basic $credential"
  echo "GIT_CONFIG_KEY_1=http.https://github.com/qtmleap/QuantumLeap.git.extraheader"
  echo "GIT_CONFIG_VALUE_1=AUTHORIZATION: basic $credential"
} >> "$GITHUB_ENV"
echo "QuantumLeap read access configured for this job."
