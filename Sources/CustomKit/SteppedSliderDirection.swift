//
//  SteppedSliderDirection.swift
//  CustomKit
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import SwiftUI

/// The horizontal order used to present and adjust a ``SteppedSlider``.
public enum SteppedSliderDirection: Equatable, Sendable {
    /// The lowest stop appears on the left and the highest appears on the right.
    case leftToRight

    /// The lowest stop appears on the right and the highest appears on the left.
    case rightToLeft

    /// The order follows the host view's SwiftUI layout direction.
    case automatic
}

extension SteppedSliderDirection {
    func resolved(for layoutDirection: LayoutDirection) -> SteppedSliderResolvedDirection {
        switch self {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        case .automatic:
            return layoutDirection == .rightToLeft ? .rightToLeft : .leftToRight
        }
    }
}

enum SteppedSliderResolvedDirection: Equatable, Sendable {
    case leftToRight
    case rightToLeft
}
