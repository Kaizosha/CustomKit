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
@Test("CustomKit and SwiftUI sliders coexist with common bindings")
func publicFloatingPointAPI() {
    let style = CustomKit.SliderStyle(
        trackColor: .secondary.opacity(0.24),
        fillColor: .mint,
        knobColor: .mint,
        restingRailHeight: 36,
        activeRailHeight: 44,
        hapticsEnabled: false
    )

    let customSlider: CustomKit.Slider<Float> = CustomKit.Slider(
        value: Binding.constant(Float(1)),
        stops: [Float(0.5), 1, 1.25, 1.5, 2],
        style: style,
        direction: CustomKit.SliderDirection.automatic,
        accessibilityLabel: "Playback speed",
        accessibilityValue: { "\($0.formatted())×" }
    )
    _ = customSlider

    _ = CustomKit.Slider(
        value: Binding.constant(Double(0.5)),
        stops: [Double(0), 0.5, 1]
    )

    _ = SwiftUI.Slider(
        value: Binding.constant(Double(0.5)),
        in: 0...1
    )

    #expect(!style.hapticsEnabled)
}
