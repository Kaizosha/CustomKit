import CustomKit
import SwiftUI

@MainActor
enum IdentityExamples {
    static var entries: [CatalogEntry] {
        [
            CatalogEntry(id: "logo", title: "The Kaizōsha mark", source: "Kaizōsha", category: .identity, summary: "Drag the illuminated glass mark and tune its finish.") { LogoExample() },
            CatalogEntry(id: "launch", title: "An opening gesture", source: "Shared", category: .identity, summary: "Replay the opposing chevron launch animation.") { LaunchExample() },
            CatalogEntry(id: "together-start", title: "Together, from the start", source: "Together", category: .identity, summary: "An interactive media welcome screen.") { StartExample(preset: .together, source: "Together") },
            CatalogEntry(id: "pinch-start", title: "A little TL;Pinch", source: "TL;Pinch", category: .identity, summary: "A Safari reading welcome screen.") { StartExample(preset: .pinch, source: "TL;Pinch") },
            CatalogEntry(id: "skeleton-start", title: "Say it with skeleton", source: "skeleton", category: .identity, summary: "A conversation welcome screen.") { StartExample(preset: .skeleton, source: "skeleton") }
        ]
    }
}

private struct LogoExample: View {
    @State private var configuration = LogoConfiguration()

    var body: some View {
        ExperimentPage(
            title: "The Kaizōsha mark",
            subtitle: "Three pillars. One identity. Drag the glass to feel its spring, then let it settle.",
            source: "Kaizōsha / Branding",
            api: "KaizoshaLogo(configuration: LogoConfiguration(\n    size: 160,\n    interactive: true,\n    refraction: 0.5\n))"
        ) {
            VStack(spacing: 30) {
                KaizoshaLogo(configuration: configuration)
                Text(configuration.interactive ? "Touch. Pull. Let go." : "A quiet signature.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 340)
        } controls: {
            Section("The mark") {
                ValueControl(title: "Size", value: $configuration.size, range: 80...230, suffix: " pt")
                ValueControl(title: "Refraction", value: $configuration.refraction, range: 0...1)
                Toggle("Interactive", isOn: $configuration.interactive)
                Toggle("Haptics", isOn: $configuration.hapticsEnabled)
            }
            Section {
                Button("Reset to Kaizōsha", role: .destructive) { configuration = .init() }
            }
        }
    }
}

private struct LaunchExample: View {
    @State private var configuration = LaunchConfiguration()
    @State private var cycle = 0
    @State private var complete = false

    var body: some View {
        ExperimentPage(
            title: "An opening gesture",
            subtitle: "The familiar arrows meet in the middle. A small beginning, before the app gets out of your way.",
            source: "Together · TL;Pinch · skeleton / Launch",
            api: "LaunchAnimation(\n    configuration: LaunchConfiguration(duration: 1.65)\n) {\n    showStart = true\n}"
        ) {
            VStack(spacing: 24) {
                LaunchAnimation(configuration: configuration) { complete = true }
                    .id(cycle)
                    .frame(height: 220)
                    .clipped()
                Button("Replay opening", systemImage: "arrow.counterclockwise") {
                    complete = false
                    cycle += 1
                }
                .customKitButton(.reset)
                Text(complete ? "Ready when you are." : "A moment to begin.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        } controls: {
            Section("Motion") {
                ValueControl(title: "Duration", value: $configuration.duration, range: 0.4...3, suffix: " s")
                ValueControl(title: "Arrow size", value: $configuration.symbolSize, range: 24...72, suffix: " pt")
                Toggle("Haptics", isOn: $configuration.hapticsEnabled)
            }
            Section {
                Button("Apply and replay") { complete = false; cycle += 1 }
                Button("Reset", role: .destructive) { configuration = .init(); complete = false; cycle += 1 }
            }
        }
    }
}

private struct StartExample: View {
    let preset: StartConfiguration
    let source: String
    @State private var configuration: StartConfiguration
    @State private var hasStarted = false
    @State private var showsSettings = false
    @State private var launch = LaunchConfiguration()
    @State private var startCycle = 0

    init(preset: StartConfiguration, source: String) {
        self.preset = preset
        self.source = source
        _configuration = State(initialValue: preset)
    }

    var body: some View {
        ExperimentPage(
            title: "\(source), at first sight",
            subtitle: "A complete start template with the original voice. Try its primary action, or rewrite it for your next app.",
            source: "\(source) / Start",
            api: "StartExperience(\n    configuration: .\(source == "Together" ? "together" : source == "skeleton" ? "skeleton" : "pinch"),\n    onPrimaryAction: { openApp() },\n    onControls: { showControls = true }\n)"
        ) {
            if hasStarted {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: source == "Together" ? "play.rectangle" : source == "skeleton" ? "waveform" : "safari")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(configuration.accent)
                    Text(source == "Together" ? "Your next watch." : source == "skeleton" ? "A conversation begins." : "A page, a little clearer.")
                        .font(.system(.title, design: .serif))
                    Text(source == "Together" ? "A quiet morning in Kyoto\n00:12 · Japanese → English" : source == "skeleton" ? "こんにちは。今日はいい天気ですね。\nHello. It's a beautiful day today." : "Read the web in your own language.\nJapanese → English · Bilingual reading")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Button("Back to start", systemImage: "arrow.counterclockwise") { hasStarted = false; startCycle += 1 }
                        .customKitButton(.reset)
                }
                .frame(maxWidth: .infinity, minHeight: 440, alignment: .leading)
            } else {
                StartExperience(configuration: configuration, launch: launch, onPrimaryAction: { hasStarted = true }, onControls: { showsSettings = true })
                    .id(startCycle)
                    .frame(height: 500)
            }
        } controls: {
            Section("Your app") {
                TextField("App name", text: $configuration.appName)
                TextField("Headline", text: Binding(get: { configuration.title.joined(separator: "\n") }, set: { configuration.title = $0.components(separatedBy: "\n") }), axis: .vertical)
                TextField("Subtitle", text: $configuration.subtitle, axis: .vertical)
                TextField("Action", text: $configuration.actionTitle)
                ColorPicker("Accent", selection: $configuration.accent, supportsOpacity: false)
                Toggle("Kaizōsha signature", isOn: $configuration.showsBrand)
            }
            Section("Opening") {
                ValueControl(title: "Duration", value: $launch.duration, range: 0.4...3, suffix: " s")
                Toggle("Haptic feedback", isOn: $launch.hapticsEnabled)
            }
            Section {
                Button("Replay start") { hasStarted = false; startCycle += 1 }
                Button("Reset to \(source)", role: .destructive) { configuration = preset; launch = .init(); hasStarted = false; startCycle += 1 }
            }
        }
        .hapticSheet(isPresented: $showsSettings) {
            NavigationStack {
                Form {
                    Section("\(source) controls") {
                        ColorPicker("Accent", selection: $configuration.accent)
                        Toggle("Kaizōsha signature", isOn: $configuration.showsBrand)
                    }
                }
                .navigationTitle("Controls")
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showsSettings = false } } }
            }
        }
    }
}
