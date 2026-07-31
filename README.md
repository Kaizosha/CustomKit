# Kaizōsha’s CustomKit

CustomKit is a focused collection of native-feeling SwiftUI controls for iOS
and iPadOS. Its first control is `SteppedSlider`, a tactile capsule slider for
choosing from a finite set of values.

Developed by Kaizōsha and created by Kaizō Konpaku.

- Kaizōsha: [kaizosha.org](https://kaizosha.org)
- Organization: [github.com/Kaizosha](https://github.com/Kaizosha)
- Author: [Kaizō Konpaku](https://x.com/kaizookonpaku)

CustomKit works entirely on device. It has no network behavior, analytics,
persistence, external assets, or third-party package dependencies.

## Requirements

- Swift 6.4
- Xcode 27 or newer
- iOS 27 or iPadOS 27

CustomKit does not support macOS, Mac Catalyst, tvOS, watchOS, or visionOS.

## Installation

In Xcode, choose **File > Add Package Dependencies** and enter:

```text
https://github.com/Kaizosha/CustomKit.git
```

Select version `0.1.0` or newer, then add the `CustomKit` library to the app
target.

For a Swift package, add:

```swift
dependencies: [
    .package(
        url: "https://github.com/Kaizosha/CustomKit.git",
        from: "0.1.0"
    )
]
```

Then add `.product(name: "CustomKit", package: "CustomKit")` to the consuming
target.

## Minimal Use

```swift
import CustomKit
import SwiftUI

struct PlaybackSpeedControl: View {
    @State private var value = 1.0

    var body: some View {
        SteppedSlider(
            value: $value,
            stops: [0.5, 1, 1.25, 1.5, 2],
            accessibilityLabel: "Playback speed",
            accessibilityValue: { "\($0.formatted())×" }
        )
        .padding()
        .background(.black, in: .rect(cornerRadius: 20))
    }
}
```

The original white appearance is designed for a dark media surface, as shown
above. On a normal system background, use semantic colors through
`SteppedSliderStyle`; the customization example below is a ready-made starting
point for light and dark appearances.

`SteppedSlider` filters invalid values, removes duplicates, and sorts its stops.
Each remaining stop receives equal visual spacing: `[0, 1, 10]` places `1` in
the center rather than one tenth of the way across the rail. The control
displays the nearest stop, and a user adjustment writes that stop to the
binding.

Selection is drag-only. A tap does not jump the value. Moving vertically away
from the rail enables finer horizontal adjustment, while crossing a stop
provides selection feedback.

## Customization

Pass a `SteppedSliderStyle` with `style:` to customize the rail, fill, stop
dots, thumb, dimensions, shadow, animation, and feedback while preserving the
same interaction behavior. The default keeps lower values on the left, matching
the original design. Pass `.automatic` or `.rightToLeft` through `direction:`
when the host should mirror or explicitly reverse the mapping.

Only name the values that should differ from the default:

```swift
let sliderStyle = SteppedSliderStyle(
    trackColor: .secondary.opacity(0.24),
    fillColor: .mint,
    knobColor: .mint,
    restingRailHeight: 36,
    activeRailHeight: 44
)
```

The accessibility label describes the setting, and the accessibility value
closure describes the selected value. Supply localized text from the host app:

```swift
SteppedSlider(
    value: $value,
    stops: availableValues,
    style: sliderStyle,
    direction: .automatic,
    accessibilityLabel: String(localized: "Intensity"),
    accessibilityValue: { value in
        value.formatted(.percent)
    },
    onEditingChanged: { isEditing in
        interactionIsActive = isEditing
    }
)
```

VoiceOver exposes a control with multiple stops as adjustable and moves one
stop at a time. A one-stop fallback is announced as a static value.
`onEditingChanged` reports `true` after a drag becomes active and `false` when
the interaction ends or is cancelled. Programmatic binding updates do not
start an editing session.

## Behavior and Limitations

- The control is horizontal and UIKit-backed, with a SwiftUI public API.
- Stops are discrete, sorted, and equally spaced; continuous ranges are not
  supported.
- Provide at least one finite stop. Invalid and duplicate stops do not create
  positions; if none remain, the current bound value becomes the sole fallback
  stop.
- Dragging changes the selection; tapping the rail intentionally does not.
- The host owns value meaning, formatting, localization, and persistence.
- Custom styles should retain a comfortable touch target and sufficient
  contrast in every system appearance.
- CustomKit does not render labels for individual stops. Place explanatory
  content next to the slider when the values are not self-evident.

## Validation

Before shipping a customized slider:

1. Build the host app with Xcode 27 for iPhone and iPad.
2. Exercise every stop in left-to-right and right-to-left layouts.
3. Verify VoiceOver increment, decrement, label, and value announcements.
4. Check light and dark appearance, Increased Contrast, Reduce Transparency,
   and Reduce Motion.
5. Test touch cancellation, compact layouts, rotation, Split View, and Stage
   Manager.
6. Run the package tests and the host app’s focused UI tests.

Because CustomKit imports UIKit, validate it with an iOS or iPadOS destination
rather than treating a macOS command-line build as platform coverage.

## Documentation

Open the package documentation in Xcode for the complete `SteppedSlider`
behavior and customization contract.

## License

CustomKit is available under the [MIT License](LICENSE).
