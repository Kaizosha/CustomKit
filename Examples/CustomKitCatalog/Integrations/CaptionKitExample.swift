import CustomKit
import CustomKitCatalog
import KaizoshaCaptionCore
import SwiftUI

struct CaptionKitExample: View {
    @State private var position = 0.0
    @State private var isPlaying = false
    @State private var mode = SubtitleDisplayMode.bilingual
    @State private var fontSize = 22.0
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
            subtitle: "Tap a line to seek through a bilingual Kaizōsha transcript.",
            source: "Together · KaizoshaCaptionKit",
            api: """
            import KaizoshaCaptionCore
            import CustomKit

            let text = segment.displayTexts(for: .bilingual)
            CaptionOverlay(text: text.primary, translation: text.secondary)
            CaptionTranscript(cues: cues, position: $position)
            """
        ) {
            VStack(spacing: 24) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.black)
                    VStack(spacing: 22) {
                        Text("改造社")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.25))
                        if let segment = activeSegment {
                            let text = segment.displayTexts(for: mode)
                            CaptionOverlay(text: text.primary, translation: text.secondary, fontSize: fontSize)
                                .padding(.horizontal, 12)
                        }
                    }
                    .padding(.vertical, 28)
                }
                .frame(minHeight: 230)
                PlaybackControls(isPlaying: $isPlaying, position: $position, duration: 16, skipInterval: 4, tint: tint)
                CaptionTranscript(cues: cues, position: $position, showsTranslation: mode == .bilingual, activeTint: tint)
                Text("A local timed transcript. No microphone access is needed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        } controls: {
            Section("Captions") {
                Picker("Language display", selection: $mode) {
                    Text("Original").tag(SubtitleDisplayMode.original)
                    Text("Translated").tag(SubtitleDisplayMode.translated)
                    Text("Both").tag(SubtitleDisplayMode.bilingual)
                }
                .pickerStyle(.segmented)
                LabeledContent("Caption size", value: "\(Int(fontSize)) pt")
                SwiftUI.Slider(value: $fontSize, in: 16...34, step: 1)
                    .accessibilityLabel("Caption size")
                ColorPicker("Active caption", selection: $tint, supportsOpacity: false)
            }
            Section {
                Button("Reset captions", systemImage: "arrow.counterclockwise") {
                    isPlaying = false
                    position = 0
                    mode = .bilingual
                    fontSize = 22
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

    private var activeSegment: SubtitleSegment? {
        segments.first { position >= $0.startTime && position < $0.endTime }
    }

    private var cues: [CaptionCue] {
        segments.enumerated().map { index, segment in
            let text = segment.displayTexts(for: mode)
            return CaptionCue(id: "\(index)", start: segment.startTime, end: segment.endTime,
                              text: text.primary, translation: text.secondary ?? "")
        }
    }
}
