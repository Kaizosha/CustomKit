import SwiftUI
import UIKit

public struct MadeByKaizosha: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let configuration: CreditsConfiguration

    public init(configuration: CreditsConfiguration = .together) {
        self.configuration = configuration
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if configuration.showsLogo {
                        CreditsArtwork(
                            size: configuration.logoSize,
                            reduceTransparency: reduceTransparency
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text(verbatim: "Kaizōsha"))
                        .accessibilityAddTraits(.isImage)
                        .accessibilityIdentifier("credits.logo")
                    }

                    Text(verbatim: configuration.title)
                        .font(.largeTitle)
                        .fontDesign(.serif)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("credits.title")

                    VStack(spacing: 12) {
                        ForEach(configuration.paragraphs.indices, id: \.self) { index in
                            JustifiedCreditText(markdown: configuration.paragraphs[index])
                                .accessibilityIdentifier(
                                    index == 0 ? "credits.purpose"
                                        : index == 1 ? "credits.build"
                                        : "credits.paragraph.\(index)"
                                )
                        }
                    }
                    .frame(maxWidth: 520)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .scrollEdgeEffectStyle(.soft, for: .bottom)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .close) { dismiss() } label: { Image(systemName: "xmark") }
                        .buttonStyle(CreditsCloseButtonStyle())
                        .foregroundStyle(Color(uiColor: .systemBackground))
                        .controlSize(.regular)
                        .accessibilityLabel("Close")
                        .accessibilityIdentifier("credits.close")
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationSizing(.page.fitted(horizontal: false, vertical: true))
        .accessibilityIdentifier("credits.sheet")
    }
}

private struct CreditsArtwork: View {
    let size: CGFloat
    let reduceTransparency: Bool

    var body: some View {
        KaizoshaLogoArtwork(reduceTransparency: reduceTransparency)
            .compositingGroup()
            .visualEffect { content, proxy in
                content.layerEffect(
                    ShaderLibrary.bundle(.module).kaizoshaGlassRefraction(
                        .float2(proxy.size),
                        .float2(CGVector(dx: -0.22, dy: -0.32)),
                        .float(0),
                        .float(0)
                    ),
                    maxSampleOffset: CGSize(width: 8, height: 8),
                    isEnabled: !reduceTransparency
                )
            }
            .scaleEffect(size / KaizoshaLogoArtworkLayout.artworkWidth)
            .frame(
                width: size,
                height: size * KaizoshaLogoArtworkLayout.artworkHeight
                    / KaizoshaLogoArtworkLayout.artworkWidth
            )
    }
}

private struct CreditsCloseButtonStyle: PrimitiveButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        Button(role: isEnabled ? configuration.role : .confirm) {
            configuration.trigger()
        } label: {
            if isEnabled {
                configuration.label
            } else {
                configuration.label
                    .foregroundStyle(Color(uiColor: .systemBackground))
            }
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.circle)
        .tint(isEnabled ? Color(uiColor: .systemRed) : .accentColor)
    }
}
