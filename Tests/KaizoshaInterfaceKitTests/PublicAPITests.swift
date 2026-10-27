import KaizoshaInterfaceKit
import SwiftUI
import Testing

@MainActor
struct PublicAPITests {
    @Test func consumingAppCanConstructAndCustomizeTheLogo() {
        var configuration = LogoConfiguration()
        #expect(configuration.size == 160)
        #expect(configuration.interactive)
        #expect(configuration.hapticsEnabled)
        #expect(configuration.motionEnabled)
        configuration.size = 220
        configuration.motionEnabled = false
        configuration.lightDirection = CGVector(dx: 0.5, dy: -0.5)
        _ = KaizoshaLogo(configuration: configuration)
        _ = KaizoshaLogo(configuration: configuration, onOpenCredits: {})
    }

    @Test func consumingAppCanConstructEveryComponentWithOneImport() {
        var credits = CreditsConfiguration.together
        credits.title = "Made for Kaizōsha."
        _ = MadeByKaizosha(configuration: credits)
        var unlock = UnlockTogetherConfiguration()
        unlock.lockedTitle = "Unlock your app"
        _ = UnlockTogetherControl(isUnlocked: false, configuration: unlock) { }
        let strategy = Binding.constant(TranslationStrategy.lowLatency)
        _ = TranslationStrategySwitcher(selection: strategy)
        _ = TranslationStrategyPill(selection: strategy)
        _ = LanguageSwitcher(selection: .constant(LanguageRole.source))
        _ = MasonryGrid { Color.clear.frame(height: 100) }
        _ = MasonryLayout { Color.clear.frame(height: 100) }
        _ = Button("Continue") { }
            .kaizoshaGlassButtonStyle()
    }

    @Test func nativeGlassConfigurationUsesNativeDefaultsAndAcceptsCustomization() {
        var configuration = NativeGlassButtonConfiguration()
        #expect(configuration.surface == .prominent)
        #expect(configuration.tint == .accentColor)
        #expect(configuration.borderShape == .capsule)

        configuration.surface = .regular
        configuration.tint = .orange
        configuration.borderShape = .circle
        #expect(configuration.surface == .regular)
        #expect(configuration.tint == .orange)
        #expect(configuration.borderShape == .circle)

        let initialized = NativeGlassButtonConfiguration(
            surface: .regular,
            tint: .orange,
            borderShape: .circle
        )
        #expect(initialized.surface == configuration.surface)
        #expect(initialized.tint == configuration.tint)
        #expect(initialized.borderShape == configuration.borderShape)
    }

    @Test func nativeGlassComposesWithNativeButtonsMenusAndInheritedDisabling() {
        for surface in [NativeGlassButtonConfiguration.Surface.regular, .prominent] {
            let configuration = NativeGlassButtonConfiguration(
                surface: surface,
                tint: .red,
                borderShape: .circle
            )

            _ = Button("Delete", systemImage: "trash", role: .destructive) { }
                .kaizoshaGlassButtonStyle(configuration)
                .controlSize(.regular)
                .accessibilityHint("Deletes the selected item")

            _ = VStack {
                Button(role: .close) { } label: {
                    Label("Close", systemImage: "xmark")
                }
                .kaizoshaGlassButtonStyle(configuration)

                Menu {
                    Button("Select All") { }
                    Button("Delete", role: .destructive) { }
                } label: {
                    Label("Actions", systemImage: "ellipsis")
                }
                .menuStyle(.button)
                .kaizoshaGlassButtonStyle(configuration)
            }
            .disabled(true)
        }
    }
}
