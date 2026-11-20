#!/usr/bin/env bash
# ---------------------------------------------------------------------
# Compile the user's own MIT Rust wallpaper at a pinned Git commit.
# Run as a NON-ROOT user in an ephemeral GitHub Docker builder, never in
# the privileged mkarchiso container or on the user's Linux workstation.
# ---------------------------------------------------------------------
set -euo pipefail
die() { printf 'nemesis wallpaper build: %s\n' "$*" >&2; exit 1; }

[[ "${NEMESIS_CI_DOCKER:-}" == "1" ]] || die "requires approved GitHub Docker CI"
[[ "$(id -u)" -ne 0 ]] || die "refusing to compile remote source as root"
[[ "$(uname -m)" == x86_64 ]] || die "only x86_64 operator image is in scope"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
spec="$root/spec/operator-edition.json"
[[ -f "$spec" ]] || die "missing source pin"
command -v python3 >/dev/null || die "python3 is required for source pin"
command -v cargo >/dev/null || die "signed cargo package required"
repo="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["wallpaper"]["source_repo"])' "$spec")"
sha="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["wallpaper"]["source_commit"])' "$spec")"
[[ "$repo" == "https://github.com/pskeffington/linux_live_wallpaper.git" ]] || die "unreviewed upstream repo"
[[ "$sha" =~ ^[0-9a-f]{40}$ ]] || die "invalid immutable source commit"
src="$root/.build/operator-wallpaper-source"
assets="$root/.build/operator-assets"
[[ ! -e "$src" && ! -L "$src" ]] || die "refusing to reuse wallpaper source directory"
[[ ! -e "$assets" && ! -L "$assets" ]] || die "refusing stale operator asset directory"
mkdir -p "$root/.build" "$assets"
git init --quiet "$src"
git -C "$src" fetch --quiet --depth 1 "$repo" "$sha"
git -C "$src" checkout --quiet --detach FETCH_HEAD
[[ "$(git -C "$src" rev-parse HEAD)" == "$sha" ]] || die "source commit mismatch"
[[ -f "$src/Cargo.lock" && -f "$src/LICENSE" ]] || die "missing license or lockfile"
grep -q 'MIT License' "$src/LICENSE" || die "unexpected upstream source license"

(
  cd "$src"
  cargo build --release --locked
)
install -m 0755 "$src/target/release/linux-live-wallpaper" "$assets/linux-live-wallpaper"
install -m 0644 "$src/LICENSE" "$assets/LICENSE"
{
  printf 'source_repository=%s\n' "$repo"
  printf 'source_commit=%s\n' "$sha"
  printf 'source_license=MIT\n'
  printf 'binary_sha256=%s\n' "$(sha256sum "$assets/linux-live-wallpaper" | awk '{print $1}')"
  printf 'cargo_lock_sha256=%s\n' "$(sha256sum "$src/Cargo.lock" | awk '{print $1}')"
} > "$assets/provenance.txt"
printf 'Pinned Linux Live Wallpaper compiled from %s\n' "$sha"
