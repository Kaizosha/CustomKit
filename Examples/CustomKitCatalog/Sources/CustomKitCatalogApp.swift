import CustomKitCatalog
import SwiftUI

@main
struct CustomKitCatalogApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView(additionalEntries: [
                CatalogEntry(id: "playerkit", title: "Press play", source: "PlayerKit", category: .kits, summary: "Play a local Kaizōsha film with the real PlayerKit engine.") { PlayerKitExample() },
                CatalogEntry(id: "captionkit", title: "Words, in time", source: "CaptionKit", category: .kits, summary: "Read and seek a bilingual CaptionKit transcript.") { CaptionKitExample() },
                CatalogEntry(id: "sekaikit", title: "A smaller world", source: "Sekai", category: .kits, summary: "Explore the native Metal globe between Chicago and Tokyo.") { SekaiKitExample() }
            ])
        }
    }
}
