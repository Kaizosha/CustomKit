import SwiftUI

public struct StartConfiguration {
    public var title: [String]
    public var subtitle: String
    public var actionTitle: String
    public var actionSymbol: String
    public var accent: Color
    public var showsBrand: Bool
    public var appName: String

    public init(
        title: [String],
        subtitle: String,
        actionTitle: String,
        actionSymbol: String,
        accent: Color = .primary,
        showsBrand: Bool = true,
        appName: String = "CustomKit"
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.actionSymbol = actionSymbol
        self.accent = accent
        self.showsBrand = showsBrand
        self.appName = appName
    }

    public static var together: Self {
        .init(title: ["Bring", "Worlds", "Together."],
              subtitle: "nothing gets lost in translation. watch anything. hear everything.",
              actionTitle: "Play", actionSymbol: "chevron.forward", appName: "Together")
    }

    public static var pinch: Self {
        .init(title: ["Too", "Long?", "Just Pinch."],
              subtitle: "pinch to see less, know more - summarize web pages and explain selected text with intelligence",
              actionTitle: "Enable in Safari", actionSymbol: "safari", appName: "TL;Pinch")
    }

    public static var skeleton: Self {
        .init(title: ["Speak freely.", "Understand more.", "Stay together."],
              subtitle: "a little closer, in any language.",
              actionTitle: "Try Skeleton", actionSymbol: "waveform", appName: "Skeleton")
    }
}

public struct StartTemplate: View {
    public var configuration: StartConfiguration
    private let onPrimaryAction: () -> Void
    private let onControls: (() -> Void)?

    public init(
        configuration: StartConfiguration,
        onPrimaryAction: @escaping () -> Void,
        onControls: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.onPrimaryAction = onPrimaryAction
        self.onControls = onControls
    }

    @ScaledMetric(relativeTo: .title3) private var sectionSpacing = 45
    @ScaledMetric(relativeTo: .body) private var actionHeight = 50

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: sectionSpacing) {
                        VStack(alignment: .leading) {
                            ForEach(Array(configuration.title.enumerated()), id: \.offset) { _, line in
                                Text(line)
                                    .font(.largeTitle.bold())
                                    .fontDesign(.serif)
                            }
                            Text(configuration.subtitle)
                                .font(.subheadline.weight(.medium))
                                .fontDesign(.monospaced)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                        GlassEffectContainer(spacing: 16) {
                            HStack(spacing: 16) {
                                Button(action: onPrimaryAction) {
                                    Label(configuration.actionTitle, systemImage: configuration.actionSymbol)
                                        .font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: actionHeight)
                                }
                                .buttonStyle(.glass)
                                .buttonBorderShape(.capsule)
                                .tint(configuration.accent)

                                if let onControls {
                                    Button(action: onControls) {
                                        Image(systemName: "slider.horizontal.3")
                                            .font(.body.weight(.semibold))
                                            .frame(width: actionHeight, height: actionHeight)
                                    }
                                    .buttonStyle(.glass)
                                    .buttonBorderShape(.circle)
                                    .tint(configuration.accent)
                                    .accessibilityLabel("Controls")
                                }
                            }
                        }
                    }
                    Spacer(minLength: sectionSpacing)
                    if configuration.showsBrand {
                        HStack(spacing: 4) {
                            Text("\(configuration.appName) by")
                                .foregroundStyle(.secondary)
                            Text("Kaizōsha")
                                .underline()
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollEdgeEffectStyle(.soft, for: [.top, .bottom])
        }
    }
}
