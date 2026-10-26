import SwiftUI

public enum CatalogCategory: String, CaseIterable, Identifiable {
    case identity = "Identity"
    case controls = "Controls"
    case presentation = "Presentation"
    case kits = "Kits"

    public var id: Self { self }
}

@MainActor
public struct CatalogEntry: Identifiable {
    public let id: String
    public let title: String
    public let source: String
    public let category: CatalogCategory
    public let summary: String
    let destination: () -> AnyView

    public init<Destination: View>(
        id: String,
        title: String,
        source: String,
        category: CatalogCategory,
        summary: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.id = id
        self.title = title
        self.source = source
        self.category = category
        self.summary = summary
        self.destination = { AnyView(destination()) }
    }
}
