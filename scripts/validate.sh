#!/usr/bin/env bash
# Portable source-level checks; actual archiso building is a separate gate.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"
scripts=(
  scripts/prepare-profile.sh
  scripts/build-iso.sh
  scripts/validate.sh
  profiles/mac-intel/airootfs/usr/local/bin/nemesis-hw-report
)
for script in "${scripts[@]}"; do
  bash -n "$script"
done

awk '
  /^[[:space:]]*(#|$)/ { next }
  !/^[a-zA-Z0-9@._+:-]+$/ { printf "invalid package line %d: %s\n", NR, $0; bad=1 }
  seen[$0]++ { printf "duplicate package line %d: %s\n", NR, $0; bad=1 }
  END { exit bad }
' profiles/mac-intel/packages.x86_64

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "${scripts[@]}"
  printf 'ShellCheck: passed\n'
else
  printf 'ShellCheck: NOT RUN (install shellcheck for full static acceptance)\n'
fi
printf 'Bash syntax and package manifest: passed\n'
