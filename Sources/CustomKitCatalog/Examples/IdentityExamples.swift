import CustomKit
import SwiftUI

@MainActor
enum IdentityExamples {
    static var entries: [CatalogEntry] {
        [
            CatalogEntry(id: "logo", title: "Kaizōsha logo", source: "Kaizōsha", category: .identity, summary: "The interactive glass mark.") { LogoExample() },
            CatalogEntry(id: "launch", title: "Launch animation", source: "Shared", category: .identity, summary: "The shared chevron opening.") { LaunchExample() },
            CatalogEntry(id: "together-start", title: "Together start", source: "Together", category: .identity, summary: "The Together start view.") { StartExample(preset: .together, source: "Together") },
            CatalogEntry(id: "pinch-start", title: "TL;Pinch start", source: "TL;Pinch", category: .identity, summary: "The TL;Pinch start view.") { StartExample(preset: .pinch, source: "TL;Pinch") },
            CatalogEntry(id: "skeleton-start", title: "Skeleton start", source: "skeleton", category: .identity, summary: "The Skeleton start view.") { StartExample(preset: .skeleton, source: "Skeleton") }
        ]
    }
}

private struct LogoExample: View {
    @State private var configuration = LogoConfiguration()

    var body: some View {
        ExperimentPage(title: "Kaizōsha logo", api: "KaizoshaLogo(configuration: LogoConfiguration(\n    size: 160,\n    interactive: true,\n    refraction: 0.5\n))") {
            KaizoshaLogo(configuration: configuration)
        } controls: {
            Section("Logo") {
                ValueControl(title: "Size", value: $configuration.size, range: 80...230, suffix: " pt")
                ValueControl(title: "Refraction", value: $configuration.refraction, range: 0...1)
                Toggle("Interactive", isOn: $configuration.interactive)
                Toggle("Haptics", isOn: $configuration.hapticsEnabled)
            }
            Section { Button("Reset", role: .destructive) { configuration = .init() } }
        }
    }
}

private struct LaunchExample: View {
    @State private var configuration = LaunchConfiguration()
    @State private var cycle = 0

    var body: some View {
        ExperimentPage(title: "Launch animation", api: "LaunchAnimation(\n    configuration: LaunchConfiguration(duration: 1.65)\n) {\n    showStart = true\n}") {
            LaunchAnimation(configuration: configuration) {}
                .id(cycle)
        } controls: {
            Section("Animation") {
                ValueControl(title: "Duration", value: $configuration.duration, range: 0.4...3, suffix: " s")
                ValueControl(title: "Arrow size", value: $configuration.symbolSize, range: 24...72, suffix: " pt")
                Toggle("Haptics", isOn: $configuration.hapticsEnabled)
            }
            Section {
                Button("Replay") { cycle += 1 }
                Button("Reset", role: .destructive) { configuration = .init(); cycle += 1 }
            }
        }
    }
}

private struct StartExample: View {
    let preset: StartConfiguration
    let source: String
    @State private var configuration: StartConfiguration
    @State private var launch = LaunchConfiguration()
    @State private var cycle = 0
    @State private var feedback = 0

    init(preset: StartConfiguration, source: String) {
        self.preset = preset
        self.source = source
        _configuration = State(initialValue: preset)
    }

    var body: some View {
        ExperimentPage(title: "\(source) start", api: "StartExperience(\n    configuration: .\(source == "Together" ? "together" : source == "Skeleton" ? "skeleton" : "pinch"),\n    onPrimaryAction: { openApp() }\n)") {
            StartExperience(configuration: configuration, launch: launch, onPrimaryAction: { feedback += 1 })
                .id(cycle)
                .frame(maxWidth: 640)
                .sensoryFeedback(.impact(weight: .heavy), trigger: feedback)
        } controls: {
            Section("Start view") {
                TextField("App name", text: $configuration.appName)
                TextField("Headline", text: Binding(get: { configuration.title.joined(separator: "\n") }, set: { configuration.title = $0.components(separatedBy: "\n") }), axis: .vertical)
                TextField("Subtitle", text: $configuration.subtitle, axis: .vertical)
                TextField("Action", text: $configuration.actionTitle)
                ColorPicker("Accent", selection: $configuration.accent, supportsOpacity: false)
                Toggle("Kaizōsha signature", isOn: $configuration.showsBrand)
            }
            Section("Opening") {
                ValueControl(title: "Duration", value: $launch.duration, range: 0.4...3, suffix: " s")
                Toggle("Haptics", isOn: $launch.hapticsEnabled)
            }
            Section {
                Button("Replay") { cycle += 1 }
                Button("Reset", role: .destructive) { configuration = preset; launch = .init(); cycle += 1 }
            }
        }
    }
}
