# CustomKit design

The component library contains SwiftUI views, typed configurations, and interaction policies. It has no app sessions, storage, analytics, or external package dependencies. Your apps supply bindings and callbacks.

The separate `CustomKitCatalog` product owns built-in examples and navigation. One immutable list of `CatalogEntry` values drives grouping, search, labels, and destinations. Each example owns state and controls. Type erasure occurs only at the heterogeneous destination boundary.

The example Xcode app links local PlayerKit, CaptionKit, and Sekai packages. It injects those examples into the catalog. A consuming app can use a button or logo without resolving these packages.

## Source provenance

| CustomKit component | Original source in sibling repositories |
| --- | --- |
| Logo geometry and Metal | `skeleton/Skeleton/Branding/KaizoshaLogoArtwork.swift`, `KaizoshaLogo.metal` |
| Logo elasticity | `skeleton/Skeleton/Branding/KaizoshaLogoInteraction.swift`, `KaizoshaLogoInteractionPolicy.swift` |
| Launch chevrons | `skeleton/Skeleton/Views/SkeletonLaunchView.swift` |
| Start presets | `Together/Together/App/Launch/TogetherStartView.swift`, `TL-Pinch/iOS (App)/StartView.swift`, `skeleton/Skeleton/Views/SkeletonStartView.swift` |
| Liquid rows | `TL-Pinch/iOS (App)/TogetherListItemSurface.swift` |
| Action roles | `Together/Together/Shared/UI/TogetherRoleAnimatedGlassButtonStyle.swift` |
| Segments and switcher | Together caption modes and skeleton translation controls |
| Presentation feedback | `skeleton/Skeleton/Design/SheetPresentationFeedback.swift` |
| Credits | `skeleton/Skeleton/Views/Controls/SkeletonCreditsSheet.swift` |
| Nothing and Clear | `skeleton/Skeleton/Design/HomeSheetDismissalFeedback.swift`, `HomeDismissalCue.swift` |

The logo resolves shaders with `ShaderLibrary.bundle(.module)`. It does not assume the host app's default Metal library. Start templates do not import app coordinators or the original sensor-housing handoff observer. The reusable pull gesture owns its scroll view and emits a host callback.

## Design decision

Two candidates were considered. A closed enum of destinations was compact, but optional kit integration would require changing it for every host. A descriptor registry lets the example app add integrations without teaching the core catalog about playback or globe engines. Independent review selected the registry.

The final design keeps the enum candidate's domain folders and typed configurations. It uses the registry candidate's independent examples and one list of navigation metadata. It rejects a shared configuration object with unrelated optional fields and a global mutable registry.

## Verification tools

Package tests cover the slider, caption interval boundaries, and pull state transitions. XCUITest drives the runnable catalog and saves screenshots. REA inspects the compiled app as additional binary evidence. Native metadata inspection does not prove UI behavior, and simulator checks cannot establish how vibration feels.
