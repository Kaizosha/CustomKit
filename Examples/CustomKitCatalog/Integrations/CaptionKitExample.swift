import CustomKit
import CustomKitCatalog
import KaizoshaCaptionCore
import SwiftUI

struct CaptionKitExample: View {
    @State private var position = 0.0
    @State private var isPlaying = false
    @State private var mode = SubtitleDisplayMode.bilingual
    @State private var tint = Color.teal
    @Environment(\.scenePhase) private var scenePhase

    private let segments = [
        SubtitleSegment(text: "Bring worlds together.", translatedText: "世界をひとつに。", startTime: 0, endTime: 4, isFinal: true),
        SubtitleSegment(text: "Nothing gets lost in translation.", translatedText: "翻訳で失われるものはない。", startTime: 4, endTime: 8, isFinal: true),
        SubtitleSegment(text: "A little closer, in every language.", translatedText: "どの言葉でも、もう少し近くに。", startTime: 8, endTime: 12, isFinal: true),
        SubtitleSegment(text: "Made by Kaizōsha.", translatedText: "改造社がつくりました。", startTime: 12, endTime: 16, isFinal: true)
    ]

    var body: some View {
        ExperimentPage(
            title: "CaptionKit",
            api: """
            import KaizoshaCaptionCore
            import CustomKit

            CaptionTranscript(cues: cues, position: $position)
            """
        ) {
            ScrollView {
                CaptionTranscript(cues: cues, position: $position, showsTranslation: mode == .bilingual, activeTint: tint)
                    .padding(24)
            }
            .frame(maxWidth: 640)
        } controls: {
            Section("Playback") {
                PlaybackControls(isPlaying: $isPlaying, position: $position, duration: 16, skipInterval: 4, tint: tint)
            }
            Section("Captions") {
                Picker("Language display", selection: $mode) {
                    Text("Original").tag(SubtitleDisplayMode.original)
                    Text("Translated").tag(SubtitleDisplayMode.translated)
                    Text("Both").tag(SubtitleDisplayMode.bilingual)
                }
                .pickerStyle(.segmented)
                ColorPicker("Active caption", selection: $tint, supportsOpacity: false)
            }
            Section {
                Button("Reset captions", systemImage: "arrow.counterclockwise") {
                    isPlaying = false
                    position = 0
                    mode = .bilingual
                    tint = .teal
                }
            }
        }
        .task(id: isPlaying) {
            guard isPlaying else { return }
            if position >= 16 { position = 0 }
            while !Task.isCancelled && isPlaying {
                do { try await Task.sleep(for: .milliseconds(100)) }
                catch { return }
                guard !Task.isCancelled, isPlaying else { return }
                position = min(16, position + 0.1)
                if position >= 16 { isPlaying = false }
            }
        }
        .onChange(of: scenePhase) { _, value in
            if value != .active { isPlaying = false }
        }
        .onDisappear { isPlaying = false }
    }

    private var cues: [CaptionCue] {
        segments.enumerated().map { index, segment in
            let text = segment.displayTexts(for: mode)
            return CaptionCue(id: "\(index)", start: segment.startTime, end: segment.endTime,
                              text: text.primary, translation: text.secondary ?? "")
        }
    }
}
