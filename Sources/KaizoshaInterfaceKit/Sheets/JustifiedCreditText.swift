import SwiftUI
import UIKit

struct JustifiedCreditText: UIViewRepresentable {
    let markdown: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.adjustsFontForContentSizeCategory = true
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let traits = UITraitCollection(
            preferredContentSizeCategory: UIContentSizeCategory(context.environment.dynamicTypeSize)
        )
        view.attributedText = Self.attributedText(for: markdown, compatibleWith: traits)
        view.accessibilityLabel = markdown.replacingOccurrences(of: "*", with: "")
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width.isFinite else { return nil }
        return uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
    }

    nonisolated static func attributedText(
        for source: String,
        compatibleWith traits: UITraitCollection? = nil
    ) -> NSAttributedString {
        let baseSize = UIFont.preferredFont(forTextStyle: .body, compatibleWith: traits).pointSize
        let baseFont = UIFont.monospacedSystemFont(ofSize: baseSize, weight: .regular)
        let paragraphStyle: NSParagraphStyle = {
            let style = NSMutableParagraphStyle()
            style.alignment = .justified
            return style
        }()
        let result = NSMutableAttributedString()
        var remainder = source[...]
        var isBold = false
        var isItalic = false
        while let marker = remainder.firstIndex(of: "*") {
            result.append(run(String(remainder[..<marker]), bold: isBold, italic: isItalic, baseFont: baseFont, paragraphStyle: paragraphStyle))
            if remainder[marker...].hasPrefix("**") {
                isBold.toggle()
                remainder = remainder[remainder.index(marker, offsetBy: 2)...]
            } else {
                isItalic.toggle()
                remainder = remainder[remainder.index(after: marker)...]
            }
        }
        result.append(run(String(remainder), bold: isBold, italic: isItalic, baseFont: baseFont, paragraphStyle: paragraphStyle))
        return result
    }

    nonisolated private static func run(
        _ text: String,
        bold: Bool,
        italic: Bool,
        baseFont: UIFont,
        paragraphStyle: NSParagraphStyle
    ) -> NSAttributedString {
        guard !text.isEmpty else { return NSAttributedString() }
        var traits = UIFontDescriptor.SymbolicTraits.traitMonoSpace
        if bold { traits.insert(.traitBold) }
        if italic { traits.insert(.traitItalic) }
        let font: UIFont = {
            guard !traits.isEmpty,
                let described = baseFont.fontDescriptor.withSymbolicTraits(traits)
            else {
                return baseFont
            }
            return UIFont(descriptor: described, size: baseFont.pointSize)
        }()
        return NSAttributedString(string: text, attributes: [
            .font: font,
            .foregroundColor: UIColor.secondaryLabel,
            .paragraphStyle: paragraphStyle,
        ])
    }
}
