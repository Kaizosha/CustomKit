import KaizoshaInterfaceKit
import SwiftUI

struct MasonryExample: View {
    @State private var minimumWidth: CGFloat = 148
    @State private var horizontalInset: CGFloat = 20
    @State private var columnSpacing: CGFloat = 16
    @State private var rowSpacing: CGFloat = 16
    @State private var count = 18
    @State private var automaticWidth = true
    @State private var rightToLeft = false

    var body: some View {
        ComponentPage(title: "Masonry Layout", fillsCanvas: true, code: code, reset: {
            minimumWidth = 148; horizontalInset = 20; columnSpacing = 16; rowSpacing = 16
            count = 18; automaticWidth = true; rightToLeft = false
        }) {
            ScrollView {
                MasonryGrid(minimumColumnWidth: automaticWidth ? nil : minimumWidth, horizontalInset: horizontalInset, columnSpacing: columnSpacing, rowSpacing: rowSpacing) {
                    ForEach(0..<count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary.opacity(0.045 + Double(index % 4) * 0.035))
                            .aspectRatio(ratios[index % ratios.count], contentMode: .fit)
                            .overlay {
                                Text(String(format: "%02d", index + 1))
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(6)
                            .accessibilityLabel("Tile \(index + 1)")
                            .accessibilityIdentifier("masonry.tile.\(index)")
                    }
                }
                .environment(\.layoutDirection, rightToLeft ? .rightToLeft : .leftToRight)
            }
            .accessibilityIdentifier("masonry.element")
        } controls: {
            Section("Layout") {
                Toggle("Automatic column width", isOn: $automaticWidth)
                ValueControl(title: "Minimum column width", value: $minimumWidth, range: 90...300, suffix: " pt")
                    .disabled(automaticWidth)
                ValueControl(title: "Horizontal inset", value: $horizontalInset, range: 0...48, suffix: " pt")
                ValueControl(title: "Column spacing", value: $columnSpacing, range: 0...40, suffix: " pt")
                ValueControl(title: "Row spacing", value: $rowSpacing, range: 0...40, suffix: " pt")
                Stepper("Tiles: \(count)", value: $count, in: 3...36)
                Toggle("Right to left", isOn: $rightToLeft)
            }
        }
    }

    private let ratios: [CGFloat] = [0.72, 1.3, 0.9, 1.6, 0.62, 1.1, 0.8]
    private let code = """
    import KaizoshaInterfaceKit

    ScrollView {
        MasonryGrid {
            ForEach(items) { item in
                Image(uiImage: item.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(6)
            }
        }
    }

    // Or use MasonryLayout directly with your own sizing.
    MasonryLayout(minimumColumnWidth: 148) {
        // Your views.
    }
    """
}
