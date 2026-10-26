# Deliver CustomKit to TestFlight

The shipping app is **CustomKit**, bundle ID `org.kaizosha.CustomKit`, version `1.0`, build `1`. It uses Kaizōsha's company team `564DV375U4`.

## Create the archive

Keep `CustomKit`, `KaizoshaPlayerKit`, `KaizoshaCaptionKit`, and `Sekai` beside one another. Run these commands from the CustomKit checkout:

```sh
python3 Scripts/generate-example-project.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project Examples/CustomKitCatalog/CustomKitCatalog.xcodeproj \
  -scheme CustomKitCatalog \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/customkit-device-build \
  -archivePath /tmp/CustomKit-1.0-1.xcarchive \
  -allowProvisioningUpdates archive
```

Read the archived app's `Info.plist`, signing identity, and embedded profile before distribution. Confirm the company team, bundle ID, version, and build. The app icon must be present and the privacy manifest must describe the linked code in that archive.

The catalog does not track users or collect data. Its local examples do not directly call Apple's required-reason APIs. The privacy manifest therefore declares no tracking, collected data, or required-reason API categories. The app uses only system encryption and declares `ITSAppUsesNonExemptEncryption=false`. Recheck those declarations when dependencies or behavior change.

## Upload the archive

1. Confirm or create the CustomKit app record in App Store Connect with the exact shipping bundle ID.
2. Open the archive in Xcode Organizer.
3. Choose **Distribute App**, then **TestFlight Internal Only**.
4. Verify the app, company team, version, and build in the distribution summary.
5. Choose **Distribute** and wait for **App Upload Complete**.
6. Wait until processing finishes in App Store Connect.
7. Assign the exact build to the intended private internal group and verify tester access.

The existing Xcode account can use cloud-managed distribution signing. If command-line export cannot use that account, use Organizer rather than changing accounts or revoking certificates.

For an export before upload, use the checked-in options:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -exportArchive \
  -archivePath /tmp/CustomKit-1.0-1.xcarchive \
  -exportPath /tmp/CustomKit-1.0-1-export \
  -exportOptionsPlist Examples/CustomKitCatalog/ExportOptions.plist \
  -allowProvisioningUpdates
```

An exported IPA does not establish upload, processing, group assignment, or installation. Verify those outcomes separately. Physical installation requires the intended iPhone or iPad to be available.

## Regenerate the icon

Run `python3 Scripts/generate-app-icon.py` on macOS with Pillow installed. The generator preserves the canonical three-pillar geometry and 改造社 characters on an opaque background. It writes the 1024-pixel app icon and asset catalog metadata.
