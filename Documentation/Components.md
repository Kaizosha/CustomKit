# Component reference

CustomKit requires Swift 6.4, Xcode 27, and iOS 27. Colors use system appearance unless a caller provides an accent.

## Branding and launch

`KaizoshaLogo(configuration:)` renders the canonical three pillars and 改造社 characters. Its Metal shader is bundled with the package. `LogoConfiguration` exposes size, interactivity, refraction, haptics, and light direction. Dragging stretches and tilts the mark; releasing returns it with a spring. Reduce Motion limits deformation. Reduce Transparency removes the shader finish.

`LaunchAnimation(configuration:onComplete:)` moves opposing chevrons into place. `LaunchConfiguration` exposes duration, symbol size, and haptics. Leaving the view cancels the task and prevents a late completion callback.

`StartTemplate(configuration:onPrimaryAction:onControls:)` renders a welcome screen. `.together`, `.pinch`, and `.skeleton` provide app presets. Customize title lines, subtitle, action label, action symbol, accent, signature, and app name. The Controls button appears when its callback is supplied.

`StartExperience` composes the opening animation and start template. Give it a new SwiftUI identity to replay the sequence. It emits the primary action; the host decides what opens next.

## Controls and lists

`customKitButton(_:tint:surface:)` applies native glass. Roles are primary, neutral, destructive, reset, success, and working. Each role has a semantic tint and a symbol effect. `KitButtonSurface` selects regular or prominent glass independently of the role. The default is prominent. Use `KitButtonStyle(role:tint:hapticsEnabled:surface:)` directly to disable haptics. The host controls loading state and whether an action is enabled.

`LiquidListRow(isSelected:action:content:)` is an actionable glass capsule with a selected wash. The caller supplies its label and accessory. Group neighboring rows in `GlassEffectContainer`.

`KitSwitcher(selection:title:subtitle:tint:)` binds a native toggle to a Boolean. `KitSegmentedControl(selection:options:accessibilityLabel:)` binds a segmented picker to a hashable selection. Each `KitSegment` supplies a title, value, and optional system image. Option values must be unique, and the selection must match an option.

`CustomKit.Slider` takes discrete stops and a bound value. Stops are finite, unique, sorted, and equally spaced. Selection is drag-only. Moving vertically away from the rail allows finer horizontal control. `SliderStyle` customizes geometry, colors, shadow, animation, and haptics. VoiceOver can adjust between stops.

## Sheets and credits

`hapticSheet(isPresented:hapticsEnabled:detents:content:)` uses native presentation. Default detents are medium and large; it starts at medium when available. It uses page sizing on iPad. Presentation and dismissal receive light impact feedback; detent changes receive selection feedback.

`MadeByKaizosha(appName:purpose:details:showsLogo:)` owns the credits layout and a Close button. Present it in a sheet. Its serif title and monospaced body follow the app credits design.

## Playback and captions

`PlaybackControls(isPlaying:position:duration:skipInterval:tint:)` supplies a timeline and transport controls. It clamps user seeking to the duration and disables playback when duration is zero. It does not create a media engine. Connect its bindings to your engine or use the real PlayerKit integration example.

`CaptionCue` contains a stable ID, normalized start and end times, text, and optional translated text. Its interval includes the start and excludes the end. `CaptionTranscript` highlights the current cue and updates the bound playhead when a cue is tapped. Its optional `onSeek` callback lets an engine seek to the same time. `CaptionOverlay` renders primary and translated text over media.

The example app adapts actual `KaizoshaCaptionCore.SubtitleSegment` values. CustomKit does not create speech or translation sessions.

## Pull to clear

`PullToClear(isEmpty:threshold:hapticsEnabled:onClear:content:)` owns a vertical scroll view. Give it rows rather than another scroll view. It starts tracking a downward contact at the top, arms after the threshold, and calls `onClear` once on release. Reversing below the threshold disarms it. Cancellation, scene changes, and empty-state changes reset the contact.

The default threshold is 140 points. An empty collection shows a Nothing cue and never calls `onClear`. VoiceOver provides a Clear contents action. The host decides what data to clear. The catalog clears only its sample conversation.

## Embed the catalog

Import `CustomKitCatalog` and show `CatalogView()`. It includes the core element examples. Pass `additionalEntries:` to append `CatalogEntry` values. Each entry owns its ID, title, source, category, summary, and destination. IDs must be unique.

`ExperimentPage(title:api:preview:controls:)` presents the element and a navigation-bar customization button. Each example owns its layout and local state. Reset controls and usage code live inside the customization sheet. The example app adds the kit entries through this boundary.
