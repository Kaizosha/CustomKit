//
//  SliderMath.swift
//  CustomKit
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import CoreGraphics

enum SliderMath {
    static let dragActivationDistance: CGFloat = 4

    static func normalizedStops(_ values: [Double], fallback: Double) -> [Double] {
        let finiteValues = values.filter(\.isFinite)
        let result = Array(Set(finiteValues)).sorted()

        guard result.isEmpty else {
            return result
        }

        return [fallback.isFinite ? fallback : 0]
    }

    static func nearestIndex(to value: Double, in stops: [Double]) -> Int {
        guard !stops.isEmpty else {
            return 0
        }

        let finiteValue = value.isFinite ? value : stops[0]
        var bestIndex = 0
        var bestDistance = abs(stops[0] - finiteValue)

        for index in stops.indices.dropFirst() {
            let distance = abs(stops[index] - finiteValue)
            if distance < bestDistance {
                bestIndex = index
                bestDistance = distance
            }
        }

        return bestIndex
    }

    static func position(
        for index: Int,
        count: Int,
        width: CGFloat,
        railHeight: CGFloat,
        direction: SliderResolvedDirection
    ) -> CGFloat {
        let safeWidth = max(width.finiteOrZero, 0)
        guard count > 1 else {
            return safeWidth / 2
        }

        let clampedIndex = min(max(index, 0), count - 1)
        let inset = min(max(railHeight.finiteOrZero / 2, 0), safeWidth / 2)
        let usableWidth = max(safeWidth - (inset * 2), 0)
        let progress = CGFloat(clampedIndex) / CGFloat(count - 1)
        let directedProgress = direction == .rightToLeft ? 1 - progress : progress
        return inset + (directedProgress * usableWidth)
    }

    static func index(
        initialIndex: Int,
        horizontalTranslation: CGFloat,
        width: CGFloat,
        railHeight: CGFloat,
        count: Int,
        sensitivity: CGFloat,
        direction: SliderResolvedDirection
    ) -> Int {
        let proposedPosition = adjustedPosition(
            from: CGFloat(initialIndex),
            horizontalTranslation: horizontalTranslation,
            width: width,
            railHeight: railHeight,
            count: count,
            sensitivity: sensitivity,
            direction: direction
        )
        return index(for: proposedPosition, count: count)
    }

    static func adjustedPosition(
        from currentPosition: CGFloat,
        horizontalTranslation: CGFloat,
        width: CGFloat,
        railHeight: CGFloat,
        count: Int,
        sensitivity: CGFloat,
        direction: SliderResolvedDirection
    ) -> CGFloat {
        guard count > 1 else {
            return 0
        }

        let safeWidth = max(width.finiteOrZero, 0)
        let inset = min(max(railHeight.finiteOrZero / 2, 0), safeWidth / 2)
        let usableWidth = max(safeWidth - (inset * 2), 1)
        let pointsPerStop = usableWidth / CGFloat(count - 1)
        let directionalTranslation = direction == .rightToLeft
            ? -horizontalTranslation.finiteOrZero
            : horizontalTranslation.finiteOrZero
        let safeSensitivity = max(sensitivity.finiteOrZero, 0)
        let proposed = currentPosition.finiteOrZero
            + ((directionalTranslation / pointsPerStop) * safeSensitivity)

        return min(max(proposed, 0), CGFloat(count - 1))
    }

    static func index(for position: CGFloat, count: Int) -> Int {
        guard count > 1 else {
            return 0
        }

        let clampedPosition = min(
            max(position.finiteOrZero, 0),
            CGFloat(count - 1)
        )
        return Int(clampedPosition.rounded())
    }

    static func sensitivity(
        verticalDistance: CGFloat,
        force: CGFloat,
        maximumPossibleForce: CGFloat
    ) -> CGFloat {
        let distance = abs(verticalDistance.finiteOrZero)
        let fineScrubFactor: CGFloat

        switch distance {
        case 44...:
            fineScrubFactor = 0.35
        case 24...:
            fineScrubFactor = 0.65
        default:
            fineScrubFactor = 1
        }

        guard
            force.isFinite,
            maximumPossibleForce.isFinite,
            force > 0,
            maximumPossibleForce > 0
        else {
            return fineScrubFactor
        }

        let normalizedForce = force / maximumPossibleForce
        let forceFactor = min(max(normalizedForce / 0.25, 0.5), 1.35)
        return fineScrubFactor * forceFactor
    }

    static func fillFrame(
        knobCenterX: CGFloat,
        railWidth: CGFloat,
        railHeight: CGFloat,
        direction: SliderResolvedDirection
    ) -> CGRect {
        let safeWidth = max(railWidth.finiteOrZero, 0)
        let radius = max(railHeight.finiteOrZero / 2, 0)
        let center = min(max(knobCenterX.finiteOrZero, 0), safeWidth)

        switch direction {
        case .leftToRight:
            return CGRect(
                x: 0,
                y: 0,
                width: min(center + radius, safeWidth),
                height: max(railHeight.finiteOrZero, 0)
            )
        case .rightToLeft:
            let start = max(center - radius, 0)
            return CGRect(
                x: start,
                y: 0,
                width: max(safeWidth - start, 0),
                height: max(railHeight.finiteOrZero, 0)
            )
        }
    }
}

private extension BinaryFloatingPoint {
    var finiteOrZero: Self {
        isFinite ? self : 0
    }
}
