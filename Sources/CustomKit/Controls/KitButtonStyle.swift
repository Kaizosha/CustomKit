import SwiftUI

public enum KitButtonRole: String, CaseIterable, Identifiable, Sendable {
    case primary, neutral, destructive, reset, success, working
    public var id: Self { self }

    public var tint: Color {
        switch self {
        case .primary: .teal
        case .neutral: .primary
        case .destructive: .red
        case .reset: .orange
        case .success: .green
        case .working: .blue
        }
    }
}

public struct KitButtonStyle: PrimitiveButtonStyle {
    public var role: KitButtonRole
    public var tint: Color?
    public var hapticsEnabled: Bool

    public init(role: KitButtonRole = .primary, tint: Color? = nil, hapticsEnabled: Bool = true) {
        self.role = role
        self.tint = tint
        self.hapticsEnabled = hapticsEnabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        AnimatedKitButton(configuration: configuration, style: self)
    }
}

public extension View {
    func customKitButton(_ role: KitButtonRole = .primary, tint: Color? = nil) -> some View {
        buttonStyle(KitButtonStyle(role: role, tint: tint))
    }
}

private struct AnimatedKitButton: View {
    let configuration: PrimitiveButtonStyleConfiguration
    let style: KitButtonStyle
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var trigger = 0

    var body: some View {
        Group {
            if style.role == .primary || style.role == .success {
                button.buttonStyle(.glassProminent)
            } else {
                button.buttonStyle(.glass)
            }
        }
        .buttonBorderShape(.capsule)
        .tint(style.tint ?? style.role.tint)
        .sensoryFeedback(.selection, trigger: trigger) { _, _ in style.hapticsEnabled }
    }

    private var button: some View {
        Button(role: configuration.role) {
            trigger &+= 1
            configuration.trigger()
        } label: {
            animatedLabel
        }
    }

    @ViewBuilder
    private var animatedLabel: some View {
        if reduceMotion {
            configuration.label.symbolEffectsRemoved()
        } else {
            switch style.role {
            case .primary:
                configuration.label.symbolEffect(.bounce.up.wholeSymbol, options: .nonRepeating, value: trigger)
            case .neutral:
                configuration.label.symbolEffect(.breathe.pulse.wholeSymbol, options: .nonRepeating, value: trigger)
            case .destructive:
                configuration.label.symbolEffect(.wiggle.custom(angle: 12).wholeSymbol, options: .nonRepeating, value: trigger)
            case .reset:
                configuration.label.symbolEffect(.rotate.counterClockwise.wholeSymbol, options: .nonRepeating, value: trigger)
            case .success:
                configuration.label.symbolEffect(.bounce.up.byLayer, options: .nonRepeating, value: trigger)
            case .working:
                configuration.label.symbolEffect(.rotate.clockwise.wholeSymbol, options: .nonRepeating, value: trigger)
            }
        }
    }
}
