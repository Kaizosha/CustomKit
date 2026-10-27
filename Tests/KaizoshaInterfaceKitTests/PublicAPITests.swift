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
    }
}
