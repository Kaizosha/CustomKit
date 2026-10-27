# Verify KaizoshaInterfaceKit

Run `Scripts/verify.sh SIMULATOR_ID` with Xcode 27 selected. The package suite covers the public import, logo motion and drag policies, haptic travel, native control actions and availability, justified credits, and masonry geometry. The gallery suite checks the ordered seven-item list, all customization sheets and usage code, customized credits, native selection, unavailable High, repeated Unlock activation, pill guidance and compact state, masonry proportions, and logo drag return.

UI tests retain screenshots in their result bundle. Use `xcrun xcresulttool export attachments --path RESULT.xcresult --output-path DIRECTORY` to export them.

## Build 3 evidence

These receipts describe the prior KaizoshaUIKit release. Verify the renamed package and build 4 separately.

- Public consumer smoke tests use ordinary `import KaizoshaUIKit` and construct every exported component. Package suite: 28 tests passed in `/tmp/kaizosha-uikit-package-final.xcresult`.
- Complete iPhone gallery suite: eight tests passed in `/tmp/kaizosha-uikit-gallery-verified.xcresult`. The recorded drag visibly moves the logo, then returns it to its anchor. Recording: `/tmp/kaizosha-uikit-interactions.mp4`.
- Dark iPad at accessibility XXXL: native activation, adaptive masonry, guidance, and compact pill checks passed in `/tmp/kaizosha-uikit-ipad-accessibility.xcresult`. The compact info symbol was bounded and rechecked in `/tmp/kaizosha-uikit-ipad-icon-fitted.xcresult`.
- The seven normal screens and customization sheets were visually reviewed. Stacked pill spacing was corrected after that review and rechecked in `/tmp/kaizosha-uikit-pill-fitted.xcresult`.
- Actual repeated native taps now read two activations in the sheet on iPad, with the original Together control implementation. The gallery constructs its element and controls while the parent evaluates its body, so first presentation uses current state. Evidence: `/tmp/kaizosha-uikit-ipad-activation-state.xcresult`.
- Signed device archive: `/tmp/KaizoshaUIKit-1.0-3-final.xcarchive`. Display name KaizoshaUIKit, version 1.0 build 3, bundle `org.kaizosha.CustomKit`, company team `564DV375U4`. Strict code-signature verification passed, and the privacy manifest and package Metal library are present.
- Archived executable SHA256: `0ef5559a227101f98373fa41cc57f32dcdd0c2e94bc09da2cfef9e6a60c0de6a`.
- REA 6.8.0 inspected that exact binary's Mach-O, dylib resolution, and native dispatch metadata. Evidence: `/tmp/kaizosha-uikit-rea-shipping`. REA reports partial Swift conformance and generic/resilient metadata coverage; these results supplement live UI verification.

Physical device tilt and tactile feel remain device checks. Simulator tests verify lifecycle and bounded input, not physical sensation.

Build 3 completed Apple processing and is Testing in Kon's Testing. See [delivery](Distribution.md).

## Repeat native inspection

Run `Scripts/inspect-with-rea.sh APP NODE REA_CLI OUTPUT_DIRECTORY` for supplementary native analysis. Binary inspection does not establish visual parity or interaction behavior.
