import SwiftUI

/// Configures native glass while the consuming control owns its behavior.
public struct NativeGlassButtonConfiguration {
    public enum Surface: Equatable, Sendable {
        case regular
        case prominent
    }

    public var surface: Surface
    public var tint: Color
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
