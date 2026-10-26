import CustomKit
import SwiftUI

@MainActor
enum PresentationExamples {
    static var entries: [CatalogEntry] {
        [
            CatalogEntry(id: "haptic-sheet", title: "Haptic sheet", source: "Shared", category: .presentation, summary: "Native sheet presentation and detent feedback.") { HapticSheetExample() },
            CatalogEntry(id: "made-by", title: "Made by Kaizōsha", source: "Kaizōsha", category: .presentation, summary: "The shared credits sheet.") { CreditsExample() },
            CatalogEntry(id: "pull-clear", title: "Pull to clear", source: "skeleton", category: .presentation, summary: "Nothing or Clear on a downward pull.") { PullClearExample() }
        ]
    }
}

private struct HapticSheetExample: View {
    @State private var showsSheet = false
    @State private var haptics = true
    @State private var largeOnly = false
    @State private var translation = true
    @State private var language = "English"

    var body: some View {
        ExperimentPage(title: "Haptic sheet", api: ".hapticSheet(\n    isPresented: $showControls,\n    hapticsEnabled: true,\n    detents: [.medium, .large]\n) {\n    ReadingControls()\n}") {
            Button("Open sheet", systemImage: "rectangle.bottomhalf.inset.filled") { showsSheet = true }
                .buttonStyle(.glass)
                .controlSize(.large)
                .accessibilityIdentifier("sheet.open")
        } controls: {
            Section("Presentation") {
                Toggle("Haptic feedback", isOn: $haptics)
                Toggle("Start at full height", isOn: $largeOnly)
            }
            Section { Button("Reset", role: .destructive) { haptics = true; largeOnly = false; translation = true; language = "English" } }
        }
        .hapticSheet(isPresented: $showsSheet, hapticsEnabled: haptics, detents: largeOnly ? [.large] : [.medium, .large]) {
            NavigationStack {
                Form {
                    Toggle("Translate this page", isOn: $translation)
                    Picker("Reading language", selection: $language) {
                        ForEach(["English", "Japanese", "French", "Spanish"], id: \.self) { Text($0) }
                    }
                }
                .navigationTitle("Reading controls")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { showsSheet = false } } }
            }
        }
    }
}

private struct CreditsExample: View {
    @State private var appName = "Together"
    @State private var purpose = "Bring worlds together."
    @State private var details = "Designed and built by Kaizō Konpaku."
    @State private var showsLogo = true
    @State private var showsSheet = false

    var body: some View {
        ExperimentPage(title: "Made by Kaizōsha", api: "MadeByKaizosha(\n    appName: \"Together\",\n    purpose: \"Bring worlds together.\",\n    details: \"Designed and built by Kaizō Konpaku.\"\n)") {
            Button("Made by Kaizōsha", systemImage: "info.circle") { showsSheet = true }
                .buttonStyle(.glass)
                .controlSize(.large)
                .accessibilityIdentifier("credits.open")
        } controls: {
            Section("Credits") {
                TextField("App name", text: $appName)
                TextField("Purpose", text: $purpose, axis: .vertical)
                TextField("Details", text: $details, axis: .vertical)
                Toggle("Show Kaizōsha mark", isOn: $showsLogo)
            }
            Section { Button("Reset", role: .destructive) { appName = "Together"; purpose = "Bring worlds together."; details = "Designed and built by Kaizō Konpaku."; showsLogo = true } }
        }
        .hapticSheet(isPresented: $showsSheet, detents: [.large]) {
            MadeByKaizosha(appName: appName, purpose: purpose, details: details, showsLogo: showsLogo)
        }
    }
}

private struct PullClearExample: View {
    @State private var messages = Self.sample
    @State private var threshold = 140.0
    @State private var haptics = true
    private static let sample = ["Shall we take the long way home?", "Yes. There's still a little daylight.", "Then let's go by the river."]

    var body: some View {
        ExperimentPage(title: "Pull to clear", api: "PullToClear(\n    isEmpty: messages.isEmpty,\n    threshold: 140,\n    onClear: { messages.removeAll() }\n) {\n    ConversationRows(messages: messages)\n}") {
            PullToClear(isEmpty: messages.isEmpty, threshold: threshold, hapticsEnabled: haptics, onClear: { messages.removeAll() }) {
                VStack(alignment: .leading, spacing: 24) {
                    if messages.isEmpty {
                        Text("Nothing.")
                            .font(.system(.title, design: .serif))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 220)
                            .accessibilityIdentifier("pull.empty")
                    } else {
                        ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(index.isMultiple(of: 2) ? "YOU" : "THEM")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                Text(message).font(.system(.body, design: .serif))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("pull.conversation")
        } controls: {
            Section("Gesture") {
                ValueControl(title: "Clear threshold", value: $threshold, range: 80...190, suffix: " pt")
                Toggle("Haptic feedback", isOn: $haptics)
            }
            Section {
                Button("Try empty state") { messages = [] }
                Button("Restore conversation") { messages = Self.sample }
                Button("Reset", role: .destructive) { messages = Self.sample; threshold = 140; haptics = true }
            }
        }
    }
}
