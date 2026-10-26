import SwiftUI

public struct LaunchConfiguration {
    public var duration: Double
    public var symbolSize: CGFloat
    public var hapticsEnabled: Bool

    public init(duration: Double = 1.65, symbolSize: CGFloat = 45, hapticsEnabled: Bool = true) {
        self.duration = duration
        self.symbolSize = symbolSize
        self.hapticsEnabled = hapticsEnabled
    }
}

public struct LaunchAnimation: View {
    public var configuration: LaunchConfiguration
    private let onComplete: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0
    @State private var feedback = 0

    public init(configuration: LaunchConfiguration = .init(), onComplete: @escaping () -> Void = {}) {
        self.configuration = configuration
        self.onComplete = onComplete
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                chevron("chevron.left", direction: -1, width: geometry.size.width)
                chevron("chevron.right", direction: 1, width: geometry.size.width)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: feedback) { _, _ in
            configuration.hapticsEnabled && !reduceMotion
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Kaizōsha launch animation")
        .task {
            let duration = configuration.duration.isFinite ? max(0.1, configuration.duration) : 1.65
            do {
                if !reduceMotion { try await Task.sleep(for: .seconds(0.16)) }
                guard !Task.isCancelled else { return }
                withAnimation(reduceMotion ? nil : .easeInOut(duration: duration)) { progress = 1 }
                try await Task.sleep(for: .seconds(reduceMotion ? 0.2 : duration))
                guard !Task.isCancelled else { return }
                feedback &+= 1
                onComplete()
            } catch {}
        }
    }

    private func chevron(_ symbol: String, direction: CGFloat, width: CGFloat) -> some View {
        let size = configuration.symbolSize.isFinite ? max(12, configuration.symbolSize) : 45
        let start = width / 2 + size * 1.5
        return Image(systemName: symbol)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .offset(x: direction * (start + (size * 0.65 - start) * progress))
    }
}
