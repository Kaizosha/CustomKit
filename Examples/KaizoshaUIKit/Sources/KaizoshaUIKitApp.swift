import SwiftUI

@main
struct KaizoshaUIKitApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Kaizosha Logo") { LogoExample() }
                        .accessibilityIdentifier("catalog.kaizosha-logo")
                    NavigationLink("Made by Kaizosha") { CreditsExample() }
                        .accessibilityIdentifier("catalog.made-by-kaizosha")
                    NavigationLink("Unlock Together") { UnlockTogetherExample() }
                        .accessibilityIdentifier("catalog.unlock-together")
                    NavigationLink("Translation Strategy Pill") { TranslationPillExample() }
                        .accessibilityIdentifier("catalog.translation-pill")
                    NavigationLink("Language Switcher") { LanguageExample() }
                        .accessibilityIdentifier("catalog.language-switcher")
                    NavigationLink("Low/High Switcher") { StrategySwitcherExample() }
                        .accessibilityIdentifier("catalog.strategy-switcher")
                    NavigationLink("Masonry Layout") { MasonryExample() }
                        .accessibilityIdentifier("catalog.masonry-layout")
                }
                .listStyle(.plain)
                .navigationTitle("KaizoshaUIKit")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tint(.primary)
        }
    }
}
