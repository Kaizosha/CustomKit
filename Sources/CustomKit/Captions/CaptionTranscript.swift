import SwiftUI

public struct CaptionTranscript: View {
    private let cues: [CaptionCue]
    @Binding private var position: Double
    private let showsTranslation: Bool
    private let activeTint: Color
    private let onSeek: ((Double) -> Void)?

    public init(
        cues: [CaptionCue],
        position: Binding<Double>,
        showsTranslation: Bool = true,
        activeTint: Color = .teal,
        onSeek: ((Double) -> Void)? = nil
    ) {
        self.cues = cues
        _position = position
        self.showsTranslation = showsTranslation
        self.activeTint = activeTint
        self.onSeek = onSeek
    }

    public var body: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(cues) { cue in
                Button {
                    position = cue.start
                    onSeek?(cue.start)
                } label: {
                    HStack(alignment: .top, spacing: 16) {
                        Text(timestamp(cue.start))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .padding(.top, 3)
                        VStack(alignment: .leading, spacing: 7) {
                            Text(cue.text)
                                .foregroundStyle(.primary)
                            if showsTranslation && !cue.translation.isEmpty {
                                Text(cue.translation)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer(minLength: 0)
                        if cue.contains(position) {
                            Image(systemName: "waveform")
                                .foregroundStyle(activeTint)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(cue.contains(position) ? activeTint.opacity(0.12) : Color.clear,
                                in: .rect(cornerRadius: 18))
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(timestamp(cue.start)), \(cue.text)")
                .accessibilityHint("Seek to this caption")
                .accessibilityAddTraits(cue.contains(position) ? [.isSelected] : [])
            }
        }
    }

    private func timestamp(_ value: Double) -> String {
        let seconds = Int(min(max(0, value.isFinite ? value : 0), Double(Int32.max)))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
