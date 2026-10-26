//
//  KaizoshaLogoArtwork.swift
//  KaizoshaUIKit
//

import SwiftUI

/// One shared grid keeps the three characters and pillars optically aligned
/// everywhere the Kaizōsha mark appears.
nonisolated enum KaizoshaLogoArtworkLayout {
    static let artworkWidth: CGFloat = 160
    static let artworkHeight: CGFloat = 151
    static let columnRegionWidth: CGFloat = 148
    static let columnWidth: CGFloat = 40
    static let columnSpacing: CGFloat = 14
    static let pillarHeight: CGFloat = 105
    static let rowSpacing: CGFloat = 9

    static func columnCenter(at index: Int) -> CGFloat {
        columnWidth / 2
            + CGFloat(index) * (columnWidth + columnSpacing)
    }
}

/// Renders the canonical three-pillar Kaizōsha artwork without owning motion
/// or interaction. Each presentation supplies its own lifecycle and effects.
struct KaizoshaLogoArtwork: View {
    let reduceTransparency: Bool

    var body: some View {
        let pillars = KaizoshaPillarsShape()

        VStack(spacing: KaizoshaLogoArtworkLayout.rowSpacing) {
            Color.clear
                .glassEffect(
                    .regular.tint(Color.primary.opacity(0.08)),
                    in: pillars
                )
                .overlay {
                    pillars
                        .stroke(
                            Color.primary.opacity(
                                reduceTransparency ? 0 : 0.42
                            ),
                            lineWidth: 0.75
                        )
                }
                .background {
                    pillars
                        .fill(
                            Color.primary.opacity(
                                reduceTransparency ? 1 : 0.38
                            )
                        )
                }
                .frame(
                    width: KaizoshaLogoArtworkLayout.columnRegionWidth,
                    height: KaizoshaLogoArtworkLayout.pillarHeight
                )

            HStack(spacing: KaizoshaLogoArtworkLayout.columnSpacing) {
                logoCharacter("改")
                logoCharacter("造")
                logoCharacter("社")
            }
            .font(.system(size: 31, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: KaizoshaLogoArtworkLayout.columnRegionWidth)
        }
        .frame(
            width: KaizoshaLogoArtworkLayout.artworkWidth,
            height: KaizoshaLogoArtworkLayout.artworkHeight,
            alignment: .center
        )
    }

    private func logoCharacter(_ character: String) -> some View {
        Text(verbatim: character)
            .frame(width: KaizoshaLogoArtworkLayout.columnWidth)
    }
}

struct KaizoshaPillarsShape: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        let scale =
            rect.width
            / KaizoshaLogoArtworkLayout.columnRegionWidth
        let pillarWidth = KaizoshaLogoArtworkLayout.columnWidth * scale
        var path = Path()

        for index in 0..<3 {
            let centerX =
                KaizoshaLogoArtworkLayout.columnCenter(
                    at: index
                ) * scale
            let originX = centerX - pillarWidth / 2
            path.addRoundedRect(
                in: CGRect(
                    x: originX,
                    y: 0,
                    width: pillarWidth,
                    height: rect.height
                ),
                cornerSize: CGSize(width: 2, height: 2),
                style: .continuous
            )
        }

        return path
    }
}
