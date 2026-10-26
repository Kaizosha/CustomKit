import SwiftUI
import Testing
import UIKit
@testable import KaizoshaUIKit

@MainActor
struct CreditsTests {
    @Test("Credits default to Together's original wording and artwork size")
    func togetherDefaults() {
        let configuration = CreditsConfiguration.together

        #expect(configuration.title == "Made by Kaizōsha.")
        #expect(configuration.paragraphs == [
            "**Kaizōsha** designs and builds **Together** to help you understand the videos you choose. Import from Photos or Files, then watch with captions, translate speech, review transcripts, or export your work.",
            "Together uses *native Apple frameworks* for playback, speech recognition, and translation. These tools process your videos and language choices *on your device*. There is no Together account, and your media is not uploaded to a Kaizōsha server.",
        ])
        #expect(configuration.showsLogo)
        #expect(configuration.logoSize == 160)
        #expect(CreditsConfiguration().paragraphs == configuration.paragraphs)
        _ = MadeByKaizosha()
    }

    @Test("Apps can customize the credits without changing their supplied copy")
    func customConfiguration() {
        var configuration = CreditsConfiguration(
            title: "Made for our team.",
            paragraphs: ["Built by **Kaizōsha**.", "Available *on your device*."],
            showsLogo: false,
            logoSize: 96
        )
        configuration.title = "Our credits"
        configuration.paragraphs.append("Thank you.")
        configuration.showsLogo = true
        configuration.logoSize = 120

        #expect(configuration.title == "Our credits")
        #expect(configuration.paragraphs == [
            "Built by **Kaizōsha**.",
            "Available *on your device*.",
            "Thank you.",
        ])
        #expect(configuration.showsLogo)
        #expect(configuration.logoSize == 120)
        _ = MadeByKaizosha(configuration: configuration)
    }

    @Test("Inline emphasis retains readable text and monospaced font traits")
    func inlineEmphasis() throws {
        let result = JustifiedCreditText.attributedText(
            for: "Plain **bold** and *italic* with **bold *both***."
        )

        #expect(result.string == "Plain bold and italic with bold both.")

        let plain = try font(in: result, at: "Plain")
        #expect(plain.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
        #expect(!plain.fontDescriptor.symbolicTraits.contains(.traitBold))
        #expect(!plain.fontDescriptor.symbolicTraits.contains(.traitItalic))

        let bold = try font(in: result, at: "bold")
        #expect(bold.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
        #expect(bold.fontDescriptor.symbolicTraits.contains(.traitBold))
        #expect(!bold.fontDescriptor.symbolicTraits.contains(.traitItalic))

        let italic = try font(in: result, at: "italic")
        #expect(italic.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
        #expect(italic.fontDescriptor.symbolicTraits.contains(.traitItalic))

        let both = try font(in: result, at: "both")
        #expect(both.fontDescriptor.symbolicTraits.contains(.traitBold))
        #expect(both.fontDescriptor.symbolicTraits.contains(.traitItalic))
    }

    @Test("Credits justify their paragraphs and use the adaptive secondary label color")
    func nativeTextAppearance() throws {
        let result = JustifiedCreditText.attributedText(for: "A native paragraph.")
        let style = try #require(
            result.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        )
        let color = try #require(
            result.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        )

        #expect(style.alignment == .justified)
        for appearance in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: appearance)
            #expect(
                color.resolvedColor(with: traits).isEqual(
                    UIColor.secondaryLabel.resolvedColor(with: traits)
                )
            )
        }
    }

    @Test("Credits body text follows the requested Dynamic Type size")
    func dynamicType() throws {
        let standard = JustifiedCreditText.attributedText(
            for: "Readable",
            compatibleWith: UITraitCollection(preferredContentSizeCategory: .large)
        )
        let accessible = JustifiedCreditText.attributedText(
            for: "Readable",
            compatibleWith: UITraitCollection(
                preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge
            )
        )

        let standardFont = try font(in: standard, at: "Readable")
        let accessibleFont = try font(in: accessible, at: "Readable")
        #expect(accessibleFont.pointSize > standardFont.pointSize)
    }

    private func font(in text: NSAttributedString, at word: String) throws -> UIFont {
        let range = (text.string as NSString).range(of: word)
        try #require(range.location != NSNotFound)
        return try #require(text.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont)
    }
}
