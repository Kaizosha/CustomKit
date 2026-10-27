# Deliver KaizoshaInterfaceKit to TestFlight

The display name is **KaizoshaInterfaceKit**. The shipping identity remains `org.kaizosha.CustomKit`, company team `564DV375U4`, App Store Connect app `6827106597`. The next archive uses version `1.0`, build `4`. Build `3`, distributed as KaizoshaUIKit, is available in the existing Kon's Testing group.

## Create the archive

```sh
python3 Scripts/generate-example-project.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project Examples/KaizoshaInterfaceKit/KaizoshaInterfaceKit.xcodeproj \
  -scheme KaizoshaInterfaceKit \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/kaizosha-interfacekit-device-build \
  -archivePath /tmp/KaizoshaInterfaceKit-1.0-4-final.xcarchive \
  -allowProvisioningUpdates archive
```

Read the archived app's metadata, verify its signature, and confirm that the bundle ID, team, display name, version, icon, and privacy manifest match the source.

## Upload and assign

1. Use the Codex browser's existing authenticated App Store Connect session when available.
2. Update the app's visible name to KaizoshaInterfaceKit without creating another app record.
3. Open the verified archive in Xcode Organizer and choose TestFlight Internal Only.
4. Wait for upload confirmation and processing.
5. Add the exact version and build to the existing Kon's Testing internal group.
6. Verify that the group reports the build as Testing.

The [TestFlight record](https://appstoreconnect.apple.com/apps/6827106597/testflight) uses the existing app ID. Do not claim upload, group availability, or physical installation from a local archive alone.

## Build 3 delivery receipt

Version 1.0 build 3, named KaizoshaUIKit, uploaded successfully on October 27, 2026, finished processing, and is assigned to the existing Kon's Testing internal group. App Store Connect reports **Testing** for build 3. The existing app identity and internal-only distribution are preserved.

- Build ID: `ca969bd4-7a71-43d7-9346-4816446d6972`.
- [Build 3 in App Store Connect](https://appstoreconnect.apple.com/teams/437df873-269a-455e-91ee-7dfc8af90cd1/apps/6827106597/testflight/ios/ca969bd4-7a71-43d7-9346-4816446d6972).
- Final archive: `/tmp/KaizoshaUIKit-1.0-3-final.xcarchive`.
- Verified executable SHA256: `0ef5559a227101f98373fa41cc57f32dcdd0c2e94bc09da2cfef9e6a60c0de6a`.
- Successful upload log: `/tmp/kaizosha-uikit-upload-ready.log`.
- Testing status screenshot: `/tmp/kaizosha-uikit-build3-testing.png`.

Physical installation and tactile feel are not established by the distribution status.
