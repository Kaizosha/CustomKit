//
//  PublicAPITests.swift
//  CustomKitTests
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import CustomKit
import SwiftUI
import Testing

@MainActor
@Test("The public API accepts common floating-point bindings")
func publicFloatingPointAPI() {
    let style = SteppedSliderStyle(
        trackColor: .secondary.opacity(0.24),
        fillColor: .mint,
        knobColor: .mint,
        restingRailHeight: 36,
        activeRailHeight: 44,
        hapticsEnabled: false
    )

    _ = SteppedSlider(
        value: Binding.constant(Float(1)),
        stops: [Float(0.5), 1, 1.25, 1.5, 2],
        style: style,
        direction: .automatic,
        accessibilityLabel: "Playback speed",
        accessibilityValue: { "\($0.formatted())×" }
    )

    #expect(!style.hapticsEnabled)
}
