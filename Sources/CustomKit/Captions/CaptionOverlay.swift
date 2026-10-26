import SwiftUI

public struct CaptionOverlay: View {
    private let text: String
    private let translation: String?
    private let fontSize: CGFloat

    public init(text: String, translation: String? = nil, fontSize: CGFloat = 22) {
        self.text = text
        self.translation = translation
        self.fontSize = fontSize.isFinite ? max(12, fontSize) : 22
    }

    public var body: some View {
        VStack(spacing: 6) {
            Text(text)
                .font(.system(size: fontSize, weight: .semibold))
            if let translation, !translation.isEmpty {
                Text(translation)
                    .font(.system(size: fontSize * 0.8))
            }
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.black.opacity(0.72), in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}
