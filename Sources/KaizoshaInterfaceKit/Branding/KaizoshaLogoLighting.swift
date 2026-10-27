//
//  KaizoshaLogoLighting.swift
//  KaizoshaInterfaceKit
//

import CoreGraphics
import CoreMotion
import Observation
import UIKit

/// Converts the device's gravity vector into a bounded screen-space light.
/// The shader consumes the latest value directly, so there is no autonomous
/// sweep or time-driven caustic animation.
nonisolated enum KaizoshaLogoLightPolicy {
    static let fallbackDirection = CGVector(dx: -0.22, dy: -0.32)

    static func direction(
        gravityX: Double,
        gravityY: Double,
        interfaceOrientation: UIInterfaceOrientation
    ) -> CGVector {
        let screenGravity: CGVector
        switch interfaceOrientation {
        case .portraitUpsideDown:
            screenGravity = CGVector(dx: -gravityX, dy: gravityY)
        case .landscapeLeft:
            screenGravity = CGVector(dx: -gravityY, dy: -gravityX)
        case .landscapeRight:
            screenGravity = CGVector(dx: gravityY, dy: gravityX)
        case .portrait, .unknown:
            screenGravity = CGVector(dx: gravityX, dy: -gravityY)
        @unknown default:
            screenGravity = CGVector(dx: gravityX, dy: -gravityY)
        }

        // Treat gravity as a stable world reference and place the virtual light
        // on the raised side of the display.
        let rawDirection = CGVector(
            dx: -screenGravity.dx * 1.25,
            dy: -screenGravity.dy * 1.10
        )
        let magnitude = hypot(rawDirection.dx, rawDirection.dy)
        guard magnitude > 1 else {
            return rawDirection
        }

        return CGVector(
            dx: rawDirection.dx / magnitude,
            dy: rawDirection.dy / magnitude
        )
    }

    static func filteredDirection(
        current: CGVector,
        target: CGVector,
        response: CGFloat = 0.22
    ) -> CGVector {
        let boundedResponse = min(max(response, 0), 1)
        return CGVector(
            dx: current.dx + (target.dx - current.dx) * boundedResponse,
            dy: current.dy + (target.dy - current.dy) * boundedResponse
        )
    }
}

/// Narrow source boundary for lifecycle and failure verification without
/// exposing Core Motion framework state to the component.
@MainActor
protocol KaizoshaLogoMotionSource: AnyObject {
    var isAvailable: Bool { get }

    func start(
        onGravity: @escaping @MainActor (Double, Double) -> Void,
        onFailure: @escaping @MainActor () -> Void
    )
    func stop()
}

@MainActor
final class KaizoshaCoreMotionSource: KaizoshaLogoMotionSource {
    private let motionManager = CMMotionManager()

    deinit {}

    var isAvailable: Bool {
        motionManager.isDeviceMotionAvailable
    }

    func start(
        onGravity: @escaping @MainActor (Double, Double) -> Void,
        onFailure: @escaping @MainActor () -> Void
    ) {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            MainActor.assumeIsolated {
                guard error == nil, let gravity = motion?.gravity else {
                    onFailure()
                    return
                }
                onGravity(gravity.x, gravity.y)
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}

/// Owns ephemeral device-motion samples for one visible logo presentation.
/// Samples stay in memory, are never persisted, and stop with the presentation.
@MainActor
@Observable
final class KaizoshaLogoLightingState {
    private(set) var direction = KaizoshaLogoLightPolicy.fallbackDirection

    @ObservationIgnored private let motionSource: any KaizoshaLogoMotionSource
    @ObservationIgnored private(set) var isRunning = false

    deinit {}

    init(
        motionSource: any KaizoshaLogoMotionSource =
            KaizoshaCoreMotionSource()
    ) {
        self.motionSource = motionSource
    }

    func start() {
        guard !isRunning, motionSource.isAvailable else {
            return
        }

        isRunning = true
        motionSource.start { [weak self] gravityX, gravityY in
            self?.record(
                gravityX: gravityX,
                gravityY: gravityY
            )
        } onFailure: { [weak self] in
            self?.stop()
        }
    }

    func stop() {
        guard isRunning else {
            return
        }

        motionSource.stop()
        isRunning = false
    }

    private func record(gravityX: Double, gravityY: Double) {
        let target = KaizoshaLogoLightPolicy.direction(
            gravityX: gravityX,
            gravityY: gravityY,
            interfaceOrientation: activeInterfaceOrientation
        )
        let filtered = KaizoshaLogoLightPolicy.filteredDirection(
            current: direction,
            target: target
        )

        guard
            hypot(
                filtered.dx - direction.dx,
                filtered.dy - direction.dy
            ) > 0.0005
        else {
            return
        }
        direction = filtered
    }

    private var activeInterfaceOrientation: UIInterfaceOrientation {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .effectiveGeometry.interfaceOrientation ?? .portrait
    }
}
