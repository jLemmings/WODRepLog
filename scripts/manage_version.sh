#!/usr/bin/env bash
set -euo pipefail

PUBSPEC_FILE=${PUBSPEC_FILE:-pubspec.yaml}

usage() {
  cat <<'USAGE' 1>&2
Usage: manage_version.sh <command> [args]

Commands:
  increment-build           Increment build number (suffix after '+') in pubspec.yaml
  release <version>         Set version to <version> (major.minor.patch) with build number reset to 1
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

write_version() {
  local new_version=$1
  python <<PY
from pathlib import Path
import re
path = Path(r"$PUBSPEC_FILE")
text = path.read_text()
pattern = re.compile(r"^version:\s*.+$", re.MULTILINE)
if not pattern.search(text):
    raise SystemExit("version field not found in pubspec")
path.write_text(pattern.sub(f"version: {new_version}", text))
PY
}

emit_outputs() {
  local new_version=$1
  local build_number=$2
  local base_version=$3
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "new_version=$new_version"
      echo "build_number=$build_number"
      echo "base_version=$base_version"
    } >> "$GITHUB_OUTPUT"
  fi
  echo "$new_version"
}

increment_build() {
  local current core build
  current=$(read_current_version)
  if [[ "$current" == *+* ]]; then
    core=${current%%+*}
    build=${current#*+}
  else
    core=$current
    build="0"
  fi
  if [[ ! $build =~ ^[0-9]+$ ]]; then
    echo "Build number must be numeric, got '$build'" >&2
    exit 1
  fi
  local new_build=$((build + 1))
  local new_version="${core}+${new_build}"
  write_version "$new_version"
  emit_outputs "$new_version" "$new_build" "$core"
}

set_release_version() {
  local release_version=$1
  release_version=${release_version#v}
  release_version=${release_version#V}
  if [[ ! $release_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Release version must match 'major.minor.patch', got '$1'" >&2
    exit 1
  fi
  local new_build=1
  local new_version="${release_version}+${new_build}"
  write_version "$new_version"
  emit_outputs "$new_version" "$new_build" "$release_version"
}

main() {
  if [[ $# -lt 1 ]]; then
    usage
    exit 1
  fi
  case $1 in
    increment-build)
      increment_build
      ;;
    release)
      if [[ $# -lt 2 ]]; then
        echo "release command requires a version argument" >&2
        usage
        exit 1
      fi
      set_release_version "$2"
      ;;
    *)
      echo "Unknown command: $1" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"

