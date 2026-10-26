import CustomKit
import SwiftUI

@MainActor
enum PresentationExamples {
    static var entries: [CatalogEntry] {
        [
            CatalogEntry(id: "haptic-sheet", title: "A sheet you can feel", source: "Shared", category: .presentation, summary: "Open a native settings sheet with presentation and detent feedback.") { HapticSheetExample() },
            CatalogEntry(id: "made-by", title: "Made by Kaizōsha.", source: "Kaizōsha", category: .presentation, summary: "Adapt the shared credits sheet to your app.") { CreditsExample() },
            CatalogEntry(id: "pull-clear", title: "Nothing. Or a clean slate.", source: "skeleton", category: .presentation, summary: "Pull down to reveal Nothing or release past the threshold to clear the sample conversation.") { PullClearExample() }
        ]
    }
}

private struct HapticSheetExample: View {
    @State private var showsSheet = false
    @State private var haptics = true
    @State private var largeOnly = false
    @State private var translation = true
    @State private var language = "English"
    @State private var presentations = 0

    var body: some View {
        ExperimentPage(title: "A sheet you can feel", subtitle: "The system owns the movement. A light tap marks presentation, and a selection tick follows each detent change.", source: "Shared / Native presentation", api: ".hapticSheet(\n    isPresented: $showControls,\n    hapticsEnabled: true,\n    detents: [.medium, .large]\n) {\n    ReadingControls()\n}") {
            VStack(spacing: 28) {
                Image(systemName: "rectangle.bottomhalf.inset.filled")
                    .font(.system(size: 54, weight: .ultraLight))
                    .foregroundStyle(.teal)
                Text("A place for the details.")
                    .font(.system(.title2, design: .serif))
                Text("Read in \(language). \(translation ? "Translation is on." : "Original text only.")")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Open reading controls", systemImage: "slider.horizontal.3") {
                    presentations += 1
                    showsSheet = true
                }
                .customKitButton(.primary)
                .accessibilityIdentifier("sheet.open")
                Text("Opened \(presentations) \(presentations == 1 ? "time" : "times")")
                    .font(.caption).foregroundStyle(.tertiary)
            }
        } controls: {
            Section("Presentation") {
                Toggle("Haptic feedback", isOn: $haptics)
                Toggle("Start at full height", isOn: $largeOnly)
                Text("Feel vibration on a physical iPhone. The simulator shows the native sheet movement.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section { Button("Reset", role: .destructive) { haptics = true; largeOnly = false; translation = true; language = "English"; presentations = 0 } }
        }
        .hapticSheet(isPresented: $showsSheet, hapticsEnabled: haptics, detents: largeOnly ? [.large] : [.medium, .large]) {
            NavigationStack {
                Form {
                    Section("Read your way") {
                        Toggle("Translate this page", isOn: $translation)
                        Picker("Reading language", selection: $language) {
                            ForEach(["English", "Japanese", "French", "Spanish"], id: \.self) { Text($0) }
                        }
                    }
                    Section { Text("Drag the top edge to change height. These settings update the example behind this sheet.") }
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
    @State private var purpose = "Bring worlds together. Watch in your language, keep the moments you love, and never lose the meaning."
    @State private var details = "Designed and built by Kaizō Konpaku. Native Apple frameworks, thoughtful details, and room for a little play."
    @State private var showsLogo = true
    @State private var showsSheet = false

    var body: some View {
        ExperimentPage(title: "Made by Kaizōsha.", subtitle: "A familiar signature, with room for your app's own story. Open the full sheet to see how it reads.", source: "Kaizōsha / Credits", api: "MadeByKaizosha(\n    appName: \"Together\",\n    purpose: \"Bring worlds together.\",\n    details: \"Designed and built by Kaizō Konpaku.\"\n)") {
            VStack(spacing: 24) {
                if showsLogo { KaizoshaLogo(configuration: .init(size: 110, interactive: false)) }
                Text("Made by Kaizōsha.").font(.system(.title, design: .serif)).multilineTextAlignment(.center)
                Text(appName).font(.system(.subheadline, design: .monospaced)).foregroundStyle(.secondary)
                Button("Read our story", systemImage: "text.alignleft") { showsSheet = true }
                    .customKitButton(.neutral)
                    .accessibilityIdentifier("credits.open")
            }
        } controls: {
            Section("Your story") {
                TextField("App name", text: $appName)
                TextField("Purpose", text: $purpose, axis: .vertical)
                TextField("Details", text: $details, axis: .vertical)
                Toggle("Show Kaizōsha mark", isOn: $showsLogo)
            }
            Section { Button("Reset", role: .destructive) { appName = "Together"; purpose = "Bring worlds together. Watch in your language, keep the moments you love, and never lose the meaning."; details = "Designed and built by Kaizō Konpaku. Native Apple frameworks, thoughtful details, and room for a little play."; showsLogo = true } }
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
    @State private var clears = 0
    private static let sample = ["Shall we take the long way home?", "Yes. There's still a little daylight.", "Then let's go by the river."]

    var body: some View {
        ExperimentPage(title: "Nothing. Or a clean slate.", subtitle: "Pull the conversation down. A short pull changes nothing. Go a little further, then release to clear these sample messages.", source: "skeleton / Pull to clear", api: "PullToClear(\n    isEmpty: messages.isEmpty,\n    threshold: 140,\n    onClear: { messages.removeAll() }\n) {\n    ConversationRows(messages: messages)\n}") {
            VStack(spacing: 16) {
                PullToClear(isEmpty: messages.isEmpty, threshold: threshold, hapticsEnabled: haptics, onClear: { messages.removeAll(); clears += 1 }) {
                    VStack(alignment: .leading, spacing: 18) {
                        if messages.isEmpty {
                            ContentUnavailableView("Nothing here.", systemImage: "bubble.left", description: Text("A clean slate for the next conversation."))
                        } else {
                            ForEach(Array(messages.enumerated()), id: \.offset) { index, message in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(index.isMultiple(of: 2) ? "YOU" : "THEM").font(.system(.caption2, design: .monospaced)).foregroundStyle(.teal)
                                    Text(message).font(.system(.body, design: .serif))
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.quaternary.opacity(0.5), in: .rect(cornerRadius: 18))
                            }
                        }
                    }
                }
                .frame(height: 340)
                .accessibilityIdentifier("pull.conversation")
                HStack {
                    Text("\(messages.count) messages · \(clears) clears")
                        .font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                        .accessibilityIdentifier("pull.status")
                    Spacer()
                    Button("Restore", systemImage: "arrow.counterclockwise") { messages = Self.sample }
                        .customKitButton(.reset)
                        .disabled(!messages.isEmpty)
                }
            }
        } controls: {
            Section("Pull gesture") {
                ValueControl(title: "Clear threshold", value: $threshold, range: 80...190, suffix: " pt")
                Toggle("Haptic feedback", isOn: $haptics)
                Button("Try the empty state") { messages = [] }
                Button("Restore sample conversation") { messages = Self.sample }
            }
            Section { Button("Reset", role: .destructive) { messages = Self.sample; threshold = 140; haptics = true; clears = 0 } }
        }
    }
}
