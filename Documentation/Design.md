# KaizoshaUIKit design

The package exports one library, `KaizoshaUIKit`. Components live in `Sources/KaizoshaUIKit`. The private example app lives in `Examples/KaizoshaUIKit`. It presents one ordered list and one element per destination.

The catalog contains the seven requested components in order. The former catalog and media integrations were removed. Git history preserves earlier work. Public components are grouped into Branding, Sheets, Controls, and Layouts. The gallery has no exported product.

## Together source

The canonical sources are in the sibling Together repository:

- `Together/Features/Video/Captions/Controls/ControlsKaizoshaLogo.swift` owns direct drag and release behavior.
- `Together/Shared/UI/KaizoshaLogoArtwork.swift` owns the three pillars and 改造社 geometry.
- `KaizoshaGlassMark.swift` and `KaizoshaLogo.metal` own the resting and drag-driven finish.
- `KaizoshaLogoInteraction.swift` and `KaizoshaLogoInteractionPolicy.swift` own elastic response and release velocity.
- `KaizoshaLogoLighting.swift` owns bounded gravity samples, orientation mapping, and lifecycle.
- `KaizoshaLogoHaptics.swift` owns accumulated finger travel and view-attached native generators.

The extraction adds typed configuration and package resource lookup through `ShaderLibrary.bundle(.module)`. It starts motion with view appearance instead of depending on Together's scroll-visibility callback. Launch-sheet travel and singularity behavior are outside this component. Credits navigation is supplied by the consuming app rather than importing Together feature state.

Motion and haptic owners retain Together's explicit synchronous destructors. The visible component owns explicit stop and invalidation.

## Shipping identity

The display name and source module are KaizoshaUIKit. The shipping bundle identifier remains `org.kaizosha.CustomKit` so existing TestFlight installations receive the renamed app as an update.

## Controls and layouts

The credits sheet comes from `TogetherCreditsSheet.swift`, retaining its exact default copy and justified UIKit text renderer. The unlock action comes from `TogetherSubscriptionHomeControl.swift` and `TogetherSegmentedControl.swift`. The strategy pill and native selector come from `TranslationStrategyBottomControl.swift` and `AppleIntelligenceTranslationSupport.swift`. Source and Translate come from `VideoLanguageSelectionSheet.swift`. Masonry geometry follows `VideoHomeGeometry.swift`, `VideoImportGridMetrics.swift`, and `ImportVideoCardGeometry.swift`.

The extraction keeps host state at the public boundary. Purchase state, translation engines, hardware checks, and playback sessions remain with consuming apps. The standalone Low/High selector uses readable label-colored text; its on-glass preset retains Together's on-accent foreground.

A private `ComponentPage` owns the navigation customization button and native sheet. It reserves visible space above a medium sheet for the live component. Masonry uses a scrollable canvas. No gallery narrative or configuration controls appear on the component canvas.
