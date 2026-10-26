# Verify KaizoshaUIKit

The reset contains one component, Kaizosha Logo. Existing tests and evidence for removed experiments do not establish verification of this build.

Run `Scripts/verify.sh SIMULATOR_ID` with Xcode 27 selected. Package tests cover importable API, reduced-motion response, elastic bounds, haptic travel tracking, light orientation, bounded sensor input, and motion-source lifecycle. The UI suite checks the one-item list, direct drag and return, live customization, reset, and usage code.

The UI suite saves screenshots named `kaizosha-uikit-list`, `kaizosha-logo`, `kaizosha-logo-customized`, `kaizosha-logo-after-drag`, and `kaizosha-logo-usage`.

Physical tilt and tactile feel require an available iPhone or iPad. Simulator motion-source tests establish lifecycle and input handling, not the physical sensation.

Run `Scripts/inspect-with-rea.sh APP NODE REA_CLI OUTPUT_DIRECTORY` for supplementary Mach-O and native metadata inspection. Binary inspection does not establish visual parity or interaction behavior.

Build, runtime, and distribution results for this reset must be recorded after they run.
