import KaizoshaInterfaceKit
import SwiftUI

struct NativeGlassButtonExample: View {
    @State private var settings = GlassButtonSettings()
    @State private var activations = 0
    @State private var rotationTrigger = 0
    @Environment(\.self) private var environment
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ComponentPage(title: "Native Glass Button", code: Self.code(for: settings, in: environment), reset: {
            settings = .init()
            activations = 0
            rotationTrigger = 0
        }) {
            VStack(spacing: 20) {
                VStack {
                    control
                        .kaizoshaGlassButtonStyle(settings.configuration)
                        .controlSize(settings.size.value)
                        .disabled(!settings.enabled)
                        .accessibilityIdentifier("glass.element")
                }
                .disabled(settings.ancestorDisabled)
                Text("Activations: \(activations)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Activations")
                    .accessibilityValue(String(activations))
                    .accessibilityIdentifier("glass.activations")
            }
        } controls: {
            Section("Example") {
                Picker("Preset", selection: Binding(
                    get: { settings.preset },
                    set: { settings = GlassButtonSettings(preset: $0) }
                )) {
                    ForEach(GlassButtonPreset.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .accessibilityIdentifier("glass.preset")
                Toggle("Enabled", isOn: $settings.enabled)
                    .accessibilityIdentifier("glass.enabled")
                Toggle("Ancestor disabled", isOn: $settings.ancestorDisabled)
                    .accessibilityIdentifier("glass.ancestor-disabled")
                LabeledContent("Activations", value: String(activations))
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Activations")
                    .accessibilityValue(String(activations))
                    .accessibilityIdentifier("glass.customization-activations")
            }
            Section("Appearance") {
                Picker("Surface", selection: $settings.surface) {
                    Text("Regular").tag(NativeGlassButtonConfiguration.Surface.regular)
                    Text("Prominent").tag(NativeGlassButtonConfiguration.Surface.prominent)
                }
                .accessibilityIdentifier("glass.surface")
                ColorPicker("Tint", selection: $settings.tint)
                Picker("Shape", selection: $settings.shape) {
                    ForEach(GlassButtonShape.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Picker("Control size", selection: $settings.size) {
                    ForEach(GlassButtonSize.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
            }
            Section("Native label and role") {
                TextField("Title", text: $settings.title)
                    .accessibilityIdentifier("glass.title")
                TextField("SF Symbol", text: $settings.symbol)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Picker("Label", selection: $settings.label) {
                    ForEach(GlassButtonLabel.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Picker("Role", selection: $settings.role) {
                    ForEach(GlassButtonRole.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .disabled(settings.preset == .menu)
            }
        }
    }

    @ViewBuilder private var control: some View {
        if settings.preset == .menu {
            Menu {
                Button("Run command", systemImage: "checkmark", action: activate)
                    .accessibilityIdentifier("glass.menu-command")
            } label: {
                label
            }
            .menuStyle(.button)
            .accessibilityLabel(settings.title)
            .accessibilityHint("Opens a menu with an example command")
        } else {
            Button(role: settings.role.value, action: activate) { label }
                .accessibilityLabel(settings.title)
                .accessibilityHint("Increments the example activation count")
        }
    }

    @ViewBuilder private var label: some View {
        switch settings.label {
        case .titleAndIcon: symbolLabel.labelStyle(.titleAndIcon)
        case .iconOnly: symbolLabel.labelStyle(.iconOnly)
        case .titleOnly: symbolLabel.labelStyle(.titleOnly)
        }
    }

    @ViewBuilder private var symbolLabel: some View {
        let label = Label(settings.title, systemImage: settings.symbol)
        if settings.preset == .reset {
            label.symbolEffect(.rotate.counterClockwise.wholeSymbol,
                               options: .nonRepeating, value: rotationTrigger)
                .symbolEffectsRemoved(reduceMotion)
        } else {
            label
        }
    }

    private func activate() {
        activations += 1
        if settings.preset == .reset && !reduceMotion { rotationTrigger &+= 1 }
    }
}

enum GlassButtonPreset: String, CaseIterable {
    case primary = "Primary", confirm = "Confirm", help = "Help"
    case reset = "Reset", destructive = "Destructive", menu = "Menu"
}

enum GlassButtonLabel: String, CaseIterable {
    case titleAndIcon = "Title and icon", iconOnly = "Icon only", titleOnly = "Title only"
}

enum GlassButtonRole: String, CaseIterable {
    case none = "None", confirm = "Confirm", close = "Close"
    case cancel = "Cancel", destructive = "Destructive"

    var value: ButtonRole? {
        switch self {
        case .none: nil
        case .confirm: .confirm
        case .close: .close
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}

enum GlassButtonShape: String, CaseIterable {
    case capsule = "Capsule", circle = "Circle", roundedRectangle = "Rounded rectangle"

    var value: ButtonBorderShape {
        switch self {
        case .capsule: .capsule
        case .circle: .circle
        case .roundedRectangle: .roundedRectangle
        }
    }
}

enum GlassButtonSize: String, CaseIterable {
    case mini = "Mini", small = "Small", regular = "Regular"
    case large = "Large", extraLarge = "Extra large"

    var value: ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}

struct GlassButtonSettings {
    var preset: GlassButtonPreset
    var surface: NativeGlassButtonConfiguration.Surface = .prominent
    var tint: Color = .accentColor
    var shape: GlassButtonShape = .capsule
    var size: GlassButtonSize = .regular
    var label: GlassButtonLabel = .titleAndIcon
    var role: GlassButtonRole = .none
    var title = "Continue"
    var symbol = "arrow.right"
    var enabled = true
    var ancestorDisabled = false

    init(preset: GlassButtonPreset = .primary) {
        self.preset = preset
        switch preset {
        case .primary: break
        case .confirm:
            title = "Done"; symbol = "checkmark"; role = .confirm
        case .help:
            title = "Help"; symbol = "questionmark"; tint = .yellow
            shape = .circle; label = .iconOnly
        case .reset:
            title = "Reset"; symbol = "arrow.counterclockwise"; tint = .orange
            shape = .circle; label = .iconOnly
        case .destructive:
            title = "Delete"; symbol = "trash"; tint = .red; role = .destructive
        case .menu:
            title = "Actions"; symbol = "ellipsis"; surface = .regular
        }
    }

    var configuration: NativeGlassButtonConfiguration {
        .init(surface: surface, tint: tint, borderShape: shape.value)
    }
}
