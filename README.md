# KaizoshaUIKit

Reusable native components from Kaizōsha's apps. The example app has a plain ordered list. Each destination presents its component and one navigation-bar button that opens live customization, reset, and copyable usage code.

## Add to your app

Add `https://github.com/Kaizosha/KaizoshaUIKit` as a Swift package dependency and select the **KaizoshaUIKit** product. The package, product, and import module all use that name. Requires Xcode 27, Swift 6.4, and iOS 27.

```swift
import KaizoshaUIKit

KaizoshaLogo()
```

The package exports these components in catalog order:

| Catalog item | Public component | Customization |
| --- | --- | --- |
| Kaizosha Logo | `KaizoshaLogo` | `LogoConfiguration` |
| Made by Kaizosha | `MadeByKaizosha` | `CreditsConfiguration` |
| Unlock Together | `UnlockTogetherControl` | `UnlockTogetherConfiguration` |
| Translation Strategy Pill | `TranslationStrategyPill` | `TranslationStrategyPillConfiguration` |
| Language Switcher | `LanguageSwitcher` | Width and titles |
| Low/High Switcher | `TranslationStrategySwitcher` | `TranslationStrategySwitcherConfiguration` |
| Masonry Layout | `MasonryGrid` or `MasonryLayout` | Column width, insets, and spacing |

```swift
import KaizoshaUIKit
import SwiftUI

struct LanguageControls: View {
	@State private var role = LanguageRole.source
	@State private var strategy = TranslationStrategy.lowLatency

	var body: some View {
		VStack {
			LanguageSwitcher(selection: $role)
			TranslationStrategyPill(selection: $strategy)
		}
	}
}
```

Your app owns bindings, actions, translation availability, and presentation. Components do not depend on Together sessions, purchases, media engines, or sibling repositories. Metal resources are bundled with the package.

For device lighting on the logo, add `NSMotionUsageDescription` to your app's Info.plist. See [component reference](Documentation/Components.md) for configuration and default behavior.

## Run the example

Open [KaizoshaUIKit.xcodeproj](Examples/KaizoshaUIKit/KaizoshaUIKit.xcodeproj) and choose the **KaizoshaUIKit** scheme.

Run `python3 Scripts/generate-example-project.py` after changing example files. The generated project is checked in.

## Verify changes

Run `Scripts/verify.sh SIMULATOR_ID` on an iOS 27 simulator. It runs package and gallery UI tests and retains screenshots in result bundles. See [verification](Documentation/Verification.md) and [TestFlight delivery](Documentation/Distribution.md).

## License

Developed by Kaizōsha and Kaizō Konpaku. Available under the [MIT License](LICENSE).
