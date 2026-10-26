import KaizoshaUIKit
import SwiftUI
import Testing

@MainActor
struct PublicAPITests {
    @Test func consumingAppCanConstructAndCustomizeTheLogo() {
        var configuration = LogoConfiguration()
        #expect(configuration.size == 160)
        #expect(configuration.interactive)
        #expect(configuration.hapticsEnabled)
        #expect(configuration.motionEnabled)
        configuration.size = 220
        configuration.motionEnabled = false
        configuration.lightDirection = CGVector(dx: 0.5, dy: -0.5)
        _ = KaizoshaLogo(configuration: configuration)
        _ = KaizoshaLogo(configuration: configuration, onOpenCredits: {})
    }
}
