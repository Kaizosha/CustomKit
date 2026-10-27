import SwiftUI
import Testing
@testable import KaizoshaInterfaceKit

@Suite("Masonry placement")
struct MasonryTests {
    @Test("Items retain order and choose the shortest column")
    func shortestColumnPlacement() {
        let metrics = metrics(width: 390)
        let geometry = MasonryGeometry(
            metrics: metrics,
            heights: [100, 200, 50, 80],
            isRightToLeft: false
        )

        #expect(metrics.columns == 2)
        #expect(metrics.columnWidth == 167)
        #expect(geometry.frames == [
            CGRect(x: 20, y: 16, width: 167, height: 100),
            CGRect(x: 203, y: 16, width: 167, height: 200),
            CGRect(x: 20, y: 132, width: 167, height: 50),
            CGRect(x: 20, y: 198, width: 167, height: 80)
        ])
        #expect(geometry.size == CGSize(width: 390, height: 294))
    }

    @Test("Right-to-left mirrors physical columns without reordering items")
    func mirrorsColumns() {
        let metrics = metrics(width: 560)
        let heights: [CGFloat] = [120, 80, 160, 60, 110]
        let leftToRight = MasonryGeometry(metrics: metrics, heights: heights, isRightToLeft: false)
        let rightToLeft = MasonryGeometry(metrics: metrics, heights: heights, isRightToLeft: true)

        for (left, right) in zip(leftToRight.frames, rightToLeft.frames) {
            #expect(abs(left.minX - (metrics.width - right.maxX)) < 0.0001)
            #expect(left.minY == right.minY)
            #expect(left.size == right.size)
        }
        #expect(leftToRight.size == rightToLeft.size)
    }

    @Test("Accessibility uses wider columns while narrow widths stay contained")
    func adaptsColumnCount() {
        let regular = metrics(width: 600)
        let accessible = metrics(width: 600, isAccessibilitySize: true)
        #expect(regular.columns == 3)
        #expect(accessible.columns == 2)
        #expect(metrics(width: 390, isAccessibilitySize: true).columns == 1)

        let narrow = metrics(width: 20)
        #expect(narrow.columns == 1)
        #expect(narrow.horizontalInset * 2 + narrow.columnWidth <= narrow.width)
    }

    @Test("Empty content has no height and unconstrained width uses one column")
    func emptyAndUnconstrained() {
        let unconstrained = metrics(width: nil)
        #expect(unconstrained.width == 188)
        #expect(unconstrained.columns == 1)
        #expect(unconstrained.columnWidth == 148)
        #expect(MasonryGeometry(metrics: unconstrained, heights: [], isRightToLeft: false).size.height == 0)
    }

    @Test("Extreme layout values remain finite and keep allocation bounded")
    func extremeFiniteValues() {
        let extreme = CGFloat.greatestFiniteMagnitude
        let cases: [(CGFloat?, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (nil, 148, extreme, 16, 16),
            (extreme, 1, 0, 0, 0),
            (extreme, extreme, extreme, extreme, extreme),
            (.infinity, .nan, .infinity, .nan, -.infinity)
        ]
        for (width, minimum, inset, columnSpacing, rowSpacing) in cases {
            let metrics = MasonryMetrics(
                proposedWidth: width,
                minimumColumnWidth: minimum,
                horizontalInset: inset,
                columnSpacing: columnSpacing,
                rowSpacing: rowSpacing
            )
            #expect(metrics.width.isFinite)
            #expect(metrics.columnWidth.isFinite)
            #expect((1...4096).contains(metrics.columns))
            let geometry = MasonryGeometry(
                metrics: metrics,
                heights: [extreme, extreme, .infinity, .nan, 100],
                isRightToLeft: false
            )
            #expect(geometry.size.width.isFinite)
            #expect(geometry.size.height.isFinite)
            #expect(geometry.frames.count == 5)
            #expect(geometry.frames.allSatisfy {
                $0.origin.x.isFinite && $0.origin.y.isFinite
                    && $0.width.isFinite && $0.height.isFinite
            })
        }
    }

    private func metrics(width: CGFloat?, isAccessibilitySize: Bool = false) -> MasonryMetrics {
        MasonryMetrics(
            proposedWidth: width,
            minimumColumnWidth: MasonryMetrics.defaultMinimumColumnWidth(
                isAccessibilitySize: isAccessibilitySize
            ),
            horizontalInset: 20,
            columnSpacing: 16,
            rowSpacing: 16
        )
    }
}
