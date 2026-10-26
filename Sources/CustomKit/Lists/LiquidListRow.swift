import SwiftUI

public struct LiquidListRow<Content: View>: View {
    public var isSelected: Bool
    private let action: () -> Void
    private let content: Content
    @Environment(\.isEnabled) private var isEnabled

    public init(
        isSelected: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action) {
            content
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .background(isSelected && isEnabled ? Color.accentColor.opacity(0.10) : .clear, in: .capsule)
        .glassEffect(.regular.interactive(isEnabled), in: .capsule)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
