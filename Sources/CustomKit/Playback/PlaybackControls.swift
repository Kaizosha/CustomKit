import SwiftUI

public struct PlaybackControls: View {
    @Binding private var isPlaying: Bool
    @Binding private var position: Double
    private let duration: Double
    private let skipInterval: Double
    private let tint: Color

    public init(
        isPlaying: Binding<Bool>,
        position: Binding<Double>,
        duration: Double,
        skipInterval: Double = 10,
        tint: Color = .teal
    ) {
        _isPlaying = isPlaying
        _position = position
        self.duration = duration.isFinite ? max(0, duration) : 0
        self.skipInterval = skipInterval.isFinite ? max(1, skipInterval) : 10
        self.tint = tint
    }

    public var body: some View {
        VStack(spacing: 16) {
            SwiftUI.Slider(value: boundedPosition, in: 0...max(duration, 0.001))
                .tint(tint)
                .disabled(duration == 0)
                .accessibilityLabel("Playback position")
                .accessibilityValue("\(time(position)) of \(time(duration))")
            HStack {
                Text(time(position))
                Spacer()
                Text(time(duration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
            GlassEffectContainer {
                HStack(spacing: 24) {
                    Button { seek(by: -skipInterval) } label: {
                        Image(systemName: "gobackward")
                            .frame(width: 48, height: 48)
                    }
                    .accessibilityLabel("Back \(skipInterval.formatted(.number.precision(.fractionLength(0)))) seconds")
                    .disabled(position <= 0)
                    Button { isPlaying.toggle() } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                            .frame(width: 64, height: 64)
                    }
                    .buttonStyle(.glassProminent)
                    .accessibilityLabel(isPlaying ? "Pause" : "Play")
                    .disabled(duration == 0)
                    Button { seek(by: skipInterval) } label: {
                        Image(systemName: "goforward")
                            .frame(width: 48, height: 48)
                    }
                    .accessibilityLabel("Forward \(skipInterval.formatted(.number.precision(.fractionLength(0)))) seconds")
                    .disabled(position >= duration)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .font(.title2)
                .tint(tint)
            }
        }
    }

    private var boundedPosition: Binding<Double> {
        Binding(
            get: { position.isFinite ? min(max(0, position), duration) : 0 },
            set: { position = min(max(0, $0), duration) }
        )
    }

    private func seek(by delta: Double) {
        boundedPosition.wrappedValue += delta
    }

    private func time(_ value: Double) -> String {
        let seconds = Int(min(max(0, value.isFinite ? value : 0), Double(Int32.max)))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
