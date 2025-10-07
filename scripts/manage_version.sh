#!/usr/bin/env bash
set -euo pipefail

PUBSPEC_FILE=${PUBSPEC_FILE:-pubspec.yaml}

usage() {
  cat <<'USAGE' 1>&2
Usage: manage_version.sh <command> [args]

Commands:
  increment-build           Increment build number (suffix after '+') in pubspec.yaml
  release <version>         Set version to <version> (major.minor.patch) and ensure build number increases
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

write_version() {
  local new_version=$1
  python - "$PUBSPEC_FILE" "$new_version" <<'PY'
from pathlib import Path
import re
import sys

pubspec_path = Path(sys.argv[1])
new_version = sys.argv[2]

text = pubspec_path.read_text()
pattern = re.compile(r"^version:\s*.+$", re.MULTILINE)
if not pattern.search(text):
    raise SystemExit("version field not found in pubspec")
pubspec_path.write_text(pattern.sub(f"version: {new_version}", text))
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
  else
    core=$current
  fi
  build=$(extract_build_number "$current")
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
  local current=$(read_current_version)
  local existing_build=$(extract_build_number "$current")
  local new_build=$((existing_build + 1))
  local run_number=${GITHUB_RUN_NUMBER:-}
  if [[ $run_number =~ ^[0-9]+$ && $run_number -gt $new_build ]]; then
    new_build=$run_number
  fi
  if (( new_build < 1 )); then
    new_build=1
  fi
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

