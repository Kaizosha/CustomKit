import CustomKit
import SwiftUI

public struct CatalogView: View {
    private let entries: [CatalogEntry]
    @State private var search = ""
    @State private var showsCredits = false

    public init(additionalEntries: [CatalogEntry] = []) {
        entries = IdentityExamples.entries + ControlExamples.entries
            + PresentationExamples.entries + additionalEntries
        precondition(Set(entries.map(\.id)).count == entries.count, "Catalog entry IDs must be unique.")
    }

    private var filteredEntries: [CatalogEntry] {
        entries.filter {
            search.isEmpty || "\($0.title) \($0.source) \($0.summary)".localizedCaseInsensitiveContains(search)
        }
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    introduction
                    ForEach(CatalogCategory.allCases) { category in
                        let group = filteredEntries.filter { $0.category == category }
                        if !group.isEmpty {
                            Text(category.rawValue)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundStyle(.tertiary)
                                .padding(.top, 34)
                                .padding(.bottom, 12)
                            Divider()
                            ForEach(group) { entry in
                                NavigationLink {
                                    entry.destination()
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(entry.title)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                        Spacer(minLength: 4)
                                        Text(entry.source)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundStyle(.tertiary)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    .padding(.vertical, 21)
                                    .frame(minHeight: 64)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("catalog.\(entry.id)")
                                .accessibilityHint(entry.summary)
                                Divider()
                            }
                        }
                    }
                    if filteredEntries.isEmpty {
                        ContentUnavailableView.search(text: search)
                            .padding(.top, 48)
                    }
                    footer
                }
                .padding(.horizontal, 26)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
            .navigationTitle("CustomKit")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Find a template")
            .hapticSheet(isPresented: $showsCredits) {
                MadeByKaizosha(
                    appName: "CustomKit",
                    purpose: "A collection of the details that make our apps feel like ours. Built to play with, made to use again.",
                    details: "Components and working examples from Together, TL;Pinch, skeleton, and the Kaizōsha kits."
                )
            }
        }
        .tint(.teal)
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Kaizōsha")
                .font(.system(.title2, design: .serif))
            Text("Reusable elements from our apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 36)
        .padding(.bottom, 12)
        .accessibilityElement(children: .combine)
    }

    private var footer: some View {
        Button {
            showsCredits = true
        } label: {
            VStack(spacing: 13) {
                Text("改 造 社")
                    .font(.system(.title3, design: .serif))
                Text("Made by Kaizōsha.")
                    .font(.system(.caption, design: .monospaced))
            }
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, 56)
            .padding(.bottom, 38)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("catalog.credits")
    }
}
