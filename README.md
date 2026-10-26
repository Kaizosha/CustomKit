# KaizoshaUIKit

Reusable native UI from Kaizōsha's apps, added one component at a time.

The catalog currently contains one item, **Kaizosha Logo**. Its screen presents the logo and a navigation-bar customization button. All adjustment controls, reset, and usage code live inside the sheet.

## Use the logo

Add this repository as a Swift package and select the `KaizoshaUIKit` product. The package requires Xcode 27, Swift 6.4, and iOS 27.

```swift
import KaizoshaUIKit

KaizoshaLogo()

KaizoshaLogo(configuration: LogoConfiguration(
	size: 200,
	interactive: true,
	hapticsEnabled: true,
	motionEnabled: true,
	refraction: 1
))
```

`LogoConfiguration` also accepts a manual `lightDirection` when device lighting is disabled. An optional `onOpenCredits` callback adds long-press and VoiceOver credits actions. Without that callback the logo has no credits action.

When enabling device lighting, add `NSMotionUsageDescription` to your app's Info.plist with a description of how motion lights the logo. The example app includes this description.

The default mark uses the canonical 160 by 151-point artwork. Direct dragging, the release-velocity spring, and accumulated-travel haptics come from Together. Metal resources belong to the package. Your app does not need to copy shaders into its own default library.

## Run the example

Open [KaizoshaUIKit.xcodeproj](Examples/KaizoshaUIKit/KaizoshaUIKit.xcodeproj) and choose the **KaizoshaUIKit** scheme. The project links only this package. It does not require any sibling repository or media engine.

Run `python3 Scripts/generate-example-project.py` after changing example files. The generated project is checked in.

## Verify changes

Run `Scripts/verify.sh SIMULATOR_ID` from the checkout root. It runs package tests and the example app's UI tests on an iOS 27 simulator. The UI tests check the one-item list, dragging, live sizing, reset, and usage code, and preserve screenshots in the result bundle.

The simulator cannot verify physical device tilt or how haptics feel. See [verification](Documentation/Verification.md), [design](Documentation/Design.md), and [TestFlight delivery](Documentation/Distribution.md).

## License

Developed by Kaizōsha and Kaizō Konpaku. Available under the [MIT License](LICENSE).
