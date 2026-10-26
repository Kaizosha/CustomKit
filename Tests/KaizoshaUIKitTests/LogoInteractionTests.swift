import CoreGraphics
import Testing
@testable import KaizoshaUIKit

struct LogoInteractionTests {
    @Test func reducedMotionKeepsTheMarkBoundedWithoutDeformation() {
        let presentation = KaizoshaLogoInteractionPolicy.presentation(
            translation: CGSize(width: 1_000, height: -1_000),
            velocity: CGSize(width: 5_000, height: -5_000),
            reduceMotion: true
        )

        #expect(KaizoshaLogoDragPolicy.magnitude(of: presentation.offset) <= 12.001)
        #expect(presentation.scaleX == 1)
        #expect(presentation.scaleY == 1)
        #expect(presentation.tiltDegrees == 0)
        #expect(presentation.stretch == 0)
    }

    @Test func longDragRetainsDirectionAndRemainsAttachedToItsAnchor() {
        let presentation = KaizoshaLogoInteractionPolicy.presentation(
            translation: CGSize(width: 100_000, height: -100_000),
            velocity: .zero,
            reduceMotion: false
        )

        #expect(presentation.offset.width > 0)
        #expect(presentation.offset.height < 0)
        #expect(KaizoshaLogoDragPolicy.magnitude(of: presentation.offset) <= 176.001)
    }

    @Test func releaseVelocityDistinguishesMovementTowardAndAwayFromAnchor() {
        let translation = CGSize(width: 100, height: 0)
        let toward = KaizoshaLogoDragPolicy.springInitialVelocity(
            translation: translation,
            velocity: CGSize(width: -1_000, height: 0)
        )
        let away = KaizoshaLogoDragPolicy.springInitialVelocity(
            translation: translation,
            velocity: CGSize(width: 1_000, height: 0)
        )

        #expect(toward > 0)
        #expect(away < 0)
        #expect(abs(toward) <= 4)
        #expect(abs(away) <= 4)
    }

    @Test func hapticTextureAccumulatesDirectionReversals() {
        var tracker = KaizoshaLogoHapticTextureTracker()
        tracker.begin()
        #expect(tracker.feedback(translation: CGSize(width: 4, height: 0), velocity: .zero) == nil)
        #expect(tracker.feedback(translation: .zero, velocity: .zero) != nil)
        tracker.reset()
        #expect(tracker.feedback(translation: CGSize(width: 1, height: 0), velocity: .zero) == nil)
    }
}
