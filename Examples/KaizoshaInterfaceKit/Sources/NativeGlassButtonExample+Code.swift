extension NativeGlassButtonExample {
    static let code = """
    import KaizoshaInterfaceKit
    import SwiftUI

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
    .kaizoshaGlassButtonStyle(.init(borderShape: .circle))
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
