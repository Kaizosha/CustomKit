import SwiftUI

public struct LogoConfiguration {
    public var size: CGFloat
    public var interactive: Bool
    public var hapticsEnabled: Bool
    public var motionEnabled: Bool
    public var refraction: CGFloat
    public var lightDirection: CGVector

    public init(
        size: CGFloat = 160,
        interactive: Bool = true,
        hapticsEnabled: Bool = true,
        motionEnabled: Bool = true,
        refraction: CGFloat = 1,
        lightDirection: CGVector = CGVector(dx: -0.22, dy: -0.32)
    ) {
        self.size = size
        self.interactive = interactive
        self.hapticsEnabled = hapticsEnabled
        self.motionEnabled = motionEnabled
        self.refraction = refraction
        self.lightDirection = lightDirection
    }
}
