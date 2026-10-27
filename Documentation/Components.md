# Component reference

## Kaizosha Logo

Import `KaizoshaInterfaceKit` and instantiate `KaizoshaLogo(configuration:onOpenCredits:)`.

`LogoConfiguration` provides the following values:

| Value | Default | Behavior |
| --- | --- | --- |
| `size` | 160 | Artwork width in points. The canonical 160:151 aspect ratio remains unchanged. |
| `interactive` | true | Enables direct dragging and elastic return. |
| `hapticsEnabled` | true | Enables tactile travel and release feedback. |
| `motionEnabled` | true | Follows device tilt while the component is visible and active. |
| `refraction` | 1 | Multiplies drag-driven refraction from 0 through 2. The resting canonical finish remains applied. |
| `lightDirection` | (-0.22, -0.32) | Manual shader lighting when device tilt is disabled. |

The optional `onOpenCredits` closure enables a 0.6-second long press and a VoiceOver Open Credits action. The consuming app owns the destination. Omitting the closure removes both actions.

Apps using device lighting include `NSMotionUsageDescription` in their Info.plist. Together and the example app both provide that purpose string.

Reduce Motion limits displacement and removes deformation and device lighting. Reduce Transparency removes shader effects and the shadow. Device lighting stops when the view disappears, the scene becomes inactive, or the corresponding configuration is disabled. Haptic generators detach when the view disappears or haptics are disabled.

The example app owns its ordered list, navigation, customization forms, and usage-code view. None of those gallery types are exported by the package.

## Made by Kaizosha

`MadeByKaizosha(configuration:)` is the complete native credits sheet. `CreditsConfiguration.together` preserves Together's title, two paragraphs, serif title, justified monospaced body, static Metal mark, and red close button. Configuration exposes `title`, `paragraphs`, `showsLogo`, and `logoSize`. Paragraphs support **bold** and *italic* emphasis. Present it with `.sheet`.

## Unlock Together

`UnlockTogetherControl(isUnlocked:configuration:action:)` is the native single-segment action. Its defaults are `Unlock Together`, `Together x You`, and system orange. The callback runs on every activation, including repeated taps, keyboard activation, and VoiceOver activation. The host owns unlock state and purchase behavior.

## Translation Strategy Pill

`TranslationStrategyPill(selection:isHighFidelityAvailable:configuration:onUnavailableHighFidelitySelection:)` combines the glass capsule, information popover, and native Low/High selector. `TranslationStrategyPillConfiguration` exposes `tint`, `isCompact`, `status`, `detail`, and `comparison`. Expanded and compact heights start at 66 and 46 points. Accessibility text sizes use a vertical arrangement. The host supplies availability and explanatory status.

## Language Switcher

`LanguageSwitcher(selection:width:sourceTitle:translationTitle:)` binds `LanguageRole.source` or `.translation`. The native segmented picker defaults to Source and Translate at 210 points wide.

## Low/High Switcher

`TranslationStrategySwitcher(selection:isEnabled:isHighFidelityAvailable:configuration:onUnavailableHighFidelitySelection:)` binds `TranslationStrategy.lowLatency` or `.highFidelity`. It defaults to 128 by 28 points. Low uses the label color; High uses system orange. Configuration exposes normal and selected foreground colors, both selected tints, width, and height. `.onGlass` supplies Together's foreground colors for placement on the tinted pill.

Tapping unavailable High leaves the current selection unchanged and invokes the unavailable callback. Availability does not silently change a host-supplied High selection. Disabling the view disables both segments.

## Masonry Layout

`MasonryGrid` measures children at the available column width and places each in the shortest column. Defaults are 20-point horizontal insets and 16-point row and column gaps. Automatic minimum column width is 148 points, or 260 at accessibility text sizes. Reading direction mirrors physical columns while preserving data order. Explicit `minimumColumnWidth` overrides automatic sizing.

`MasonryLayout` exposes the same geometry as a SwiftUI `Layout` for direct composition. It accepts an explicit `layoutDirection`; the `MasonryGrid` wrapper reads it from the environment. Each child owns its aspect ratio and padding. A six-point child inset reproduces Together's media-card proportions without importing its playback or thumbnail state.

## Native Glass Button

Apply `.kaizoshaGlassButtonStyle(_:)` to a native `Button`, or to a native `Menu`
using `.menuStyle(.button)`. `NativeGlassButtonConfiguration` contains:

| Value | Default | Behavior |
| --- | --- | --- |
| `surface` | `.prominent` | Native prominent or regular glass. |
| `tint` | `.accentColor` | The enabled surface tint. |
| `borderShape` | `.capsule` | Native border shape; label size and control size stay with the caller. |

Prominent labels use the adaptive system-background foreground inside the native
label: light in Light appearance and dark in Dark appearance, matching Done.
Unavailable prominent controls use the native confirmation rendering role and
app accent, including when an ancestor disables them. They remain truly disabled.
Re-enabling restores the supplied role and tint. This intentionally normalizes
the role only while unavailable, including close and destructive roles. Regular
glass preserves its native foreground and supplied tint without this adaptation.

Roles, actions, labels, accessibility, `.controlSize`, `.disabled`, and symbol
effects remain native SwiftUI responsibilities. The component adds no custom
material, opacity simulation, tap handling, or forced enabled environment.

```swift
Menu("Actions", systemImage: "ellipsis") {
    Button("Select All", action: selectAll)
    Button("Remove", role: .destructive, action: remove)
}
.menuStyle(.button)
.kaizoshaGlassButtonStyle(.init(surface: .regular))
```

The gallery provides Primary, Confirm, Help, Reset, Destructive, and Menu presets.
Its customization sheet changes the native label, role, tint, surface, shape,
control size, and local or inherited availability. The visible activation count
proves repeated actions and disabling; Reset restores defaults. The usage screen
contains the current configuration followed by ready-to-use examples.
