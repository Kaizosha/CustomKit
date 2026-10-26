import SwiftUI

public struct MadeByKaizosha: View {
    public var appName: String
    public var purpose: String
    public var details: String
    public var showsLogo: Bool
    @Environment(\.dismiss) private var dismiss

    public init(
        appName: String,
        purpose: String,
        details: String = "Built with native Apple frameworks.",
        showsLogo: Bool = true
    ) {
        self.appName = appName
        self.purpose = purpose
        self.details = details
        self.showsLogo = showsLogo
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if showsLogo {
                        KaizoshaLogo(configuration: .init(interactive: false))
                            .padding(.vertical, 12)
                    }
                    Text("Made by Kaizōsha.")
                        .font(.largeTitle)
                        .fontDesign(.serif)
                        .multilineTextAlignment(.center)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Kaizōsha designs and builds \(appName). \(purpose)")
                        Text(details)
                    }
                    .font(.body.monospaced())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 520, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollEdgeEffectStyle(.soft, for: [.top, .bottom])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
                    .accessibilityLabel("Close credits")
                }
            }
        }
    }
}
