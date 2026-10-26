import CustomKit
import SwiftUI

@MainActor
enum ControlExamples {
    static var entries: [CatalogEntry] {
        [
            CatalogEntry(id: "liquid-list", title: "Liquid lists", source: "TL;Pinch", category: .controls, summary: "Choose the languages for a bilingual reading session.") { LiquidListExample() },
            CatalogEntry(id: "buttons", title: "Buttons with a purpose", source: "Together", category: .controls, summary: "Add, export, and clear a working sample queue.") { ButtonsExample() },
            CatalogEntry(id: "switcher", title: "A change of mind", source: "skeleton", category: .controls, summary: "Switch translation on and off in a conversation.") { SwitcherExample() },
            CatalogEntry(id: "segments", title: "One view, three ways", source: "Together", category: .controls, summary: "Switch between original, translated, and bilingual captions.") { SegmentsExample() },
            CatalogEntry(id: "slider", title: "A tactile little slider", source: "CustomKit", category: .controls, summary: "Set playback speed with the original discrete capsule slider.") { SliderExample() }
        ]
    }
}

private struct LiquidListExample: View {
    @State private var selected = "Japanese"
    @State private var spacing = 10.0
    @State private var showsNative = true
    private let languages = [("Japanese", "日本語"), ("English", "English"), ("French", "Français"), ("Spanish", "Español")]

    var body: some View {
        ExperimentPage(title: "Liquid lists", subtitle: "Choose a reading language. Native glass gives each row a little presence, and the selection stays clear.", source: "TL;Pinch / Language selection", api: "LiquidListRow(isSelected: language == selected) {\n    selected = language\n} content: {\n    Text(language)\n}") {
            VStack(alignment: .leading, spacing: spacing) {
                Text("READ THE WEB IN")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
                GlassEffectContainer(spacing: spacing) {
                    VStack(spacing: spacing) {
                        ForEach(languages, id: \.0) { language in
                            LiquidListRow(isSelected: selected == language.0, action: { selected = language.0 }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(language.0)
                                        if showsNative {
                                            Text(language.1).font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    if selected == language.0 { Image(systemName: "checkmark").foregroundStyle(.teal) }
                                }
                            }
                        }
                    }
                }
                Text("Your next page will open in \(selected).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 16)
            }
        } controls: {
            Section("Reading list") {
                ValueControl(title: "Row spacing", value: $spacing, range: 4...24, suffix: " pt")
                Toggle("Native language names", isOn: $showsNative)
                Picker("Selected language", selection: $selected) { ForEach(languages, id: \.0) { Text($0.0).tag($0.0) } }
            }
            Section { Button("Reset", role: .destructive) { selected = "Japanese"; spacing = 10; showsNative = true } }
        }
    }
}

private struct ButtonsExample: View {
    @State private var count = 1
    @State private var exported = false
    @State private var tint = Color.teal
    @State private var padding = 12.0
    @State private var symbols = true

    var body: some View {
        ExperimentPage(title: "Buttons with a purpose", subtitle: "A tiny Together queue. Add a clip, finish an export, or clear it. Each action has its own movement.", source: "Together / Actions", api: "Button(\"Add clip\", systemImage: \"plus\") {\n    queue.add(clip)\n}\n.customKitButton(.primary, tint: .teal)") {
            VStack(spacing: 26) {
                Image(systemName: exported ? "checkmark.rectangle.stack" : "rectangle.stack")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(tint)
                    .contentTransition(.symbolEffect(.replace))
                Text(exported ? "Ready to keep." : "\(count) \(count == 1 ? "clip" : "clips") in your queue.")
                    .font(.system(.title3, design: .serif))
                    .accessibilityIdentifier("buttons.status")
                VStack(spacing: 14) {
                    Button { count += 1; exported = false } label: {
                        actionLabel("Add clip", symbol: "plus")
                    }
                    .customKitButton(.primary, tint: tint)
                    Button { exported = true } label: {
                        actionLabel(exported ? "Export complete" : "Export captions", symbol: exported ? "checkmark" : "square.and.arrow.up")
                    }
                    .customKitButton(.success, tint: tint)
                    .disabled(count == 0 || exported)
                    Button { count = 0; exported = false } label: { actionLabel("Clear queue", symbol: "trash") }
                        .customKitButton(.destructive)
                        .disabled(count == 0)
                }
            }
        } controls: {
            Section("Actions") {
                ColorPicker("Primary tint", selection: $tint, supportsOpacity: false)
                ValueControl(title: "Content padding", value: $padding, range: 6...22, suffix: " pt")
                Toggle("Symbols", isOn: $symbols)
            }
            Section { Button("Reset", role: .destructive) { count = 1; exported = false; tint = .teal; padding = 12; symbols = true } }
        }
    }

    private func actionLabel(_ title: String, symbol: String) -> some View {
        HStack {
            if symbols { Image(systemName: symbol) }
            Text(title)
        }
        .frame(maxWidth: .infinity)
        .padding(padding)
    }
}

private struct SwitcherExample: View {
    @State private var translated = true
    @State private var tint = Color.teal
    @State private var original = "今日はどこへ行きましょうか。"
    @State private var translation = "Where shall we go today?"

    var body: some View {
        ExperimentPage(title: "A change of mind", subtitle: "Keep a conversation in the language you need. Switch the translation without losing the original thought.", source: "skeleton / Conversation", api: "KitSwitcher(\n    selection: $showsTranslation,\n    title: \"Live translation\",\n    subtitle: \"Japanese → English\"\n)") {
            VStack(alignment: .leading, spacing: 28) {
                Text("CONVERSATION 01").font(.system(.caption2, design: .monospaced)).foregroundStyle(.secondary)
                Text(original).font(.title2)
                if translated {
                    Text(translation).font(.system(.title2, design: .serif)).foregroundStyle(tint).transition(.opacity)
                }
                Divider()
                KitSwitcher(selection: $translated, title: "Live translation", subtitle: "Japanese → English", tint: tint)
            }
            .animation(.easeInOut(duration: 0.2), value: translated)
        } controls: {
            Section("Conversation") {
                Toggle("Translation", isOn: $translated)
                TextField("Original", text: $original, axis: .vertical)
                TextField("Translation", text: $translation, axis: .vertical)
                ColorPicker("Tint", selection: $tint)
            }
            Section { Button("Reset", role: .destructive) { translated = true; tint = .teal; original = "今日はどこへ行きましょうか。"; translation = "Where shall we go today?" } }
        }
    }
}

private struct SegmentsExample: View {
    @State private var selection = "Both"
    @State private var tint = Color.teal
    @State private var original = "また、ここで会いましょう。"
    @State private var translation = "Let's meet here again."
    private let options = ["Original", "Translation", "Both"]

    var body: some View {
        ExperimentPage(title: "One view, three ways", subtitle: "A caption can tell the same story in more than one language. Change the reading mode and keep your place.", source: "Together / Caption modes", api: "KitSegmentedControl(\n    selection: $mode,\n    options: [\n        KitSegment(\"Original\", value: \"Original\"),\n        KitSegment(\"Translation\", value: \"Translation\"),\n        KitSegment(\"Both\", value: \"Both\")\n    ]\n)") {
            VStack(spacing: 32) {
                VStack(spacing: 14) {
                    Image(systemName: "captions.bubble").font(.system(size: 40, weight: .light)).foregroundStyle(tint)
                    if selection != "Translation" { Text(original).font(.title3).multilineTextAlignment(.center) }
                    if selection != "Original" { Text(translation).font(.system(.title3, design: .serif)).multilineTextAlignment(.center).foregroundStyle(.secondary) }
                }
                .frame(minHeight: 190)
                KitSegmentedControl(selection: $selection, options: options.map { KitSegment($0, value: $0) })
                    .tint(tint)
            }
        } controls: {
            Section("Captions") {
                Picker("Mode", selection: $selection) { ForEach(options, id: \.self) { Text($0) } }
                TextField("Original", text: $original)
                TextField("Translation", text: $translation)
                ColorPicker("Accent", selection: $tint)
            }
            Section { Button("Reset", role: .destructive) { selection = "Both"; tint = .teal; original = "また、ここで会いましょう。"; translation = "Let's meet here again." } }
        }
    }
}

private struct SliderExample: View {
    @State private var speed = 1.0
    @State private var tint = Color.white
    @State private var haptics = true
    @State private var rail = 44.0

    var body: some View {
        ExperimentPage(title: "A tactile little slider", subtitle: "The original CustomKit control. Drag through playback speeds, or move your finger away from the rail for a finer adjustment.", source: "CustomKit / Playback speed", api: "CustomKit.Slider(\n    value: $speed,\n    stops: [0.5, 1, 1.25, 1.5, 2],\n    accessibilityLabel: \"Playback speed\",\n    accessibilityValue: { \"\\($0.formatted())×\" }\n)") {
            VStack(alignment: .leading, spacing: 28) {
                HStack {
                    Image(systemName: "play.rectangle").font(.largeTitle)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("A quiet morning in Kyoto").font(.subheadline)
                        Text("TOGETHER / PLAYBACK").font(.system(.caption2, design: .monospaced)).foregroundStyle(.white.opacity(0.55))
                    }
                }
                Text("\(speed.formatted())×")
                    .font(.system(size: 54, weight: .light, design: .rounded))
                    .monospacedDigit()
                CustomKit.Slider(value: $speed, stops: [0.5, 1, 1.25, 1.5, 2], style: .init(fillColor: tint, knobColor: tint, restingRailHeight: rail, activeRailHeight: rail + 8, hapticsEnabled: haptics), accessibilityLabel: "Playback speed", accessibilityValue: { "\($0.formatted()) times" })
                HStack { Text("0.5×"); Spacer(); Text("2×") }
                    .font(.system(.caption, design: .monospaced)).foregroundStyle(.white.opacity(0.55))
            }
            .foregroundStyle(.white)
            .padding(24)
            .background(.black, in: .rect(cornerRadius: 22))
        } controls: {
            Section("Playback speed") {
                Picker("Speed", selection: $speed) { ForEach([0.5, 1, 1.25, 1.5, 2], id: \.self) { Text("\($0.formatted())×").tag($0) } }
                ValueControl(title: "Rail height", value: $rail, range: 24...48, suffix: " pt")
                ColorPicker("Fill", selection: $tint)
                Toggle("Haptics", isOn: $haptics)
            }
            Section { Button("Reset", role: .destructive) { speed = 1; rail = 44; tint = .white; haptics = true } }
        }
    }
}
