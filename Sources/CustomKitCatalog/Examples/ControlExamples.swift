import CustomKit
import SwiftUI

@MainActor
enum ControlExamples {
    static var entries: [CatalogEntry] {
        [
            CatalogEntry(id: "liquid-list", title: "Liquid list", source: "TL;Pinch", category: .controls, summary: "Glass language rows.") { LiquidListExample() },
            buttonEntry(.primary, id: "buttons", title: "Primary button"),
            buttonEntry(.neutral, id: "button-neutral", title: "Neutral button"),
            buttonEntry(.destructive, id: "button-destructive", title: "Destructive button"),
            buttonEntry(.reset, id: "button-reset", title: "Reset button"),
            buttonEntry(.success, id: "button-success", title: "Success button"),
            buttonEntry(.working, id: "button-working", title: "Working button"),
            CatalogEntry(id: "switcher", title: "Switcher", source: "Together", category: .controls, summary: "A glass settings toggle.") { SwitcherExample() },
            CatalogEntry(id: "segments", title: "Segmented control", source: "Together", category: .controls, summary: "Native segments in a glass capsule.") { SegmentsExample() },
            CatalogEntry(id: "slider", title: "Slider", source: "CustomKit", category: .controls, summary: "The discrete capsule slider.") { SliderExample() }
        ]
    }

    private static func buttonEntry(_ role: KitButtonRole, id: String, title: String) -> CatalogEntry {
        CatalogEntry(id: id, title: title, source: "Together", category: .controls, summary: "The \(role.rawValue) glass button.") {
            ButtonExample(role: role, title: title)
        }
    }
}

private struct LiquidListExample: View {
    @State private var selected = "Japanese"
    @State private var spacing = 10.0
    @State private var showsNative = true
    private let languages = [("Japanese", "日本語"), ("English", "English"), ("French", "Français"), ("Spanish", "Español")]

    var body: some View {
        ExperimentPage(title: "Liquid list", api: "LiquidListRow(isSelected: language == selected) {\n    selected = language\n} content: {\n    Text(language)\n}") {
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
            .frame(maxWidth: 440)
            .padding(24)
        } controls: {
            Section("List") {
                ValueControl(title: "Row spacing", value: $spacing, range: 4...24, suffix: " pt")
                Toggle("Native language names", isOn: $showsNative)
                Picker("Selected language", selection: $selected) { ForEach(languages, id: \.0) { Text($0.0).tag($0.0) } }
            }
            Section { Button("Reset", role: .destructive) { selected = "Japanese"; spacing = 10; showsNative = true } }
        }
    }
}

private struct ButtonExample: View {
    let role: KitButtonRole
    let title: String
    @State private var label: String
    @State private var symbol: String
    @State private var tint: Color
    @State private var padding = 0.0
    @State private var showsSymbol = true
    @State private var prominent: Bool

    init(role: KitButtonRole, title: String) {
        self.role = role
        self.title = title
        _label = State(initialValue: Self.label(for: role))
        _symbol = State(initialValue: Self.symbol(for: role))
        _tint = State(initialValue: role.tint)
        _prominent = State(initialValue: role != .neutral)
    }

    var body: some View {
        ExperimentPage(title: title, api: "Button(\"\(Self.label(for: role))\", systemImage: \"\(Self.symbol(for: role))\") {\n    performAction()\n}\n.customKitButton(.\(role.rawValue)\(role == .neutral ? ", surface: .regular" : ""))\n.controlSize(.large)") {
            Button {} label: {
                HStack(spacing: 8) {
                    if showsSymbol { Image(systemName: symbol) }
                    Text(label)
                }
                .padding(.horizontal, padding)
            }
            .customKitButton(role, tint: tint, surface: prominent ? .prominent : .regular)
            .controlSize(.large)
            .accessibilityLabel(label)
            .accessibilityIdentifier("button.element")
        } controls: {
            Section("Button") {
                TextField("Label", text: $label)
                TextField("SF Symbol", text: $symbol)
                    .textInputAutocapitalization(.never)
                ColorPicker("Tint", selection: $tint, supportsOpacity: false)
                Toggle("Show symbol", isOn: $showsSymbol)
                Toggle("Prominent glass", isOn: $prominent)
                ValueControl(title: "Horizontal padding", value: $padding, range: 0...30, suffix: " pt")
            }
            Section {
                Button("Reset", role: .destructive) {
                    label = Self.label(for: role)
                    symbol = Self.symbol(for: role)
                    tint = role.tint
                    padding = 0
                    showsSymbol = true
                    prominent = role != .neutral
                }
            }
        }
    }

    private static func label(for role: KitButtonRole) -> String {
        switch role {
        case .primary: "Add video"
        case .neutral: "More"
        case .destructive: "Clear cache"
        case .reset: "Use Default Accent"
        case .success: "Export complete"
        case .working: "Translate"
        }
    }

    private static func symbol(for role: KitButtonRole) -> String {
        switch role {
        case .primary: "plus"
        case .neutral: "ellipsis"
        case .destructive: "trash"
        case .reset: "arrow.counterclockwise"
        case .success: "checkmark"
        case .working: "arrow.trianglehead.2.clockwise.rotate.90"
        }
    }
}

private struct SwitcherExample: View {
    @State private var enabled = true
    @State private var tint = Color.teal
    @State private var title = "Live translation"
    @State private var subtitle = "Japanese → English"

    var body: some View {
        ExperimentPage(title: "Switcher", api: "KitSwitcher(\n    selection: $showsTranslation,\n    title: \"Live translation\",\n    subtitle: \"Japanese → English\"\n)") {
            KitSwitcher(selection: $enabled, title: title, subtitle: subtitle, tint: tint)
                .frame(maxWidth: 440)
                .padding(24)
        } controls: {
            Section("Switcher") {
                Toggle("Enabled", isOn: $enabled)
                TextField("Title", text: $title)
                TextField("Subtitle", text: $subtitle)
                ColorPicker("Tint", selection: $tint)
            }
            Section { Button("Reset", role: .destructive) { enabled = true; tint = .teal; title = "Live translation"; subtitle = "Japanese → English" } }
        }
    }
}

private struct SegmentsExample: View {
    @State private var selection = "Both"
    @State private var tint = Color.teal
    private let options = ["Original", "Translation", "Both"]

    var body: some View {
        ExperimentPage(title: "Segmented control", api: "KitSegmentedControl(\n    selection: $mode,\n    options: [\n        KitSegment(\"Original\", value: \"Original\"),\n        KitSegment(\"Translation\", value: \"Translation\"),\n        KitSegment(\"Both\", value: \"Both\")\n    ]\n)") {
            KitSegmentedControl(selection: $selection, options: options.map { KitSegment($0, value: $0) })
                .tint(tint)
                .frame(maxWidth: 440)
                .padding(24)
        } controls: {
            Section("Segments") {
                Picker("Selection", selection: $selection) { ForEach(options, id: \.self) { Text($0) } }
                ColorPicker("Accent", selection: $tint)
            }
            Section { Button("Reset", role: .destructive) { selection = "Both"; tint = .teal } }
        }
    }
}

private struct SliderExample: View {
    @State private var speed = 1.0
    @State private var tint = Color.white
    @State private var haptics = true
    @State private var rail = 44.0

    var body: some View {
        ExperimentPage(title: "Slider", api: "CustomKit.Slider(\n    value: $speed,\n    stops: [0.5, 1, 1.25, 1.5, 2],\n    accessibilityLabel: \"Playback speed\",\n    accessibilityValue: { \"\\($0.formatted())×\" }\n)") {
            CustomKit.Slider(value: $speed, stops: [0.5, 1, 1.25, 1.5, 2], style: .init(fillColor: tint, knobColor: tint, restingRailHeight: rail, activeRailHeight: rail + 8, hapticsEnabled: haptics), accessibilityLabel: "Playback speed", accessibilityValue: { "\($0.formatted()) times" })
                .frame(maxWidth: 400)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
        } controls: {
            Section("Slider") {
                Picker("Speed", selection: $speed) { ForEach([0.5, 1, 1.25, 1.5, 2], id: \.self) { Text("\($0.formatted())×").tag($0) } }
                ValueControl(title: "Rail height", value: $rail, range: 24...48, suffix: " pt")
                ColorPicker("Fill", selection: $tint)
                Toggle("Haptics", isOn: $haptics)
            }
            Section { Button("Reset", role: .destructive) { speed = 1; rail = 44; tint = .white; haptics = true } }
        }
        .preferredColorScheme(.dark)
    }
}
