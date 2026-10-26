import SwiftUI

@main
struct KaizoshaUIKitApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink {
                        LogoExample()
                    } label: {
                        Text("Kaizosha Logo")
                    }
                    .accessibilityIdentifier("catalog.kaizosha-logo")
                }
                .listStyle(.plain)
                .navigationTitle("KaizoshaUIKit")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tint(.primary)
        }
    }
}
