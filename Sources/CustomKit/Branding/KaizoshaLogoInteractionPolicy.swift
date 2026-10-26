import CoreGraphics

@available(iOS 26.0, *)
nonisolated struct KaizoshaLogoInteractionPresentation: Equatable {
    let offset: CGSize
    let direction: CGVector
    let scaleX: CGFloat
    let scaleY: CGFloat
    let tiltDegrees: Double
    let stretch: CGFloat
    let normalizedSpeed: CGFloat
    let refractionVelocity: CGFloat
}

@available(iOS 26.0, *)
nonisolated enum KaizoshaLogoInteractionPolicy {
    static let maximumPresentedDistance: CGFloat = 176
    static let freePresentedDistance: CGFloat = 76
    static let reducedMotionMaximumDistance: CGFloat = 12
    static let minimumReleaseFeedbackDistance: CGFloat = 6

    static func presentation(
        translation: CGSize,
        velocity: CGSize,
        reduceMotion: Bool
    ) -> KaizoshaLogoInteractionPresentation {
        let rawDistance = KaizoshaLogoDragPolicy.magnitude(of: translation)
        let speed = KaizoshaLogoDragPolicy.magnitude(of: velocity)
        let direction = KaizoshaLogoDragPolicy.resolvedDirection(
            translation: translation,
            velocity: velocity
        )
        let presentedDistance: CGFloat
        if reduceMotion {
            presentedDistance = KaizoshaLogoDragPolicy.rubberBandedDistance(
                rawDistance,
                limit: reducedMotionMaximumDistance
            )
        } else {
            presentedDistance =
                KaizoshaLogoDragPolicy.extendedRubberBandedDistance(
                    rawDistance,
                    freeDistance: freePresentedDistance,
                    limit: maximumPresentedDistance
                )
        }
        let offset = CGSize(
            width: direction.dx * presentedDistance,
            height: direction.dy * presentedDistance
        )

        guard !reduceMotion else {
            return KaizoshaLogoInteractionPresentation(
                offset: offset,
                direction: direction,
                scaleX: 1,
                scaleY: 1,
                tiltDegrees: 0,
                stretch: 0,
                normalizedSpeed: 0,
                refractionVelocity: 0
            )
        }

        let dragProgress = min(rawDistance / 210, 1)
        let normalizedSpeed = min(speed / 2_400, 1)
        let deformation = min(
            dragProgress * 0.17 + normalizedSpeed * 0.11,
            0.25
        )
        let horizontalInfluence = abs(direction.dx)
        let verticalInfluence = abs(direction.dy)
        let scaleX = max(
            1
                + horizontalInfluence * deformation
                - verticalInfluence * deformation * 0.2,
            0.93
        )
        let scaleY = max(
            1
                + verticalInfluence * deformation
                - horizontalInfluence * deformation * 0.2,
            0.93
        )
        let horizontalVelocity = min(
            max(velocity.width / 2_400, -1),
            1
        )
        let tilt = min(
            max(
                Double(direction.dx * (4 + dragProgress * 6))
                    + Double(horizontalVelocity * 3),
                -11
            ),
            11
        )

        return KaizoshaLogoInteractionPresentation(
            offset: offset,
            direction: direction,
            scaleX: scaleX,
            scaleY: scaleY,
            tiltDegrees: tilt,
            stretch: min(dragProgress * 0.58 + normalizedSpeed * 0.42, 1),
            normalizedSpeed: normalizedSpeed,
            refractionVelocity: min(
                max(
                    (velocity.width + velocity.height * 0.24) / 2_400,
                    -1
                ),
                1
            )
        )
    }

}
