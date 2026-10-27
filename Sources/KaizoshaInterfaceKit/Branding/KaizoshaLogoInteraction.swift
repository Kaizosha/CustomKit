//
//  KaizoshaLogoInteraction.swift
//  KaizoshaInterfaceKit
//

import CoreGraphics
import Foundation

/// Direction resolution, elastic travel, release velocity, and tactile spacing
/// for the directly draggable Kaizōsha mark.
nonisolated enum KaizoshaLogoDragPolicy {
    static func magnitude(of value: CGSize) -> CGFloat {
        hypot(value.width, value.height)
    }

    static func resolvedDirection(
        translation: CGSize,
        velocity: CGSize
    ) -> CGVector {
        let translationDistance = magnitude(of: translation)
        if translationDistance > 0.001 {
            return CGVector(
                dx: translation.width / translationDistance,
                dy: translation.height / translationDistance
            )
        }

        let speed = magnitude(of: velocity)
        guard speed > 0.001 else {
            return CGVector(dx: 0, dy: 1)
        }

        return CGVector(
            dx: velocity.width / speed,
            dy: velocity.height / speed
        )
    }

    static func rubberBandedDistance(
        _ distance: CGFloat,
        limit: CGFloat
    ) -> CGFloat {
        guard distance > 0, limit > 0 else {
            return 0
        }

        return limit * (1 - exp(-distance / limit))
    }

    /// Keeps the first part of a large drag close to the finger, then adds a
    /// soft asymptotic limit so the mark feels elastic instead of detached.
    static func extendedRubberBandedDistance(
        _ distance: CGFloat,
        freeDistance: CGFloat,
        limit: CGFloat
    ) -> CGFloat {
        guard distance > 0, limit > 0 else {
            return 0
        }
        let boundedFreeDistance = min(max(freeDistance, 0), limit)
        guard distance > boundedFreeDistance,
            limit > boundedFreeDistance
        else {
            return min(distance, limit)
        }

        let elasticRange = limit - boundedFreeDistance
        return boundedFreeDistance
            + elasticRange
            * (1 - exp(-(distance - boundedFreeDistance) / elasticRange))
    }

    static func springInitialVelocity(
        translation: CGSize,
        velocity: CGSize
    ) -> Double {
        let distance = magnitude(of: translation)
        guard distance > 1 else {
            return 0
        }

        let towardAnchor = CGVector(
            dx: -translation.width / distance,
            dy: -translation.height / distance
        )
        let velocityTowardAnchor =
            velocity.width * towardAnchor.dx
            + velocity.height * towardAnchor.dy
        let normalized = velocityTowardAnchor / max(distance, 28)
        return Double(min(max(normalized, -4), 4))
    }

    static func textureFeedbackSpacing(velocity: CGSize) -> CGFloat {
        let normalizedSpeed = min(magnitude(of: velocity) / 2_200, 1)
        return 7 + normalizedSpeed * 6
    }

    static func textureFeedbackIntensity(
        translation: CGSize,
        velocity: CGSize
    ) -> CGFloat {
        let tension = min(magnitude(of: translation) / 160, 1)
        let normalizedSpeed = min(magnitude(of: velocity) / 2_200, 1)
        return min(0.2 + tension * 0.2 + normalizedSpeed * 0.14, 0.54)
    }

    static func releaseFeedbackIntensity(
        translation: CGSize,
        velocity: CGSize
    ) -> CGFloat {
        let tension = min(magnitude(of: translation) / 180, 1)
        let normalizedSpeed = min(magnitude(of: velocity) / 2_200, 1)
        return min(0.42 + tension * 0.24 + normalizedSpeed * 0.18, 0.84)
    }
}
