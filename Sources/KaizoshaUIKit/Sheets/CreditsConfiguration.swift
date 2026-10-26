import SwiftUI

public struct CreditsConfiguration {
    public var title: String
    public var paragraphs: [String]
    public var showsLogo: Bool
    public var logoSize: CGFloat

    public init(
        title: String = "Made by Kaizōsha.",
        paragraphs: [String] = [
            "**Kaizōsha** designs and builds **Together** to help you understand the videos you choose. Import from Photos or Files, then watch with captions, translate speech, review transcripts, or export your work.",
            "Together uses *native Apple frameworks* for playback, speech recognition, and translation. These tools process your videos and language choices *on your device*. There is no Together account, and your media is not uploaded to a Kaizōsha server.",
        ],
        showsLogo: Bool = true,
        logoSize: CGFloat = 160
    ) {
        self.title = title
        self.paragraphs = paragraphs
        self.showsLogo = showsLogo
        self.logoSize = logoSize
    }

    public static var together: Self { Self() }
}
