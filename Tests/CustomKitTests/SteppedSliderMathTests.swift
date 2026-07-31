//
//  SteppedSliderMathTests.swift
//  CustomKitTests
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import CoreGraphics
import SwiftUI
import Testing

@testable import CustomKit

@Suite("Stepped slider policy")
struct SteppedSliderMathTests {
    @Test("Stops are finite, unique, and sorted")
    func normalizesStops() {
        let result = SteppedSliderMath.normalizedStops(
            [2, .nan, 1, 2, .infinity, -.infinity, -1],
            fallback: 7
        )

        #expect(result == [-1, 1, 2])
    }

    @Test("An empty normalized collection uses a safe fallback")
    func fallsBackForInvalidStops() {
        #expect(
            SteppedSliderMath.normalizedStops(
                [.nan, .infinity],
                fallback: 3
            ) == [3]
        )
        #expect(
            SteppedSliderMath.normalizedStops(
                [],
                fallback: .nan
            ) == [0]
        )
    }

    @Test("Nearest stop clamps naturally and resolves ties downward")
    func findsNearestStop() {
        let stops = [0.0, 2, 4]

        #expect(SteppedSliderMath.nearestIndex(to: -10, in: stops) == 0)
        #expect(SteppedSliderMath.nearestIndex(to: 1, in: stops) == 0)
        #expect(SteppedSliderMath.nearestIndex(to: 3.2, in: stops) == 2)
        #expect(SteppedSliderMath.nearestIndex(to: 99, in: stops) == 2)
        #expect(SteppedSliderMath.nearestIndex(to: .nan, in: stops) == 0)
    }

    @Test("Stops use equal visual spacing")
    func positionsStops() {
        let left = SteppedSliderMath.position(
            for: 0,
            count: 5,
            width: 280,
            railHeight: 44,
            direction: .leftToRight
        )
        let center = SteppedSliderMath.position(
            for: 2,
            count: 5,
            width: 280,
            railHeight: 44,
            direction: .leftToRight
        )
        let right = SteppedSliderMath.position(
            for: 4,
            count: 5,
            width: 280,
            railHeight: 44,
            direction: .leftToRight
        )

        #expect(left == 22)
        #expect(center == 140)
        #expect(right == 258)
    }

    @Test("Right-to-left presentation mirrors every stop")
    func mirrorsStopPositions() {
        let low = SteppedSliderMath.position(
            for: 0,
            count: 5,
            width: 280,
            railHeight: 44,
            direction: .rightToLeft
        )
        let high = SteppedSliderMath.position(
            for: 4,
            count: 5,
            width: 280,
            railHeight: 44,
            direction: .rightToLeft
        )

        #expect(low == 258)
        #expect(high == 22)
    }

    @Test("A one-stop slider stays centered")
    func centersSingleStop() {
        #expect(
            SteppedSliderMath.position(
                for: 0,
                count: 1,
                width: 280,
                railHeight: 44,
                direction: .leftToRight
            ) == 140
        )
        #expect(
            SteppedSliderMath.position(
                for: 0,
                count: 1,
                width: 280,
                railHeight: 44,
                direction: .rightToLeft
            ) == 140
        )
    }

    @Test("Drag geometry shares the marker span")
    func mapsDragToStops() {
        let next = SteppedSliderMath.index(
            initialIndex: 0,
            horizontalTranslation: 30,
            width: 280,
            railHeight: 52,
            count: 5,
            sensitivity: 1,
            direction: .leftToRight
        )
        let mirroredNext = SteppedSliderMath.index(
            initialIndex: 0,
            horizontalTranslation: -30,
            width: 280,
            railHeight: 52,
            count: 5,
            sensitivity: 1,
            direction: .rightToLeft
        )
        let clamped = SteppedSliderMath.index(
            initialIndex: 2,
            horizontalTranslation: 2_000,
            width: 280,
            railHeight: 52,
            count: 5,
            sensitivity: 1,
            direction: .leftToRight
        )

        #expect(next == 1)
        #expect(mirroredNext == 1)
        #expect(clamped == 4)
    }

    @Test("Sensitivity changes do not move a stationary drag")
    func keepsIncrementalDragStable() {
        let initialPosition = SteppedSliderMath.adjustedPosition(
            from: 1,
            horizontalTranslation: 20,
            width: 280,
            railHeight: 52,
            count: 5,
            sensitivity: 1,
            direction: .leftToRight
        )
        let stationaryPosition = SteppedSliderMath.adjustedPosition(
            from: initialPosition,
            horizontalTranslation: 0,
            width: 280,
            railHeight: 52,
            count: 5,
            sensitivity: 0.35,
            direction: .leftToRight
        )

        #expect(stationaryPosition == initialPosition)
    }

    @Test("Invalid and degenerate drag geometry stays safe")
    func handlesDegenerateDragGeometry() {
        #expect(
            SteppedSliderMath.index(
                initialIndex: 1,
                horizontalTranslation: .nan,
                width: 0,
                railHeight: .infinity,
                count: 3,
                sensitivity: .nan,
                direction: .leftToRight
            ) == 1
        )
        #expect(
            SteppedSliderMath.index(
                initialIndex: 0,
                horizontalTranslation: 100,
                width: 0,
                railHeight: 44,
                count: 1,
                sensitivity: 1,
                direction: .leftToRight
            ) == 0
        )
    }

    @Test(
        "Vertical travel selects the expected fine-scrub band",
        arguments: [
            (CGFloat(0), CGFloat(1)),
            (CGFloat(23.9), CGFloat(1)),
            (CGFloat(24), CGFloat(0.65)),
            (CGFloat(43.9), CGFloat(0.65)),
            (CGFloat(44), CGFloat(0.35)),
            (CGFloat(-100), CGFloat(0.35)),
        ]
    )
    func appliesFineScrubbing(
        verticalDistance: CGFloat,
        expected: CGFloat
    ) {
        let result = SteppedSliderMath.sensitivity(
            verticalDistance: verticalDistance,
            force: 0,
            maximumPossibleForce: 0
        )

        #expect(result == expected)
    }

    @Test("Pressure sensitivity is bounded")
    func boundsPressureSensitivity() {
        let light = SteppedSliderMath.sensitivity(
            verticalDistance: 0,
            force: 0.01,
            maximumPossibleForce: 1
        )
        let reference = SteppedSliderMath.sensitivity(
            verticalDistance: 0,
            force: 0.25,
            maximumPossibleForce: 1
        )
        let heavy = SteppedSliderMath.sensitivity(
            verticalDistance: 0,
            force: 1,
            maximumPossibleForce: 1
        )

        #expect(light == 0.5)
        #expect(reference == 1)
        #expect(heavy == 1.35)
    }

    @Test("Progress fill grows from the semantic low edge")
    func laysOutFillDirection() {
        let leftToRight = SteppedSliderMath.fillFrame(
            knobCenterX: 22,
            railWidth: 280,
            railHeight: 44,
            direction: .leftToRight
        )
        let rightToLeft = SteppedSliderMath.fillFrame(
            knobCenterX: 258,
            railWidth: 280,
            railHeight: 44,
            direction: .rightToLeft
        )

        #expect(leftToRight == CGRect(x: 0, y: 0, width: 44, height: 44))
        #expect(rightToLeft == CGRect(x: 236, y: 0, width: 44, height: 44))
    }

    @Test("Automatic direction follows the host layout")
    func resolvesDirection() {
        #expect(
            SteppedSliderDirection.leftToRight.resolved(for: .rightToLeft)
                == .leftToRight
        )
        #expect(
            SteppedSliderDirection.rightToLeft.resolved(for: .leftToRight)
                == .rightToLeft
        )
        #expect(
            SteppedSliderDirection.automatic.resolved(for: .rightToLeft)
                == .rightToLeft
        )
    }
}
