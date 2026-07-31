# ``CustomKit``

@Metadata {
    @DisplayName("Kaizōsha’s CustomKit")
}

Build tactile, native-feeling SwiftUI controls for iOS and iPadOS.

## Overview

CustomKit is a local, dependency-free control library. Its first component,
``Slider``, binds a value to one of several equally spaced stops and
provides drag-only selection, fine adjustment, haptic feedback, accessibility,
layout-direction handling, and focused appearance customization.

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

### Configuration

- ``SliderStyle``
- ``SliderDirection``
