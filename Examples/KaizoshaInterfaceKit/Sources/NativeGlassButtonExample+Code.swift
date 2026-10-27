import SwiftUI

extension NativeGlassButtonExample {
    static func code(for settings: GlassButtonSettings, in environment: EnvironmentValues) -> String {
        let title = swiftLiteral(settings.title)
        let symbol = swiftLiteral(settings.symbol)
        let tint = settings.tint.resolve(in: environment)
        let surface = settings.surface == .regular ? "regular" : "prominent"
        let role = settings.role == .none ? "nil" : ".\(settings.role)"
        let control: String
        if settings.preset == .menu {
            control = """
                Menu(\(title), systemImage: \(symbol)) {
                    Button("Run command", systemImage: "checkmark") {
                        // Run your command.
                    }
                }
                .menuStyle(.button)
            """
        } else {
            control = """
                Button(\(title), systemImage: \(symbol), role: \(role)) {
                    // Perform your action.
                }
            """
        }
        return """
        import KaizoshaInterfaceKit
        import SwiftUI

        // Current customization. The tint is resolved for this appearance.
        VStack {
        \(control)
            .labelStyle(.\(settings.label))
            .kaizoshaGlassButtonStyle(.init(
                surface: .\(surface),
                tint: Color(.sRGB, red: \(tint.red), green: \(tint.green), blue: \(tint.blue), opacity: \(tint.opacity)),
                borderShape: .\(settings.shape)
            ))
            .controlSize(.\(settings.size))
            .accessibilityLabel(\(title))
            .disabled(\(!settings.enabled)) // Local availability.
        }
        .disabled(\(settings.ancestorDisabled)) // Ancestor availability.

        // Ready examples
        \(readyExamples)
        """
    }

    private static func swiftLiteral(_ value: String) -> String {
        var result = "\""
        for scalar in value.unicodeScalars {
            switch scalar.value {
            case 0x22: result += "\\\""
            case 0x5C: result += "\\\\"
            case 0...0x1F, 0x7F...0x9F, 0x2028, 0x2029:
                result += "\\u{\(String(scalar.value, radix: 16))}"
            default: result.unicodeScalars.append(scalar)
            }
        }
        return result + "\""
    }

    private static let readyExamples = """
    // Keep actions, roles, labels and availability on native controls.
    Button("Continue", systemImage: "arrow.right") {
        // Continue your workflow.
    }
    .kaizoshaGlassButtonStyle()

    Button("Done", systemImage: "checkmark", role: .confirm) {
        // Commit your changes.
    }
    .kaizoshaGlassButtonStyle()

    Button("Help", systemImage: "questionmark") {
        // Present your help.
    }
    .labelStyle(.iconOnly)
    .kaizoshaGlassButtonStyle(.init(tint: .yellow, borderShape: .circle))
    .accessibilityHint("Opens help")

    Button("Reset", systemImage: "arrow.counterclockwise") {
        // Reset your settings.
    }
    .labelStyle(.iconOnly)
    .kaizoshaGlassButtonStyle(.init(tint: .orange, borderShape: .circle))
    .accessibilityHint("Restores default settings")
    .disabled(false) // Replace with your workflow's availability.

    Button("Delete", systemImage: "trash", role: .destructive) {
        // Delete the selected item.
    }
    .kaizoshaGlassButtonStyle(.init(tint: .red))

    Menu("Actions", systemImage: "ellipsis") {
        Button("Run command", systemImage: "checkmark") {
            // Run your command.
        }
    }
    .menuStyle(.button)
    .kaizoshaGlassButtonStyle(.init(surface: .regular))
    """
}
