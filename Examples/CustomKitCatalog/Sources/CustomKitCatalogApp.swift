import CustomKitCatalog
import SwiftUI

@main
struct CustomKitCatalogApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView(additionalEntries: [
                CatalogEntry(id: "playerkit", title: "PlayerKit", source: "PlayerKit", category: .kits, summary: "Play a local Kaizōsha film with the real PlayerKit engine.") { PlayerKitExample() },
                CatalogEntry(id: "captionkit", title: "CaptionKit", source: "CaptionKit", category: .kits, summary: "Read and seek a bilingual CaptionKit transcript.") { CaptionKitExample() },
                CatalogEntry(id: "sekaikit", title: "SekaiKit", source: "Sekai", category: .kits, summary: "Explore the native Metal globe between Chicago and Tokyo.") { SekaiKitExample() }
            ])
        }
    }
}
