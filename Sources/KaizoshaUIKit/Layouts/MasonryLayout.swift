import SwiftUI

/// Places each child in the shortest column without changing its measured proportions.
public struct MasonryLayout: Layout {
    public var minimumColumnWidth: CGFloat
    public var horizontalInset: CGFloat
    public var columnSpacing: CGFloat
    public var rowSpacing: CGFloat
    public var layoutDirection: LayoutDirection

    public init(
        minimumColumnWidth: CGFloat = 148,
        horizontalInset: CGFloat = 20,
        columnSpacing: CGFloat = 16,
        rowSpacing: CGFloat = 16,
        layoutDirection: LayoutDirection = .leftToRight
    ) {
        self.minimumColumnWidth = minimumColumnWidth
        self.horizontalInset = horizontalInset
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.layoutDirection = layoutDirection
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        geometry(proposedWidth: proposal.width, subviews: subviews).size
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let geometry = geometry(proposedWidth: bounds.width, subviews: subviews)
        for (subview, frame) in zip(subviews, geometry.frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }

    private func geometry(proposedWidth: CGFloat?, subviews: Subviews) -> MasonryGeometry {
        let metrics = MasonryMetrics(
            proposedWidth: proposedWidth,
            minimumColumnWidth: minimumColumnWidth,
            horizontalInset: horizontalInset,
            columnSpacing: columnSpacing,
            rowSpacing: rowSpacing
        )
        let heights = subviews.map {
            $0.sizeThatFits(ProposedViewSize(width: metrics.columnWidth, height: nil)).height
        }
        return MasonryGeometry(
            metrics: metrics,
            heights: heights,
            isRightToLeft: layoutDirection == .rightToLeft
        )
    }
}

/// A masonry layout that follows the current reading direction and accessibility text size.
public struct MasonryGrid<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutDirection) private var layoutDirection

    public var minimumColumnWidth: CGFloat?
    public var horizontalInset: CGFloat
    public var columnSpacing: CGFloat
    public var rowSpacing: CGFloat
    private let content: Content

    public init(
        minimumColumnWidth: CGFloat? = nil,
        horizontalInset: CGFloat = 20,
        columnSpacing: CGFloat = 16,
        rowSpacing: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.minimumColumnWidth = minimumColumnWidth
        self.horizontalInset = horizontalInset
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.content = content()
    }

    public var body: some View {
        MasonryLayout(
            minimumColumnWidth: minimumColumnWidth
                ?? MasonryMetrics.defaultMinimumColumnWidth(
                    isAccessibilitySize: dynamicTypeSize.isAccessibilitySize
                ),
            horizontalInset: horizontalInset,
            columnSpacing: columnSpacing,
            rowSpacing: rowSpacing,
            layoutDirection: layoutDirection
        ) {
            content
        }
    }
}

struct MasonryMetrics {
    let width: CGFloat
    let horizontalInset: CGFloat
    let columnSpacing: CGFloat
    let rowSpacing: CGFloat
    let columns: Int
    let columnWidth: CGFloat

    init(
        proposedWidth: CGFloat?,
        minimumColumnWidth: CGFloat,
        horizontalInset: CGFloat,
        columnSpacing: CGFloat,
        rowSpacing: CGFloat
    ) {
        let minimum = minimumColumnWidth.isFinite ? max(1, minimumColumnWidth) : 148
        let inset = Self.nonnegative(horizontalInset, fallback: 20)
        let spacing = Self.nonnegative(columnSpacing, fallback: 16)
        let width = proposedWidth.flatMap { $0.isFinite ? max(0, $0) : nil }
            ?? minimum + inset * 2
        let resolvedInset = min(inset, width / 2)
        let available = width - resolvedInset * 2
        let columns = max(1, Int((available + spacing) / (minimum + spacing)))

        self.width = width
        self.horizontalInset = resolvedInset
        self.columnSpacing = spacing
        self.rowSpacing = Self.nonnegative(rowSpacing, fallback: 16)
        self.columns = columns
        self.columnWidth = max(0, (available - CGFloat(columns - 1) * spacing) / CGFloat(columns))
    }

    static func defaultMinimumColumnWidth(isAccessibilitySize: Bool) -> CGFloat {
        isAccessibilitySize ? 260 : 148
    }

    private static func nonnegative(_ value: CGFloat, fallback: CGFloat) -> CGFloat {
        value.isFinite ? max(0, value) : fallback
    }
}

struct MasonryGeometry {
    let frames: [CGRect]
    let size: CGSize

    init(metrics: MasonryMetrics, heights: [CGFloat], isRightToLeft: Bool) {
        var bottoms = Array(repeating: metrics.rowSpacing, count: metrics.columns)
        var frames: [CGRect] = []
        frames.reserveCapacity(heights.count)

        for height in heights {
            let column = bottoms.indices.min { bottoms[$0] < bottoms[$1] } ?? 0
            let physicalColumn = isRightToLeft ? metrics.columns - column - 1 : column
            let height = height.isFinite ? max(0, height) : 0
            let frame = CGRect(
                x: metrics.horizontalInset
                    + CGFloat(physicalColumn) * (metrics.columnWidth + metrics.columnSpacing),
                y: bottoms[column],
                width: metrics.columnWidth,
                height: height
            )
            frames.append(frame)
            bottoms[column] += height + metrics.rowSpacing
        }

        self.frames = frames
        self.size = CGSize(width: metrics.width, height: heights.isEmpty ? 0 : bottoms.max() ?? 0)
    }
}
