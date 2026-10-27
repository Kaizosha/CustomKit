import KaizoshaInterfaceKit
import SwiftUI

struct LogoExample: View {
    @State private var configuration = LogoConfiguration()

    var body: some View {
        ComponentPage(title: "Kaizosha Logo", code: code, reset: { configuration = .init() }) {
            KaizoshaLogo(configuration: configuration)
                .accessibilityIdentifier("logo.element")
        } controls: {
            Section("Logo") {
                ValueControl(title: "Size", value: $configuration.size, range: 80...280, suffix: " pt")
                ValueControl(title: "Refraction", value: $configuration.refraction, range: 0...2)
                Toggle("Interactive", isOn: $configuration.interactive)
                Toggle("Haptics", isOn: $configuration.hapticsEnabled)
                Toggle("Follow device tilt", isOn: $configuration.motionEnabled)
            }
            Section("Light direction") {
                ValueControl(title: "Horizontal", value: $configuration.lightDirection.dx, range: -1...1)
                ValueControl(title: "Vertical", value: $configuration.lightDirection.dy, range: -1...1)
            }
            .disabled(configuration.motionEnabled)
        }
    }

    private let code = """
    import KaizoshaInterfaceKit

    KaizoshaLogo()

    KaizoshaLogo(configuration: LogoConfiguration(
        size: 200,
        interactive: true,
        hapticsEnabled: true,
        motionEnabled: true,
        refraction: 1
    ))
    """

}
