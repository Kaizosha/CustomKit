# ``CustomKit``

@Metadata {
    @DisplayName("Kaizōsha’s CustomKit")
}

Build tactile, native-feeling SwiftUI controls for iOS and iPadOS.

## Overview

CustomKit contains reusable branding, launch templates, native glass controls,
haptic sheets, caption views, playback controls, and pull-to-clear interactions.
Each component takes host-owned values and callbacks. The separate CustomKitCatalog
product provides interactive examples and customization sheets.

```swift
@State private var value = 1.0

CustomKit.Slider(
    value: $value,
    stops: [0.5, 1, 1.25, 1.5, 2],
    accessibilityLabel: "Playback speed",
    accessibilityValue: { "\($0.formatted())×" }
)
```

The package performs no networking, analytics, or persistence. The host
application owns the meaning, storage, localization, and formatting of each
value.

Developed by Kaizōsha and created by Kaizō Konpaku.

## Topics

### Essentials

- <doc:UsingSlider>

### Controls

- ``Slider``
- ``KitButtonStyle``
- ``KitSwitcher``
- ``KitSegmentedControl``
- ``LiquidListRow``

### Branding and presentation

- ``KaizoshaLogo``
- ``LaunchAnimation``
- ``StartTemplate``
- ``StartExperience``
- ``MadeByKaizosha``
- ``PullToClear``

### Media

- ``PlaybackControls``
- ``CaptionCue``
- ``CaptionOverlay``
- ``CaptionTranscript``

### Configuration

- ``SliderStyle``
- ``SliderDirection``
