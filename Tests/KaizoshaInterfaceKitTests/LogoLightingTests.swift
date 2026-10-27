//
//  LogoLightingTests.swift
//  KaizoshaInterfaceKitTests
//

import CoreGraphics
import Testing
import UIKit
@testable import KaizoshaInterfaceKit

struct KaizoshaLogoLightingTests {
    @Test func portraitGravityPlacesLightOnRaisedSideOfDisplay() {
        let direction = KaizoshaLogoLightPolicy.direction(
            gravityX: 0.4,
            gravityY: -0.6,
            interfaceOrientation: .portrait
        )

        #expect(direction.dx < 0)
        #expect(direction.dy < 0)
    }

    @Test func orientationMappingKeepsPhysicalTiltAlignedToScreen() {
        let portrait = KaizoshaLogoLightPolicy.direction(
            gravityX: 0.6,
            gravityY: 0,
            interfaceOrientation: .portrait
        )
        let landscape = KaizoshaLogoLightPolicy.direction(
            gravityX: 0,
            gravityY: -0.6,
            interfaceOrientation: .landscapeLeft
        )

        #expect(abs(portrait.dx - landscape.dx) < 0.001)
        #expect(abs(portrait.dy - landscape.dy) < 0.001)
    }

    @Test func extremeTiltRemainsInsideShaderInputBounds() {
        let direction = KaizoshaLogoLightPolicy.direction(
            gravityX: 4,
            gravityY: -3,
            interfaceOrientation: .portrait
        )

        #expect(hypot(direction.dx, direction.dy) <= 1.001)
    }

    @Test func filterMovesTowardSensorSampleWithoutOvershooting() {
        let current = CGVector(dx: -0.2, dy: -0.3)
        let target = CGVector(dx: 0.8, dy: 0.7)
        let filtered = KaizoshaLogoLightPolicy.filteredDirection(
            current: current,
            target: target
        )

        #expect(filtered.dx > current.dx)
        #expect(filtered.dx < target.dx)
        #expect(filtered.dy > current.dy)
        #expect(filtered.dy < target.dy)
    }

    @MainActor
    @Test func lightingStateStartsOnceAndStopsItsMotionSourceOnce() {
        let source = TestLogoMotionSource()
        let state = KaizoshaLogoLightingState(motionSource: source)

        state.start()
        state.start()

        #expect(state.isRunning)
        #expect(source.startCount == 1)

        source.send(gravityX: 0.5, gravityY: -0.4)
        #expect(state.direction != KaizoshaLogoLightPolicy.fallbackDirection)

        state.stop()
        state.stop()

        #expect(!state.isRunning)
        #expect(source.stopCount == 1)
    }

    @MainActor
    @Test func unavailableMotionSourceNeverStarts() {
        let source = TestLogoMotionSource(isAvailable: false)
        let state = KaizoshaLogoLightingState(motionSource: source)

        state.start()

        #expect(!state.isRunning)
        #expect(source.startCount == 0)
        #expect(source.stopCount == 0)
    }

    @MainActor
    @Test func motionFailureStopsTheActiveSource() {
        let source = TestLogoMotionSource()
        let state = KaizoshaLogoLightingState(motionSource: source)

        state.start()
        source.fail()

        #expect(!state.isRunning)
        #expect(source.stopCount == 1)
    }
}

@MainActor
private final class TestLogoMotionSource: KaizoshaLogoMotionSource {
    let isAvailable: Bool
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private var onGravity: (@MainActor (Double, Double) -> Void)?
    private var onFailure: (@MainActor () -> Void)?

    init(isAvailable: Bool = true) {
        self.isAvailable = isAvailable
    }

    func start(
        onGravity: @escaping @MainActor (Double, Double) -> Void,
        onFailure: @escaping @MainActor () -> Void
    ) {
        startCount += 1
        self.onGravity = onGravity
        self.onFailure = onFailure
    }

    func stop() {
        stopCount += 1
        onGravity = nil
        onFailure = nil
    }

    func send(gravityX: Double, gravityY: Double) {
        onGravity?(gravityX, gravityY)
    }

    func fail() {
        onFailure?()
    }
}
