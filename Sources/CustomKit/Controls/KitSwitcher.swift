import SwiftUI

public struct KitSwitcher: View {
    @Binding private var selection: Bool
    public var title: String
    public var subtitle: String
    public var tint: Color

    public init(selection: Binding<Bool>, title: String, subtitle: String = "", tint: Color = .teal) {
        _selection = selection
        self.title = title
        self.subtitle = subtitle
        self.tint = tint
    }

    public var body: some View {
        Toggle(isOn: $selection) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(tint)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .frame(minHeight: 54)
        .glassEffect(.regular, in: .capsule)
        .sensoryFeedback(.selection, trigger: selection)
    }
}
