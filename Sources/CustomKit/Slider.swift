//
//  Slider.swift
//  CustomKit
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import Foundation
import SwiftUI

/// A tactile, drag-only slider for selecting one of several discrete values.
///
/// Stops are filtered to finite values, de-duplicated, sorted, and presented
/// with equal spacing. The binding may use `Float`, `Double`, `CGFloat`, or
/// another `BinaryFloatingPoint` type.
@MainActor
public struct Slider<Value: BinaryFloatingPoint>: View {
    @Binding private var value: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection

    private let stops: [Value]
    private let style: SliderStyle
    private let direction: SliderDirection
    private let accessibilityLabel: String
    private let accessibilityValue: (Value) -> String
    private let onEditingChanged: (Bool) -> Void

    /// Creates a slider.
    ///
    /// - Parameters:
    ///   - value: The selected value. User adjustments write a normalized stop.
    ///   - stops: The available values. Invalid values and duplicates are
    ///     discarded, and the remaining values are sorted and equally spaced.
    ///   - style: Visual geometry, colors, animation, and haptic feedback.
    ///   - direction: Horizontal value order. The Kaizōsha design keeps lower
    ///     values on the left by default.
    ///   - accessibilityLabel: A localized name for the adjusted setting.
    ///   - accessibilityValue: A localized description of a selected value.
    ///   - onEditingChanged: Called once when dragging begins and once when it
    ///     ends or is cancelled. Accessibility adjustments use the same
    ///     balanced lifecycle.
    public init(
        value: Binding<Value>,
        stops: [Value],
        style: SliderStyle = .init(),
        direction: SliderDirection = .leftToRight,
        accessibilityLabel: String = String(localized: "Slider"),
        accessibilityValue: @escaping (Value) -> String = {
            Double($0).formatted(
                .number.precision(.fractionLength(0...3))
            )
        },
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        _value = value
        self.stops = stops
        self.style = style
        self.direction = direction
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.onEditingChanged = onEditingChanged
    }

    public var body: some View {
        let doubleStops = SliderMath.normalizedStops(
            stops.map { Double($0) },
            fallback: Double(value)
        )

        SliderRepresentable(
            value: Binding(
                get: { Double(value) },
                set: { value = Value($0) }
            ),
            stops: doubleStops,
            style: style,
            direction: direction.resolved(for: layoutDirection),
            isEnabled: isEnabled,
            reduceMotion: reduceMotion,
            accessibilityLabel: accessibilityLabel,
            accessibilityValue: { accessibilityValue(Value($0)) },
            onEditingChanged: onEditingChanged
        )
    }
}
