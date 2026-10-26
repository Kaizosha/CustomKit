import SwiftUI

public struct LogoConfiguration {
    public var size: CGFloat
    public var interactive: Bool
    public var refraction: Double
    public var hapticsEnabled: Bool
    public var lightDirection: CGVector

    public init(
        size: CGFloat = 160,
        interactive: Bool = true,
        refraction: Double = 0.5,
        hapticsEnabled: Bool = true,
        lightDirection: CGVector = CGVector(dx: -0.35, dy: -0.55)
    ) {
        self.size = size
        self.interactive = interactive
        self.refraction = refraction
        self.hapticsEnabled = hapticsEnabled
        self.lightDirection = lightDirection
    }
}

/// The canonical Kaizōsha artwork with package-owned Metal and elastic dragging.
public struct KaizoshaLogo: View {
    public var configuration: LogoConfiguration

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @GestureState private var isDragging = false
    @State private var translation = CGSize.zero
    @State private var velocity = CGSize.zero
    @State private var textureStep = 0
    @State private var releaseTrigger = 0

    public init(configuration: LogoConfiguration = .init()) {
        self.configuration = configuration
    }

    private var size: CGFloat {
        configuration.size.isFinite ? max(24, configuration.size) : 160
    }

    public var body: some View {
        let interaction = KaizoshaLogoInteractionPolicy.presentation(
            translation: translation,
            velocity: velocity,
            reduceMotion: reduceMotion
        )
        let refraction = configuration.refraction.isFinite
            ? min(max(configuration.refraction, 0), 1) : 0.5
        let lightDirection = configuration.lightDirection
        let glassEnabled = !reduceTransparency && refraction > 0
        let deformationEnabled = !reduceMotion && interaction.stretch > 0.001

        KaizoshaLogoArtwork(reduceTransparency: reduceTransparency)
            .compositingGroup()
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        ShaderLibrary.bundle(.module).kaizoshaGlassRefraction(
                            .float2(proxy.size),
                            .float2(lightDirection),
                            .float(refraction),
                            .float(interaction.refractionVelocity)
                        ),
                        maxSampleOffset: CGSize(width: 8, height: 8),
                        isEnabled: glassEnabled
                    )
                    .distortionEffect(
                        ShaderLibrary.bundle(.module).kaizoshaElasticWarp(
                            .float2(proxy.size),
                            .float2(interaction.direction),
                            .float(interaction.stretch),
                            .float(interaction.normalizedSpeed)
                        ),
                        maxSampleOffset: CGSize(width: 36, height: 36),
                        isEnabled: deformationEnabled
                    )
            }
            .scaleEffect(x: interaction.scaleX, y: interaction.scaleY)
            .rotation3DEffect(
                .degrees(interaction.tiltDegrees),
                axis: (x: -interaction.direction.dy * 0.42, y: interaction.direction.dx, z: 0),
                perspective: 0.32
            )
            .scaleEffect(size / KaizoshaLogoArtworkLayout.artworkWidth)
            .frame(width: size, height: size * 151 / 160)
            .offset(interaction.offset)
            .contentShape(Rectangle())
            .gesture(drag, isEnabled: configuration.interactive)
            .sensoryFeedback(.selection, trigger: textureStep) { _, _ in
                configuration.hapticsEnabled && !reduceMotion
            }
            .sensoryFeedback(.impact(weight: .light), trigger: releaseTrigger) { _, _ in
                configuration.hapticsEnabled && !reduceMotion
            }
            .onChange(of: isDragging) { _, active in
                if !active { settle() }
            }
            .onChange(of: configuration.interactive) { _, _ in settle() }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Kaizōsha")
            .accessibilityAddTraits(.isImage)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 1)
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                translation = value.translation
                velocity = value.velocity
                textureStep = Int(hypot(translation.width, translation.height) / 14)
            }
            .onEnded { value in
                if hypot(value.translation.width, value.translation.height)
                    > KaizoshaLogoInteractionPolicy.minimumReleaseFeedbackDistance {
                    releaseTrigger &+= 1
                }
                settle()
            }
    }

    private func settle() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.65, dampingFraction: 0.66)) {
            translation = .zero
            velocity = .zero
        }
    }
}
