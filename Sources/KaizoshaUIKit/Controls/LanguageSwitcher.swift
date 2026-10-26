import SwiftUI

public enum LanguageRole: String, CaseIterable, Identifiable, Sendable {
    case source
    case translation
    public var id: Self { self }
}

public struct LanguageSwitcher: View {
    @Binding private var selection: LanguageRole
    private var width: CGFloat
    private var sourceTitle: String
    private var translationTitle: String

    public init(
        selection: Binding<LanguageRole>,
        width: CGFloat = 210,
        sourceTitle: String = "Source",
        translationTitle: String = "Translate"
    ) {
        self._selection = selection
        self.width = width
        self.sourceTitle = sourceTitle
        self.translationTitle = translationTitle
    }

    public var body: some View {
        Picker("Language Type", selection: $selection) {
            Text(sourceTitle).tag(LanguageRole.source)
            Text(translationTitle).tag(LanguageRole.translation)
        }
        .pickerStyle(.segmented)
        .frame(width: width)
        .accessibilityIdentifier("kaizosha.language-switcher")
    }
}
