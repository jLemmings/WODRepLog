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

emit_outputs() {
  local current_version=$1
  local version_code=$2
  local base_version=$3
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "new_version=$base_version"
      echo "full_version=$current_version"
      echo "version_name=$base_version"
      echo "version_code=$version_code"
      echo "base_version=$base_version"
    } >> "$GITHUB_OUTPUT"
  fi
  echo "$current_version"
}

current_version() {
  local current core version_code
  current=$(read_current_version)
  if [[ "$current" == *+* ]]; then
    core=${current%%+*}
  else
    core=$current
  fi
  version_code=$(compute_version_code "$core")
  emit_outputs "$current" "$version_code" "$core"
}

compute_version_code() {
  local core_version=$1
  local major minor patch version_code
  IFS=. read -r major minor patch extra <<< "$core_version"
  if [[ -n "${extra:-}" || -z "${major:-}" || -z "${minor:-}" || -z "${patch:-}" ]]; then
    echo "Version core must have three segments (major.minor.patch)" >&2
    exit 1
  fi

  for component in "$major" "$minor" "$patch"; do
    if [[ ! "$component" =~ ^[0-9]+$ ]]; then
      echo "Version components must be integers" >&2
      exit 1
    fi
  done

  major=$((10#$major))
  minor=$((10#$minor))
  patch=$((10#$patch))

  ensure_range "major" "$major" 20
  ensure_range "minor" "$minor" 99
  ensure_range "patch" "$patch" 99

  version_code=$((major * 100000000 + minor * 1000000 + patch * 10000))
  if (( version_code > 2100000000 )); then
    echo "Computed version code exceeds Android limit of 2100000000" >&2
    exit 1
  fi

  echo "$version_code"
}

ensure_range() {
  local name=$1
  local value=$2
  local upper=$3
  if (( value < 0 || value > upper )); then
    echo "$name component must be between 0 and $upper, got $value" >&2
    exit 1
  fi
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

