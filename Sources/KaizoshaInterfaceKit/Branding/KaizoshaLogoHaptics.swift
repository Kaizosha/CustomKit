//
//  KaizoshaLogoHaptics.swift
//  KaizoshaInterfaceKit
//

import UIKit

nonisolated struct KaizoshaLogoHapticTextureFeedback: Equatable {
    let intensity: CGFloat
}

/// Accumulates the finger's complete path so short samples and direction
/// reversals still produce tactile texture once enough travel has occurred.
nonisolated struct KaizoshaLogoHapticTextureTracker {
    private var lastTranslation = CGSize.zero
    private var accumulatedTravel: CGFloat = 0
    private var isTracking = false

    mutating func begin() {
        lastTranslation = .zero
        accumulatedTravel = 0
        isTracking = true
    }

    mutating func feedback(
        translation: CGSize,
        velocity: CGSize
    ) -> KaizoshaLogoHapticTextureFeedback? {
        if !isTracking {
            begin()
        }

        let segment = CGSize(
            width: translation.width - lastTranslation.width,
            height: translation.height - lastTranslation.height
        )
        lastTranslation = translation
        accumulatedTravel += KaizoshaLogoDragPolicy.magnitude(of: segment)

        let spacing = KaizoshaLogoDragPolicy.textureFeedbackSpacing(
            velocity: velocity
        )
        guard accumulatedTravel >= spacing else {
            return nil
        }

        accumulatedTravel.formTruncatingRemainder(dividingBy: spacing)
        return KaizoshaLogoHapticTextureFeedback(
            intensity: KaizoshaLogoDragPolicy.textureFeedbackIntensity(
                translation: translation,
                velocity: velocity
            )
        )
    }

    mutating func reset() {
        lastTranslation = .zero
        accumulatedTravel = 0
        isTracking = false
    }
}

@MainActor
final class KaizoshaLogoHapticDriver {
    enum Completion {
        case cancelled
        case returnedToAnchor
        case launchedIntoSingularity
    }

    private weak var feedbackView: UIView?
    private var textureGenerator: UIImpactFeedbackGenerator?
    private var releaseGenerator: UIImpactFeedbackGenerator?
    private var launchGenerator: UIImpactFeedbackGenerator?
    private var textureTracker = KaizoshaLogoHapticTextureTracker()
    private var isDragging = false

    deinit {}

    func dragChanged(
        translation: CGSize,
        velocity: CGSize,
        location: CGPoint
    ) {
        ensureFeedbackGenerators()
        if !isDragging {
            isDragging = true
            textureTracker.begin()
            textureGenerator?.prepare()
            releaseGenerator?.prepare()
            launchGenerator?.prepare()
        }

        guard
            let feedback = textureTracker.feedback(
                translation: translation,
                velocity: velocity
            )
        else {
            return
        }

        textureGenerator?.impactOccurred(
            intensity: feedback.intensity,
            at: resolvedLocation(location)
        )
        textureGenerator?.prepare()
    }

    func dragEnded(
        translation: CGSize,
        velocity: CGSize,
        location: CGPoint,
        completion: Completion
    ) {
        ensureFeedbackGenerators()
        let intensity = KaizoshaLogoDragPolicy.releaseFeedbackIntensity(
            translation: translation,
            velocity: velocity
        )
        let feedbackLocation = resolvedLocation(location)

        switch completion {
        case .cancelled:
            break
        case .returnedToAnchor:
            releaseGenerator?.impactOccurred(
                intensity: intensity,
                at: feedbackLocation
            )
        case .launchedIntoSingularity:
            launchGenerator?.impactOccurred(
                intensity: max(intensity, 0.88),
                at: feedbackLocation
            )
        }

        cancelDrag()
    }

    func cancelDrag() {
        isDragging = false
        textureTracker.reset()
    }

    func creditsOpened() {
        ensureFeedbackGenerators()
        launchGenerator?.impactOccurred(intensity: 0.85)
    }

    func invalidate() {
        cancelDrag()
        detachFeedbackGenerators()
    }

    private func ensureFeedbackGenerators() {
        guard let view = Self.foregroundWindow else {
            return
        }
        guard feedbackView !== view else {
            return
        }

        detachFeedbackGenerators()
        feedbackView = view
        textureGenerator = UIImpactFeedbackGenerator(
            style: .soft,
            view: view
        )
        releaseGenerator = UIImpactFeedbackGenerator(
            style: .medium,
            view: view
        )
        launchGenerator = UIImpactFeedbackGenerator(
            style: .heavy,
            view: view
        )
    }

    private func detachFeedbackGenerators() {
        if let textureGenerator {
            feedbackView?.removeInteraction(textureGenerator)
        }
        if let releaseGenerator {
            feedbackView?.removeInteraction(releaseGenerator)
        }
        if let launchGenerator {
            feedbackView?.removeInteraction(launchGenerator)
        }

        textureGenerator = nil
        releaseGenerator = nil
        launchGenerator = nil
        feedbackView = nil
    }

    private func resolvedLocation(_ location: CGPoint) -> CGPoint {
        guard let feedbackView else {
            return location
        }
        return CGPoint(
            x: min(max(location.x, feedbackView.bounds.minX), feedbackView.bounds.maxX),
            y: min(max(location.y, feedbackView.bounds.minY), feedbackView.bounds.maxY)
        )
    }

    private static var foregroundWindow: UIWindow? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap {
            $0 as? UIWindowScene
        }
        let foregroundScenes = windowScenes.filter {
            $0.activationState == .foregroundActive
        }
        return foregroundScenes.lazy
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? foregroundScenes.lazy.flatMap(\.windows).first
    }
}
