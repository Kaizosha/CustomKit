import KaizoshaUIKit
import SwiftUI

struct CreditsExample: View {
    @State private var configuration = CreditsConfiguration.together
    @State private var showsCredits = false

    var body: some View {
        ComponentPage(title: "Made by Kaizosha", code: code, reset: { configuration = .together }) {
            Button("Made by Kaizōsha") { showsCredits = true }
                .buttonStyle(.glass)
                .accessibilityIdentifier("credits.open")
                .sheet(isPresented: $showsCredits) {
                    MadeByKaizosha(configuration: configuration)
                }
                .sensoryFeedback(.impact(weight: .light), trigger: showsCredits)
        } controls: {
            Section("Credits") {
                TextField("Title", text: $configuration.title)
                Toggle("Show logo", isOn: $configuration.showsLogo)
                ValueControl(title: "Logo size", value: $configuration.logoSize, range: 80...240, suffix: " pt")
            }
            Section("Paragraphs") {
                ForEach(configuration.paragraphs.indices, id: \.self) { index in
                    TextField("Paragraph \(index + 1)", text: $configuration.paragraphs[index], axis: .vertical)
                }
            }
        }
    }

    private let code = """
    import KaizoshaUIKit

    @State private var showsCredits = false

    Button("Made by Kaizōsha") { showsCredits = true }
        .sheet(isPresented: $showsCredits) {
            MadeByKaizosha()
        }

    MadeByKaizosha(configuration: CreditsConfiguration(
        title: "Made by Kaizōsha.",
        paragraphs: ["**Kaizōsha** designs and builds your app."],
        logoSize: 160
    ))
    """
}
