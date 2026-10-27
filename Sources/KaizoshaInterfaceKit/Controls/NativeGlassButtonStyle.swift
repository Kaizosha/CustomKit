import SwiftUI

/// Configures native glass while the consuming control owns its behavior.
public struct NativeGlassButtonConfiguration {
    /// Chooses the system's regular or prominent interactive glass surface.
    public enum Surface: Hashable, Sendable {
        case regular
        case prominent
    }

    /// The native surface to apply; prominent is the default.
    public var surface: Surface
    /// The enabled surface tint. Unavailable prominent buttons use the app accent.
    public var tint: Color
    /// The native button border shape, without imposing label size or padding.
    public var borderShape: ButtonBorderShape

    public init(
        surface: Surface = .prominent,
        tint: Color = .accentColor,
        borderShape: ButtonBorderShape = .capsule
    ) {
        self.surface = surface
        self.tint = tint
        self.borderShape = borderShape
    }
}

extension View {
    /// Styles native buttons, including menus using the native button menu style.
    ///
    /// Prominent labels follow the system background color. Disabled prominent
    /// controls use native confirmation styling and the app accent while retaining
    /// the inherited disabled state.
    @ViewBuilder
    public func kaizoshaGlassButtonStyle(
        _ configuration: NativeGlassButtonConfiguration = .init()
    ) -> some View {
        switch configuration.surface {
        case .regular:
            buttonStyle(.glass)
                .buttonBorderShape(configuration.borderShape)
                .tint(configuration.tint)
        case .prominent:
            buttonStyle(NativeProminentGlassButtonStyle(
                tint: configuration.tint,
                borderShape: configuration.borderShape
            ))
        }
    }
}

/// Adapts the native label and unavailable appearance without enabling interaction.
private struct NativeProminentGlassButtonStyle: PrimitiveButtonStyle {
    let tint: Color
    let borderShape: ButtonBorderShape

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        Button(role: isEnabled ? configuration.role : .confirm) {
            configuration.trigger()
        } label: {
            configuration.label
                .foregroundStyle(Color(uiColor: .systemBackground))
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(borderShape)
        .tint(isEnabled ? tint : .accentColor)
    }
}
