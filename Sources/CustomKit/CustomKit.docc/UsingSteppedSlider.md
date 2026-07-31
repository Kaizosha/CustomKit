# Using SteppedSlider

Bind a value to a finite set of tactile, equally spaced positions.

## Overview

``SteppedSlider`` is a horizontal SwiftUI control backed by UIKit. It presents
a capsule rail, progress fill, stop dots, and a circular thumb. It is designed
for small sets of discrete choices such as playback rate, intensity, zoom, or
quality.

The slider is local and state-light. It reads and writes a binding but does not
persist the selected value or attach product meaning to it.

## Create a Slider

Provide a binding, a collection of stops, and accessible descriptions:

```swift
struct SpeedPicker: View {
    @State private var speed = 1.0

    var body: some View {
        SteppedSlider(
            value: $speed,
            stops: [0.5, 1, 1.25, 1.5, 2],
            accessibilityLabel: "Playback speed",
            accessibilityValue: { "\($0.formatted())×" }
        )
        .padding()
        .background(.black, in: .rect(cornerRadius: 20))
    }
}
```

The default white appearance is designed for dark media surfaces. Supply a
``SteppedSliderStyle`` with semantic colors when placing the control on a
system background.

CustomKit filters non-finite values, removes duplicate stops, and sorts the
result. The control displays the nearest valid stop, and a user adjustment
writes that stop to the binding. If no finite stop remains, the current bound
value becomes the sole fallback stop.

Stops describe ordered choices, not a continuous scale. Their visual positions
are equally spaced by index. For example, `[0, 1, 10]` renders `1` at the
center even though its numeric distance from the other values is unequal.

## Customize Presentation

Create a ``SteppedSliderStyle`` and pass it through `style:` to customize the
rail, progress fill, dots, thumb, dimensions, shadow, animation, and feedback.
Keep the defaults when the host only needs tint-level adaptation.

```swift
let sliderStyle = SteppedSliderStyle(
    trackColor: .secondary.opacity(0.24),
    fillColor: .mint,
    knobColor: .mint,
    restingRailHeight: 36,
    activeRailHeight: 44
)

SteppedSlider(
    value: $intensity,
    stops: intensityStops,
    style: sliderStyle,
    accessibilityLabel: String(localized: "Intensity"),
    accessibilityValue: { $0.formatted(.percent) }
)
```

Visual customization does not change stop normalization, selection, editing,
or accessibility behavior. Maintain sufficient contrast and touch-target size
when creating a custom style.

## Choose a Direction

The default ``SteppedSliderDirection`` keeps lower values on the left, matching
the original design. Pass `.automatic` to follow the interface layout direction
or use an explicit direction when the underlying concept has an inherent
mapping.

```swift
SteppedSlider(
    value: $value,
    stops: stops,
    direction: .automatic,
    accessibilityLabel: label,
    accessibilityValue: formatValue
)
```

Direction affects both presentation and drag mapping. Test explicit directions
with right-to-left localization rather than reversing the stop array.

## Observe Editing

Use `onEditingChanged` to coordinate temporary interface state:

```swift
SteppedSlider(
    value: $value,
    stops: stops,
    accessibilityLabel: label,
    accessibilityValue: formatValue,
    onEditingChanged: { isEditing in
        controlsAreActive = isEditing
    }
)
```

The callback becomes `true` after movement activates a drag and returns to
`false` when tracking ends or is cancelled. A tap does not begin editing, and
a programmatic binding update does not invoke the callback.

Treat cancellation as a normal editing end. The binding remains the source of
truth for the current snapped value.

## Support Accessibility

Supply a localized `accessibilityLabel` that names the setting and an
`accessibilityValue` closure that speaks the selected stop in context.
VoiceOver treats a slider with multiple stops as adjustable and moves exactly
one stop for each increment or decrement. A one-stop fallback is announced as
a static value.

The package owns adjustable-control mechanics. The host remains responsible
for:

- Localized label and value wording.
- Sufficient contrast after style customization.
- Nearby instructions when stop meanings are not evident.
- Validation with VoiceOver, Larger Text, Increased Contrast, Reduce
  Transparency, and Reduce Motion.

## Understand Interaction

The control changes only through a drag or an accessibility adjustment. It does
not jump on tap. Horizontal travel selects stops; moving vertically away from
the rail reduces sensitivity for finer adjustment. Haptic selection feedback
occurs when the value crosses a stop when feedback is enabled by the style.

The slider is horizontal, discrete, and iOS/iPadOS-only. It does not provide a
continuous range, individual stop labels, persistence, networking, or a
macOS/Catalyst implementation.

## Validate an Integration

Use Xcode 27 with an iOS or iPadOS 27 destination. Run package tests, then
exercise the customized control in its host layout on iPhone and iPad. Cover:

- First, middle, and last stops.
- Drag cancellation and fine adjustment.
- Automatic and explicit layout direction.
- VoiceOver increment and decrement.
- Light and dark appearance plus accessibility display settings.
- Rotation, Split View, and Stage Manager.
