# CustomKit

Reusable SwiftUI details from Kaizōsha's apps, with an interactive catalog to try them.

The catalog has 16 working examples. Each opens a live preview, its own customization sheet, reset controls, and copyable usage code.

## Run the catalog

Open [CustomKitCatalog.xcodeproj](Examples/CustomKitCatalog/CustomKitCatalog.xcodeproj) in Xcode 27. Choose the **CustomKitCatalog** scheme and an iOS 27 simulator.

The example project expects these repositories beside CustomKit:

- `KaizoshaPlayerKit` supplies real local video playback.
- `KaizoshaCaptionKit` supplies subtitle segments and display modes.
- `Sekai` supplies the native Metal globe.

The app bundles a 12-second silent Kaizōsha motion study. PlayerKit can also open a movie chosen from Files. The caption example has a local timed bilingual transcript. Sekai renders a real globe with city markers, a connecting arc, rotation, zoom, and appearance controls.

The public `CustomKit` package has no external package dependencies. You can import the components without the catalog or the other kits.

The shipping app uses `org.kaizosha.CustomKit` on Kaizōsha's company team. See [TestFlight distribution](Documentation/Distribution.md) for archive and upload steps.

## Use the components

Add this repository as a local Swift package. Choose the `CustomKit` product for your app. Choose `CustomKitCatalog` to embed the interactive catalog.

```swift
import CustomKit
import SwiftUI

StartExperience(
	configuration: .together,
	onPrimaryAction: { openLibrary() },
	onControls: { showControls() }
)

KaizoshaLogo(configuration: .init(size: 160, interactive: true))

Button("Add clip", systemImage: "plus") { addClip() }
	.customKitButton(.primary, tint: .teal)

KitSwitcher(selection: $translation, title: "Live translation")

KitSegmentedControl(selection: $mode, options: [
	KitSegment("Original", value: "original"),
	KitSegment("Both", value: "both")
])

content.hapticSheet(isPresented: $showCredits, detents: [.large]) {
	MadeByKaizosha(appName: "Together", purpose: "Bring worlds together.")
}

PullToClear(isEmpty: messages.isEmpty, onClear: { messages.removeAll() }) {
	ConversationRows(messages: messages)
}
```

Your app owns actions, data, persistence, and engine lifecycle. CustomKit owns the visual behavior. `CustomKit.Slider` is the original discrete, drag-only capsule slider. Its existing API and behavior are preserved.

## Find a component

| Folder | Public API |
| --- | --- |
| `Branding` | `KaizoshaLogo`, `LogoConfiguration` |
| `Launch` | `LaunchAnimation`, `LaunchConfiguration`, `StartTemplate`, `StartExperience`, `StartConfiguration` |
| `Controls` | `KitButtonStyle`, `KitButtonRole`, `KitSwitcher`, `KitSegmentedControl`, `KitSegment`, `Slider`, `SliderStyle`, `SliderDirection` |
| `Lists` | `LiquidListRow` |
| `Sheets` | `hapticSheet`, `MadeByKaizosha` |
| `Playback` | `PlaybackControls` |
| `Captions` | `CaptionCue`, `CaptionOverlay`, `CaptionTranscript` |
| `Interaction` | `PullToClear` |

Components live in `Sources/CustomKit`. Catalog previews and customization forms live in `Sources/CustomKitCatalog`. Real kit integrations and the movie fixture live in `Examples/CustomKitCatalog`.

See [the component reference](Documentation/Components.md) for behavior and customization. See [the design notes](Documentation/Design.md) for source provenance and package boundaries.

## Verify changes

Use Xcode 27 and iOS 27. This package imports UIKit and requires an iOS destination.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -scheme CustomKit-Package \
  -destination 'platform=iOS Simulator,id=YOUR_SIMULATOR_ID' test

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild -project Examples/CustomKitCatalog/CustomKitCatalog.xcodeproj \
  -scheme CustomKitCatalog \
  -destination 'platform=iOS Simulator,id=YOUR_SIMULATOR_ID' \
  -parallel-testing-enabled NO test
```

The UI suite opens all 16 entries, checks every customization sheet and usage sheet, and exercises queue actions, welcome navigation, local playback, caption seeking, and pull-to-clear. It saves screenshots in the test result bundle.

After adding example app files, run `python3 Scripts/generate-example-project.py`. The generated project is checked in, so XcodeGen is not required. `Scripts/generate-sample.py` reproduces the motion study using Pillow and FFmpeg.

Vibration needs a physical device for a sensory check. Simulator tests verify state and native presentation.

## License

Developed by Kaizōsha and Kaizō Konpaku. Available under the [MIT License](LICENSE).
