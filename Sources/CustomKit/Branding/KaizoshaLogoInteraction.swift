import CoreGraphics
import Foundation

@available(iOS 26.0, *)
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

}
