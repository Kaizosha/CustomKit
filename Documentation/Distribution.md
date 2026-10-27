# Deliver KaizoshaUIKit to TestFlight

The display name is **KaizoshaUIKit**. The shipping identity remains `org.kaizosha.CustomKit`, company team `564DV375U4`, App Store Connect app `6827106597`. This reset uses version `1.0`, build `3`. Earlier build `2` remains available in the existing Kon's Testing group until a replacement is uploaded and assigned.

## Create the archive

```sh
python3 Scripts/generate-example-project.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project Examples/KaizoshaUIKit/KaizoshaUIKit.xcodeproj \
  -scheme KaizoshaUIKit \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/kaizosha-uikit-device-build \
  -archivePath /tmp/KaizoshaUIKit-1.0-3-final.xcarchive \
  -allowProvisioningUpdates archive
```

Read the archived app's metadata, verify its signature, and confirm that the bundle ID, team, display name, version, icon, and privacy manifest match the source.

## Upload and assign

1. Use the Codex browser's existing authenticated App Store Connect session when available.
2. Update the app's visible name to KaizoshaUIKit without creating another app record.
3. Open the verified archive in Xcode Organizer and choose TestFlight Internal Only.
4. Wait for upload confirmation and processing.
5. Add the exact version and build to the existing Kon's Testing internal group.
6. Verify that the group reports the build as Testing.

The [TestFlight record](https://appstoreconnect.apple.com/apps/6827106597/testflight) uses the existing app ID. Do not claim upload, group availability, or physical installation from a local archive alone.

## Current build 3 state

Xcode uploaded version 1.0 build 3 successfully on October 27, 2026. App Store Connect shows the upload as Processing. The company account, existing app identity, and internal-only distribution are preserved. Group assignment and Testing availability remain pending processing.

The final archive is `/tmp/KaizoshaUIKit-1.0-3-final.xcarchive`; its verified executable SHA256 is `0ef5559a227101f98373fa41cc57f32dcdd0c2e94bc09da2cfef9e6a60c0de6a`. The upload log is `/tmp/kaizosha-uikit-upload-ready.log` and ends with `Upload succeeded` and `EXPORT SUCCEEDED`.
