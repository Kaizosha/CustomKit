#!/bin/bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: Scripts/inspect-with-rea.sh APP NODE REA_CLI OUTPUT_DIRECTORY" >&2
  exit 2
fi

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
app_path=$1
node_path=$2
rea_path=$3
evidence_dir=$4
mkdir -p "$evidence_dir"
binary_name=$(/usr/libexec/PlistBuddy -c 'Print CFBundleExecutable' "$app_path/Info.plist")
"$node_path" "$rea_path" inspect-macho "$app_path" --format json > "$evidence_dir/macho.json"
"$node_path" "$rea_path" trace-dylib-resolution "$app_path" --format json > "$evidence_dir/dylibs.json"
"$node_path" "$rea_path" inspect-native-dispatch-metadata "$app_path/$binary_name" \
  --max-records 5000 --format json > "$evidence_dir/dispatch.json"
echo "REA native inspection evidence: $evidence_dir"
