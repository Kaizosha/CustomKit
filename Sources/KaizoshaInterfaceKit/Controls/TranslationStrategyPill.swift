import SwiftUI
import UIKit

public struct TranslationStrategyPillConfiguration {
    public var tint: Color
    public var isCompact: Bool
    public var status: String
    public var detail: String
    public var comparison: String

    public init(
        tint: Color = .accentColor,
        isCompact: Bool = false,
        status: String = "Ready",
        detail: String = "",
        comparison: String = "Low Latency provides faster on-device translation. High Fidelity uses Apple Intelligence for more natural, context-aware wording and may take longer."
    ) {
        self.tint = tint
        self.isCompact = isCompact
        self.status = status
        self.detail = detail
        self.comparison = comparison
    }
}

/// Together's morphing glass strategy surface, without a translation session or hardware policy.
public struct TranslationStrategyPill: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var glassNamespace
    @State private var showsGuidance = false
    @Binding private var selection: TranslationStrategy
    private var isHighFidelityAvailable: Bool
    private var configuration: TranslationStrategyPillConfiguration
    private var onUnavailableHighFidelitySelection: () -> Void

    public init(
        selection: Binding<TranslationStrategy>,
        isHighFidelityAvailable: Bool = true,
        configuration: TranslationStrategyPillConfiguration = .init(),
        onUnavailableHighFidelitySelection: @escaping () -> Void = {}
    ) {
        self._selection = selection
        self.isHighFidelityAvailable = isHighFidelityAvailable
        self.configuration = configuration
        self.onUnavailableHighFidelitySelection = onUnavailableHighFidelitySelection
    }

    public var body: some View {
        GlassEffectContainer(spacing: 20) {
            ZStack {
                if configuration.isCompact {
                    surface(compact: true)
                        .glassEffectID("translation-strategy-compact", in: glassNamespace)
                        .glassEffectTransition(.matchedGeometry)
                } else {
                    surface(compact: false)
                        .glassEffectID("translation-strategy-expanded", in: glassNamespace)
                        .glassEffectTransition(.matchedGeometry)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .animation(reduceMotion ? nil : .smooth, value: configuration.isCompact)
        .popover(isPresented: $showsGuidance, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
            guidance
                .presentationCompactAdaptation(.popover)
        }
    }

    private func surface(compact: Bool) -> some View {
        controls(compact: compact)
            .padding(.horizontal, compact ? 12 : 20)
            .frame(maxWidth: compact ? nil : .infinity, minHeight: compact ? 46 : 66, alignment: .leading)
            .contentShape(Capsule())
            .glassEffect(.regular.tint(configuration.tint).interactive(), in: Capsule())
    }

    @ViewBuilder
    private func controls(compact: Bool) -> some View {
        if compact {
            HStack(spacing: 4) {
                infoButton(compact: true)
                switcher
            }
        } else if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 10) {
                infoButton(compact: false)
                switcher
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    infoButton(compact: false)
                    switcher
                }
                VStack(alignment: .leading, spacing: 10) {
                    infoButton(compact: false)
                    switcher
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func infoButton(compact: Bool) -> some View {
        Button {
            showsGuidance = true
        } label: {
            Group {
                if compact {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        .frame(width: 44, height: 44)
                } else {
                    Text("Translation Strategy")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }
            }
            .foregroundStyle(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Translation Strategy")
        .accessibilityHint("Explain Low Latency, High Fidelity, and current availability.")
        .accessibilityIdentifier("kaizosha.translation-strategy-info")
    }

    private var switcher: some View {
        TranslationStrategySwitcher(
            selection: $selection,
            isHighFidelityAvailable: isHighFidelityAvailable,
            configuration: .onGlass,
            onUnavailableHighFidelitySelection: onUnavailableHighFidelitySelection
        )
    }

    private var guidanceMessage: Text {
        let availability = isHighFidelityAvailable
            ? "High Fidelity is available."
            : "High Fidelity is unavailable. Low Latency remains available."
        let comparison = Text(verbatim: configuration.comparison)
        let details = [configuration.status, configuration.detail]
            .filter { !$0.isEmpty }
            .map { "\n" + $0 }
            .joined()
        return Text("\(comparison)\n\n\(Text(verbatim: availability).bold())\(Text(verbatim: details))")
    }

    private var guidance: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Translation Strategy").font(.headline)
                guidanceMessage
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(idealWidth: 320, maxWidth: 360, idealHeight: 320, maxHeight: 420)
        .accessibilityIdentifier("kaizosha.translation-strategy-guidance")
    }
}
