//
//  SteppedSliderStyle.swift
//  CustomKit
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import CoreGraphics
import SwiftUI

/// The appearance and tactile feedback of a ``SteppedSlider``.
///
/// The default value is the original Kaizōsha design: a 44-point capsule that
/// expands to 52 points while dragging, centered six-point stops, and a white
/// circular knob.
public struct SteppedSliderStyle {
    /// The unfilled rail color.
    public var trackColor: Color

    /// The filled rail color.
    public var fillColor: Color

    /// The color of stops at or before the selected value.
    public var passedStopColor: Color

    /// The color of stops after the selected value.
    public var remainingStopColor: Color

    /// The selected-value knob color.
    public var knobColor: Color

    /// The selected-value knob shadow color.
    public var knobShadowColor: Color

    /// The control's preferred height.
    public var controlHeight: CGFloat

    /// The rail height when the control is idle.
    public var restingRailHeight: CGFloat

    /// The rail height during an active drag.
    public var activeRailHeight: CGFloat

    /// The knob diameter when the control is idle.
    public var restingKnobDiameter: CGFloat

    /// The knob diameter during an active drag.
    public var activeKnobDiameter: CGFloat

    /// The diameter of each stop marker.
    public var stopDiameter: CGFloat

    /// The knob shadow blur radius.
    public var knobShadowRadius: CGFloat

    /// The knob shadow offset.
    public var knobShadowOffset: CGSize

    /// The duration of the active-state geometry transition.
    public var animationDuration: TimeInterval

    /// Whether crossing a stop produces system selection feedback.
    public var hapticsEnabled: Bool

    /// Creates a stepped-slider appearance.
    public init(
        trackColor: Color = .white.opacity(0.28),
        fillColor: Color = .white,
        passedStopColor: Color = .black.opacity(0.45),
        remainingStopColor: Color = .white.opacity(0.72),
        knobColor: Color = .white,
        knobShadowColor: Color = .black.opacity(0.24),
        controlHeight: CGFloat = 56,
        restingRailHeight: CGFloat = 44,
        activeRailHeight: CGFloat = 52,
        restingKnobDiameter: CGFloat = 48,
        activeKnobDiameter: CGFloat = 60,
        stopDiameter: CGFloat = 6,
        knobShadowRadius: CGFloat = 3,
        knobShadowOffset: CGSize = CGSize(width: 0, height: 1),
        animationDuration: TimeInterval = 0.2,
        hapticsEnabled: Bool = true
    ) {
        self.trackColor = trackColor
        self.fillColor = fillColor
        self.passedStopColor = passedStopColor
        self.remainingStopColor = remainingStopColor
        self.knobColor = knobColor
        self.knobShadowColor = knobShadowColor
        self.controlHeight = controlHeight
        self.restingRailHeight = restingRailHeight
        self.activeRailHeight = activeRailHeight
        self.restingKnobDiameter = restingKnobDiameter
        self.activeKnobDiameter = activeKnobDiameter
        self.stopDiameter = stopDiameter
        self.knobShadowRadius = knobShadowRadius
        self.knobShadowOffset = knobShadowOffset
        self.animationDuration = animationDuration
        self.hapticsEnabled = hapticsEnabled
    }
}

struct ResolvedSteppedSliderStyle {
    let source: SteppedSliderStyle
    let controlHeight: CGFloat
    let restingRailHeight: CGFloat
    let activeRailHeight: CGFloat
    let restingKnobDiameter: CGFloat
    let activeKnobDiameter: CGFloat
    let stopDiameter: CGFloat
    let knobShadowRadius: CGFloat
    let knobShadowOffset: CGSize
    let animationDuration: TimeInterval

    init(_ source: SteppedSliderStyle) {
        self.source = source

        controlHeight = max(source.controlHeight.finiteOrZero, 44)
        restingRailHeight = min(
            max(source.restingRailHeight.finiteOrZero, 1),
            controlHeight
        )
        activeRailHeight = min(
            max(source.activeRailHeight.finiteOrZero, 1),
            controlHeight
        )
        restingKnobDiameter = max(source.restingKnobDiameter.finiteOrZero, 1)
        activeKnobDiameter = max(source.activeKnobDiameter.finiteOrZero, 1)
        stopDiameter = max(source.stopDiameter.finiteOrZero, 1)
        knobShadowRadius = max(source.knobShadowRadius.finiteOrZero, 0)
        knobShadowOffset = CGSize(
            width: source.knobShadowOffset.width.finiteOrZero,
            height: source.knobShadowOffset.height.finiteOrZero
        )
        animationDuration = max(source.animationDuration.finiteOrZero, 0)
    }
}

private extension BinaryFloatingPoint {
    var finiteOrZero: Self {
        isFinite ? self : 0
    }
}
