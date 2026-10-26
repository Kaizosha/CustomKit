# Verification record

Verified on October 26, 2026 with Xcode 27, Swift 6.4, and iOS 27 simulators.

## Element cleanup, build 2

| Check | Result | Evidence |
| --- | --- | --- |
| All 21 element destinations, customization sheets, and usage pages | Passed | `/tmp/customkit-elements-ui.log` |
| Individual button roles, live label edits, switcher, segments, startup action, credits, and native detents | Passed | `/tmp/customkit-elements-ui.log` |
| Pull to clear, empty state, restoration, local playback, caption seeking, and Files presentation | Two focused tests passed | `/tmp/customkit-elements-focused.log` |
| Dark slider navigation and final TL;Pinch and Skeleton startup views | Passed | `/tmp/customkit-elements-final-r2.log` |
| Independent source and screenshot review | Passed after correcting slider title contrast | `/tmp/customkit-elements-screens`, `/tmp/customkit-elements-final-screens` |
| TestFlight delivery | CustomKit 1.0 (2) reports Testing in Kon's Testing; one tester and two builds | `/tmp/customkit-build2-testing.png` |
| Signed device archive | CustomKit 1.0 (2), company team `564DV375U4`; signature verified | `/tmp/CustomKit-1.0-2-final.xcarchive`, `/tmp/customkit-elements-archive-final.log` |
| REA inspection of the final device binary | arm64, iOS 27; Mach-O, dependencies, and dispatch inspected | `/tmp/customkit-elements-rea-final` |

Eight distinct UI test methods passed across the full and focused runs. The initial pull test began at screen y105 inside the navigation bar, which ended at y116. Moving its start into the conversation made the same clear-and-restore assertions pass. The production pull gesture did not change.

The slider test uses the observed accessibility type `Other` for its UIKit control. Fresh screenshots show the original rail and knob with a readable navigation title. REA remains supplementary binary evidence and does not establish visual behavior or physical haptic feel.

## Initial release checks

| Check | Result | Evidence |
| --- | --- | --- |
| Package behavior | 31 tests passed | `/tmp/customkit-package-final.log` |
| All 16 catalog entries, customization sheets, and usage sheets | Passed on iPhone 17 Pro | `/tmp/customkit-ui-tests-r3.log` |
| Queue actions, reading switcher, start navigation, credits, real local playback, caption seeking, and pull-to-clear | Five UI tests passed | `/tmp/customkit-ui-tests-r3.log` |
| Live customization and native sheet detent expansion | Passed on iPhone and iPad Pro | `/tmp/customkit-live-r2.log`, `/tmp/customkit-ipad-live-r2.log` |
| iPad playback, caption seeking, start navigation, and credits | Two UI tests passed | `/tmp/customkit-ipad-final.log` |
| Release simulator build | Passed | `/tmp/customkit-release-final.log` |
| Original slider implementation | All five moved files match their original Git contents | `Sources/CustomKit/Controls/Slider` |
| Independent source and screenshot review | No blocking findings | Review by `gpt-6-sol` |
| Signed iOS archive | CustomKit 1.0 (1), `org.kaizosha.CustomKit`, company team `564DV375U4` | `/tmp/customkit-archive.log`, `/tmp/CustomKit-1.0-1.xcarchive` |
| Independent release review | Signing verified; icon and privacy resources match source | Review by `gpt-6-sol` |

The first UI run found a parent accessibility identifier that overrode child control identifiers and a row tap beneath the automatic search bar. The final code removes that parent identifier and puts search in the navigation drawer. The full iPhone rerun passed.

The live customization test initially tapped the center of a switch's label and left its value at `1`. Targeting the switch thumb changed it to `0`, hid the native language text, and passed with the original preview implementation. The same check passed on iPad. Its regression test also expands a real native sheet and checks its changed position.

## Initial release REA inspection

REA 6.8.0 inspected the Release simulator app using the native macOS provider. Node 26.12.1 came from the official Node distribution, with its archive checksum verified against the official checksum list. Tooling remained outside the repository.

The Mach-O inventory reported arm64, the iOS Simulator platform, and minimum OS 27.0. The dependency graph reported complete parsing of admitted images and no graph findings. Both CustomKit and Sekai Metal libraries were present in the app. Full evidence from the final Release build is in `/tmp/customkit-rea-final`.

REA metadata inspection is partial for generic and resilient Swift metadata, unresolved external relative pointers, and some ivar offsets. The dependency graph does not evaluate system libraries outside the analyzed app root, signing policy, or every dynamic load. These inspections support the build inventory; they do not prove UI behavior.

## Remaining sensory check

Simulator checks cannot establish the feel of vibration. Presentation, detent, button, logo, slider, and pull feedback still need a physical iPhone sensory check.

Run `Scripts/verify.sh SIMULATOR_ID` to repeat the package and catalog checks. Run `Scripts/inspect-with-rea.sh APP NODE REA_CLI OUTPUT_DIRECTORY` to repeat binary inspection. Test screenshots live in the result bundles. The local decision trail is `.audit/catalog.tsv`.
