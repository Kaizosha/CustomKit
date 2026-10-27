import KaizoshaInterfaceKit
import SwiftUI
import UIKit

struct UnlockTogetherExample: View {
    @State private var configuration = UnlockTogetherConfiguration()
    @State private var isUnlocked = false
    @State private var activations = 0

    var body: some View {
        ComponentPage(title: "Unlock Together", code: code, reset: {
            configuration = .init(); isUnlocked = false; activations = 0
        }) {
            UnlockTogetherControl(isUnlocked: isUnlocked, configuration: configuration) {
                activations += 1
            }
            .accessibilityIdentifier("unlock.element")
        } controls: {
            Section("Control") {
                Toggle("Unlocked", isOn: $isUnlocked)
                TextField("Locked title", text: $configuration.lockedTitle)
                TextField("Unlocked title", text: $configuration.unlockedTitle)
                ColorPicker("Tint", selection: Binding(get: { Color(uiColor: configuration.tint) }, set: { configuration.tint = UIColor($0) }))
                LabeledContent("Activations", value: String(activations))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Activations")
                    .accessibilityValue(String(activations))
                    .accessibilityIdentifier("unlock.activations")
            }
        }
    }

    private let code = """
    import KaizoshaInterfaceKit

    UnlockTogetherControl(isUnlocked: false) {
        // Present your unlock flow.
    }

    UnlockTogetherControl(
        isUnlocked: true,
        configuration: UnlockTogetherConfiguration(
            unlockedTitle: "Together x You",
            tint: .systemOrange
        )
    ) { }
    """
}

struct TranslationPillExample: View {
    @State private var configuration = TranslationStrategyPillConfiguration(tint: .orange)
    @State private var selection = TranslationStrategy.lowLatency
    @State private var highAvailable = true

    var body: some View {
        ComponentPage(title: "Translation Strategy Pill", code: code, reset: {
            configuration = .init(tint: .orange); selection = .lowLatency; highAvailable = true
        }) {
            TranslationStrategyPill(selection: $selection, isHighFidelityAvailable: highAvailable, configuration: configuration)
        } controls: {
            Section("Pill") {
                Toggle("Compact", isOn: $configuration.isCompact)
                Toggle("High fidelity available", isOn: $highAvailable)
                ColorPicker("Tint", selection: $configuration.tint)
                TextField("Status", text: $configuration.status)
                TextField("Detail", text: $configuration.detail, axis: .vertical)
            }
        }
    }

    private let code = """
    import KaizoshaInterfaceKit

    @State private var strategy = TranslationStrategy.lowLatency

    TranslationStrategyPill(
        selection: $strategy,
        isHighFidelityAvailable: true,
        configuration: TranslationStrategyPillConfiguration(
            tint: .orange,
            isCompact: false,
            status: "Ready",
            detail: "Your app provides translation availability."
        )
    )
    """
}

struct LanguageExample: View {
    @State private var selection = LanguageRole.source
    @State private var width: CGFloat = 210
    @State private var sourceTitle = "Source"
    @State private var translationTitle = "Translate"

    var body: some View {
        ComponentPage(title: "Language Switcher", code: code, reset: {
            selection = .source; width = 210; sourceTitle = "Source"; translationTitle = "Translate"
        }) {
            LanguageSwitcher(selection: $selection, width: width, sourceTitle: sourceTitle, translationTitle: translationTitle)
                .accessibilityIdentifier("language.element")
        } controls: {
            Section("Switcher") {
                ValueControl(title: "Width", value: $width, range: 160...320, suffix: " pt")
                TextField("Source title", text: $sourceTitle)
                TextField("Translation title", text: $translationTitle)
            }
        }
    }

    private let code = """
    import KaizoshaInterfaceKit

    @State private var role = LanguageRole.source

    LanguageSwitcher(selection: $role)
    """
}

struct StrategySwitcherExample: View {
    @State private var selection = TranslationStrategy.lowLatency
    @State private var configuration = TranslationStrategySwitcherConfiguration()
    @State private var highAvailable = true
    @State private var enabled = true
    @State private var unavailableTaps = 0

    var body: some View {
        ComponentPage(title: "Low/High Switcher", code: code, reset: {
            selection = .lowLatency; configuration = .init(); highAvailable = true; enabled = true; unavailableTaps = 0
        }) {
            TranslationStrategySwitcher(selection: $selection, isEnabled: enabled, isHighFidelityAvailable: highAvailable, configuration: configuration) {
                unavailableTaps += 1
            }
            .accessibilityIdentifier("strategy.element")
        } controls: {
            Section("Switcher") {
                Toggle("Enabled", isOn: $enabled)
                Toggle("High fidelity available", isOn: $highAvailable)
                ValueControl(title: "Width", value: $configuration.width, range: 128...280, suffix: " pt")
                ValueControl(title: "Height", value: $configuration.height, range: 28...48, suffix: " pt")
                ColorPicker("High tint", selection: Binding(get: { Color(uiColor: configuration.highTint) }, set: { configuration.highTint = UIColor($0) }))
                LabeledContent("Unavailable taps", value: String(unavailableTaps))
            }
        }
    }

    private let code = """
    import KaizoshaInterfaceKit

    @State private var strategy = TranslationStrategy.lowLatency

    TranslationStrategySwitcher(
        selection: $strategy,
        isHighFidelityAvailable: true
    ) {
        // Explain availability in your app.
    }
    """
}
