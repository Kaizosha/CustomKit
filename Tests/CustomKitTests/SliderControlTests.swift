//
//  SliderControlTests.swift
//  CustomKitTests
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import SwiftUI
import Testing
import UIKit

@testable import CustomKit

@MainActor
@Suite("Slider control")
struct SliderControlTests {
    @Test("Default style preserves the Kaizōsha geometry")
    func defaultStyleGeometry() {
        let style = ResolvedSliderStyle(.init())

        #expect(style.controlHeight == 56)
        #expect(style.restingRailHeight == 44)
        #expect(style.activeRailHeight == 52)
        #expect(style.restingKnobDiameter == 48)
        #expect(style.activeKnobDiameter == 60)
        #expect(style.stopDiameter == 6)
        #expect(style.knobShadowRadius == 3)
        #expect(style.knobShadowOffset == CGSize(width: 0, height: 1))
        #expect(style.animationDuration == 0.2)
    }

    @Test("Unsafe custom geometry is normalized")
    func normalizesCustomStyleGeometry() {
        let style = ResolvedSliderStyle(
            .init(
                controlHeight: 20,
                restingRailHeight: -3,
                activeRailHeight: CGFloat.infinity,
                restingKnobDiameter: CGFloat.nan,
                activeKnobDiameter: -2,
                stopDiameter: 0,
                knobShadowRadius: -4,
                knobShadowOffset: CGSize(
                    width: CGFloat.nan,
                    height: CGFloat.infinity
                ),
                animationDuration: -Double.infinity,
                hapticsEnabled: false
            )
        )

        #expect(style.controlHeight == 44)
        #expect(style.restingRailHeight == 1)
        #expect(style.activeRailHeight == 1)
        #expect(style.restingKnobDiameter == 1)
        #expect(style.activeKnobDiameter == 1)
        #expect(style.stopDiameter == 1)
        #expect(style.knobShadowRadius == 0)
        #expect(style.knobShadowOffset == .zero)
        #expect(style.animationDuration == 0)
    }

    @Test("Value assignment snaps to the nearest stop")
    func snapsAssignedValue() {
        let control = makeControl()

        control.value = 1.4
        #expect(control.value == 1.5)

        control.value = 1.375
        #expect(control.value == 1.25)

        control.value = 99
        #expect(control.value == 2)
    }

    @Test("Accessibility content is caller-owned")
    func configuresAccessibilityContent() {
        let control = makeControl()
        control.value = 1.5

        #expect(control.accessibilityLabel == "Playback speed")
        #expect(control.accessibilityValue == "1.5×")
        #expect(control.accessibilityTraits.contains(.adjustable))
        #expect(!control.accessibilityTraits.contains(.notEnabled))
    }

    @Test("Accessibility increments emit one balanced edit")
    func incrementsAccessibly() {
        let control = makeControl()
        let recorder = ControlEventRecorder(control: control)
        control.value = 1

        control.accessibilityIncrement()

        #expect(control.value == 1.25)
        #expect(control.accessibilityValue == "1.25×")
        #expect(recorder.events == [.began, .changed, .ended])
    }

    @Test("Accessibility decrements emit one balanced edit")
    func decrementsAccessibly() {
        let control = makeControl()
        let recorder = ControlEventRecorder(control: control)
        control.value = 1.25

        control.accessibilityDecrement()

        #expect(control.value == 1)
        #expect(recorder.events == [.began, .changed, .ended])
    }

    @Test("Accessibility endpoints do not report false changes")
    func ignoresAccessibilityEndpoints() {
        let control = makeControl()
        let recorder = ControlEventRecorder(control: control)
        control.value = 2

        control.accessibilityIncrement()

        #expect(control.value == 2)
        #expect(recorder.events.isEmpty)
    }

    @Test("A disabled control is inert and announced as disabled")
    func disablesAccessibilityAdjustment() {
        let control = makeControl(isEnabled: false)
        let recorder = ControlEventRecorder(control: control)
        control.value = 1

        control.accessibilityIncrement()

        #expect(control.value == 1)
        #expect(control.accessibilityTraits.contains(.notEnabled))
        #expect(recorder.events.isEmpty)
    }

    @Test("Resting views use configured geometry")
    func laysOutCustomGeometry() throws {
        let style = SliderStyle(
            controlHeight: 64,
            restingRailHeight: 36,
            activeRailHeight: 44,
            restingKnobDiameter: 30,
            activeKnobDiameter: 38,
            stopDiameter: 4,
            hapticsEnabled: false
        )
        let control = makeControl(style: style)
        control.frame = CGRect(x: 0, y: 0, width: 280, height: 64)
        control.value = 1.25
        control.layoutIfNeeded()

        let track = try #require(control.subviews.first)
        let knob = try #require(control.subviews.last)

        #expect(track.frame == CGRect(x: 0, y: 14, width: 280, height: 36))
        #expect(knob.frame == CGRect(x: 125, y: 17, width: 30, height: 30))
    }

    @Test("A one-stop control centers its knob in either direction")
    func centersOneStop() throws {
        let leftToRight = makeControl(
            stops: [1],
            direction: .leftToRight
        )
        leftToRight.frame = CGRect(x: 0, y: 0, width: 280, height: 56)
        leftToRight.layoutIfNeeded()

        let rightToLeft = makeControl(
            stops: [1],
            direction: .rightToLeft
        )
        rightToLeft.frame = CGRect(x: 0, y: 0, width: 280, height: 56)
        rightToLeft.layoutIfNeeded()

        let leftKnob = try #require(leftToRight.subviews.last)
        let rightKnob = try #require(rightToLeft.subviews.last)
        #expect(leftKnob.frame.midX == 140)
        #expect(rightKnob.frame.midX == 140)
        #expect(!leftToRight.accessibilityTraits.contains(.adjustable))
        #expect(leftToRight.accessibilityTraits.contains(.staticText))
    }

    @Test("Right-to-left geometry mirrors the selected stop")
    func mirrorsControlLayout() throws {
        let leftToRight = makeControl(direction: .leftToRight)
        leftToRight.frame = CGRect(x: 0, y: 0, width: 280, height: 56)
        leftToRight.value = 0.5
        leftToRight.layoutIfNeeded()

        let rightToLeft = makeControl(direction: .rightToLeft)
        rightToLeft.frame = CGRect(x: 0, y: 0, width: 280, height: 56)
        rightToLeft.value = 0.5
        rightToLeft.layoutIfNeeded()

        let leftKnob = try #require(leftToRight.subviews.last)
        let rightKnob = try #require(rightToLeft.subviews.last)
        #expect(leftKnob.frame.midX == 22)
        #expect(rightKnob.frame.midX == 258)
    }

    private func makeControl(
        stops: [Double] = [0.5, 1, 1.25, 1.5, 2],
        style: SliderStyle = .init(hapticsEnabled: false),
        direction: SliderResolvedDirection = .leftToRight,
        isEnabled: Bool = true
    ) -> SliderControl {
        let control = SliderControl()
        control.configure(
            stops: stops,
            style: style,
            direction: direction,
            isEnabled: isEnabled,
            reduceMotion: true,
            accessibilityLabel: "Playback speed",
            accessibilityValue: { "\($0.formatted())×" }
        )
        return control
    }
}

@MainActor
private final class ControlEventRecorder {
    enum Event: Equatable {
        case began
        case changed
        case ended
    }

    private(set) var events: [Event] = []

    init(control: SliderControl) {
        control.eventObserver = { [weak self] event in
            guard let self else {
                return
            }

            if event == .editingDidBegin {
                events.append(.began)
            } else if event == .valueChanged {
                events.append(.changed)
            } else if event == .editingDidEnd || event == .editingDidEndOnExit {
                events.append(.ended)
            }
        }
    }
}
