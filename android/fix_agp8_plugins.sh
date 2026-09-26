#!/usr/bin/env bash
# Migrates old Flutter plugin Android modules to be compatible with AGP 8.x.
#
# For every plugin referenced in .flutter-plugins this script:
#   1. Removes the deprecated `package="..."` attribute from the plugin's
#      android/src/main/AndroidManifest.xml (AGP 8 rejects it for libraries).
#   2. Adds a `namespace '...'` line to the plugin's android/build.gradle
#      (using the old package value) so R/BuildConfig are generated correctly.
#
# Idempotent: safe to run multiple times. Re-run after `flutter pub get` if the
# pub cache is repaired/cleaned.
#
# NOTE: This edits files inside ~/.pub-cache. Those edits persist until
# `flutter pub cache clean` / `pub cache repair`. Keep this script in the repo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_FILE="$SCRIPT_DIR/../.flutter-plugins"

if [ ! -f "$PLUGINS_FILE" ]; then
  echo ">> .flutter-plugins not found. Run 'flutter pub get' first."
  exit 1
fi

patched=0

while IFS='=' read -r name path; do
  case "$name" in '#'*) continue ;; esac
  [ -z "$path" ] && continue
  path="${path%/}"
  manifest="$path/android/src/main/AndroidManifest.xml"
  bgradle="$path/android/build.gradle"
  [ -f "$manifest" ] || continue
  [ -f "$bgradle" ] || continue

  pkg="$(grep -oE 'package="[^"]+"' "$manifest" | head -1 | sed -E 's/package="([^"]+)"/\1/')"
  if [ -z "$pkg" ]; then
    continue
  fi

  # 1. Remove the package="..." attribute from the manifest.
  perl -0pi -e 's/\s*package="[^"]+"//g' "$manifest"
  # Collapse a <manifest ...>\n> pattern that can appear after removal.
  perl -0pi -e 's/<manifest([^>]*?)\s*\n\s*>/<manifest\1>/g' "$manifest"

  # 2. Add namespace to build.gradle if not already present.
  if ! grep -Eq "^[[:space:]]*namespace[[:space:]]+['\"]" "$bgradle"; then
    if grep -q 'android[[:space:]]*{' "$bgradle"; then
      perl -0pi -e "s/(android\s*\{)/\$1\n    namespace '$pkg'/" "$bgradle"
    fi
  fi

  echo "  patched: $name (namespace=$pkg)"
  patched=$((patched+1))
done < "$PLUGINS_FILE"

echo ">> Done. Patched $patched plugin(s)."
