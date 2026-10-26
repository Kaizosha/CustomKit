#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: Scripts/verify.sh SIMULATOR_ID" >&2
  exit 2
fi

cd "$(dirname "$0")/.."
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
verification_dir=$(mktemp -d /tmp/kaizosha-uikit-verify.XXXXXX)
python3 Scripts/generate-example-project.py
xcodebuild -scheme KaizoshaUIKit \
  -destination "platform=iOS Simulator,id=$1" \
  -derivedDataPath "$verification_dir/package" \
  -resultBundlePath "$verification_dir/package.xcresult" test \
  > "$verification_dir/package.log" 2>&1
xcodebuild -project Examples/KaizoshaUIKit/KaizoshaUIKit.xcodeproj \
  -scheme KaizoshaUIKit \
  -destination "platform=iOS Simulator,id=$1" \
  -derivedDataPath "$verification_dir/app" \
  -resultBundlePath "$verification_dir/gallery.xcresult" \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test \
  > "$verification_dir/gallery.log" 2>&1
echo "Package and gallery tests passed. Evidence: $verification_dir"
