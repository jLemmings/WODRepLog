#!/usr/bin/env bash
set -euo pipefail

PUBSPEC_FILE=${PUBSPEC_FILE:-pubspec.yaml}

usage() {
  cat <<'USAGE' 1>&2
Usage: manage_version.sh <command> [args]

Commands:
  current                   Print current version and derived Android version code
USAGE
}

require_pubspec() {
  if [[ ! -f "$PUBSPEC_FILE" ]]; then
    echo "pubspec file not found at '$PUBSPEC_FILE'" >&2
    exit 1
  fi
}

read_current_version() {
  require_pubspec
  local current
  current=$(grep -E '^version:' "$PUBSPEC_FILE" | awk '{print $2}' | tr -d '\r')
  if [[ -z "$current" ]]; then
    echo "Unable to find version in $PUBSPEC_FILE" >&2
    exit 1
  fi
  echo "$current"
}

extract_build_number() {
  local version=$1
  if [[ $version == *+* ]]; then
    local suffix=${version#*+}
    if [[ $suffix =~ ^[0-9]+$ ]]; then
      echo "$suffix"
      return
    fi
    echo "Build number must be numeric, got '$suffix'" >&2
    exit 1
  fi
  echo "0"
}

emit_outputs() {
  local new_version=$1
  local build_number=$2
  local base_version=$3
  local build_suffix=$4
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "new_version=$new_version"
      echo "build_number=$build_number"
      echo "version_name=$new_version"
      echo "version_code=$build_number"
      echo "base_version=$base_version"
      echo "build_suffix=$build_suffix"
    } >> "$GITHUB_OUTPUT"
  fi
  echo "$new_version"
}

current_version() {
  local current core build version_code
  current=$(read_current_version)
  if [[ "$current" == *+* ]]; then
    core=${current%%+*}
  else
    core=$current
  fi
  build=$(extract_build_number "$current")
  version_code=$(compute_version_code "$core" "$build")
  emit_outputs "$current" "$version_code" "$core" "$build"
}

compute_version_code() {
  local core_version=$1
  local build_suffix=$2
  python - "$core_version" "$build_suffix" <<'PY'
import sys

core = sys.argv[1]
suffix = sys.argv[2]

parts = core.split('.')
if len(parts) != 3:
    raise SystemExit("Version core must have three segments (major.minor.patch)")

try:
    major, minor, patch = [int(part) for part in parts]
    build = int(suffix)
except ValueError as exc:
    raise SystemExit(f"Version components must be integers: {exc}") from exc

def ensure_range(name, value, upper):
    if value < 0 or value > upper:
        raise SystemExit(f"{name} component must be between 0 and {upper}, got {value}")

ensure_range("major", major, 99)
ensure_range("minor", minor, 99)
ensure_range("patch", patch, 99)
ensure_range("build", build, 9999)

version_code = int(f"{major:02d}{minor:02d}{patch:02d}{build:04d}")
if version_code > 2100000000:
    raise SystemExit("Computed version code exceeds Android limit of 2100000000")

print(version_code)
PY
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi
  case $1 in
    current)
      current_version
      ;;
    *)
      echo "Unknown command: $1" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"

