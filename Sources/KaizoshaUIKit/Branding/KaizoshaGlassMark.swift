import SwiftUI

struct KaizoshaGlassMark: View {
    let lightDirection: CGVector
    let interaction: KaizoshaLogoInteractionPresentation
    let refraction: CGFloat
    let reduceMotion: Bool
    let reduceTransparency: Bool

    var body: some View {
        KaizoshaLogoArtwork(reduceTransparency: reduceTransparency)
            .compositingGroup()
            .visualEffect { content, proxy in
                content
                    .layerEffect(
                        ShaderLibrary.bundle(.module).kaizoshaGlassRefraction(
                            .float2(proxy.size),
                            .float2(lightDirection),
                            .float(interaction.stretch * 0.34 * refraction),
                            .float(interaction.refractionVelocity)
                        ),
                        maxSampleOffset: CGSize(width: 8, height: 8),
                        isEnabled: !reduceTransparency
                    )
                    .distortionEffect(
                        ShaderLibrary.bundle(.module).kaizoshaElasticWarp(
                            .float2(proxy.size),
                            .float2(interaction.direction),
                            .float(interaction.stretch),
                            .float(interaction.normalizedSpeed)
                        ),
                        maxSampleOffset: CGSize(width: 36, height: 36),
                        isEnabled: !reduceMotion && interaction.stretch > 0.001
                    )
            }
            .shadow(
                color: Color.primary.opacity(reduceTransparency ? 0 : 0.16),
                radius: 16,
                y: 6
            )
    }
}
