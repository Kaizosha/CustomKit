import SwiftUI

public struct KitSegment<Selection: Hashable>: Identifiable {
    public var title: String
    public var value: Selection
    public var systemImage: String?
    public var id: Selection { value }

    public init(_ title: String, value: Selection, systemImage: String? = nil) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
    }
}

public struct KitSegmentedControl<Selection: Hashable>: View {
    @Binding private var selection: Selection
    public var options: [KitSegment<Selection>]
    public var accessibilityLabel: String

    public init(
        selection: Binding<Selection>,
        options: [KitSegment<Selection>],
        accessibilityLabel: String = "Selection"
    ) {
        _selection = selection
        self.options = options
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Picker(accessibilityLabel, selection: $selection) {
            ForEach(options) { option in
                Group {
                    if let symbol = option.systemImage {
                        Label(option.title, systemImage: symbol)
                    } else {
                        Text(option.title)
                    }
                }
                .tag(option.value)
            }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .glassEffect(.regular, in: .capsule)
    }
}
