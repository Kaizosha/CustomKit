import KaizoshaUIKit
import SwiftUI
import UIKit

struct LogoExample: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var configuration = LogoConfiguration()
    @State private var showsCustomization = false
    @State private var selectedDetent = PresentationDetent.medium

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            GeometryReader { geometry in
                let canvasHeight = showsCustomization && selectedDetent == .medium
                    ? geometry.size.height / 2 : geometry.size.height
                KaizoshaLogo(configuration: configuration)
                    .accessibilityIdentifier("logo.element")
                    .position(x: geometry.size.width / 2, y: canvasHeight / 2)
                    .animation(reduceMotion ? nil : .snappy, value: canvasHeight)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Kaizosha Logo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Customize", systemImage: "slider.horizontal.3") {
                    selectedDetent = .medium
                    showsCustomization = true
                }
                .labelStyle(.iconOnly)
                .accessibilityIdentifier("component.customize")
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: showsCustomization)
        .sheet(isPresented: $showsCustomization) {
            NavigationStack {
                Form {
                    Section("Logo") {
                        valueControl("Size", value: $configuration.size, range: 80...280, suffix: " pt")
                        valueControl("Refraction", value: $configuration.refraction, range: 0...2)
                        Toggle("Interactive", isOn: $configuration.interactive)
                        Toggle("Haptics", isOn: $configuration.hapticsEnabled)
                        Toggle("Follow device tilt", isOn: $configuration.motionEnabled)
                    }
                    Section("Light direction") {
                        valueControl("Horizontal", value: $configuration.lightDirection.dx, range: -1...1)
                        valueControl("Vertical", value: $configuration.lightDirection.dy, range: -1...1)
                    }
                    .disabled(configuration.motionEnabled)
                    Section {
                        Button("Reset", role: .destructive) { configuration = .init() }
                            .accessibilityIdentifier("logo.reset")
                        NavigationLink("Use in your app") { LogoUsageCode() }
                            .accessibilityIdentifier("component.code")
                    }
                }
                .navigationTitle("Customize")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") { showsCustomization = false }
                            .accessibilityIdentifier("customize.done")
                    }
                }
            }
            .presentationSizing(.page.fitted(horizontal: false, vertical: true))
            .presentationDetents([.medium, .large], selection: $selectedDetent)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .sensoryFeedback(.selection, trigger: selectedDetent)
        }
    }

    private func valueControl(_ title: String, value: Binding<CGFloat>, range: ClosedRange<Double>, suffix: String = "") -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: "\(Double(value.wrappedValue).formatted(.number.precision(.fractionLength(1))))\(suffix)")
            Slider(value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = CGFloat($0) }), in: range)
                .accessibilityLabel(title)
        }
    }
}

private struct LogoUsageCode: View {
    @State private var copied = false
    private let code = """
    import KaizoshaUIKit

    KaizoshaLogo()

    KaizoshaLogo(configuration: LogoConfiguration(
        size: 200,
        interactive: true,
        hapticsEnabled: true,
        motionEnabled: true,
        refraction: 1
    ))
    """

    var body: some View {
        ScrollView {
            Text(code)
                .font(.system(.footnote, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
        }
        .navigationTitle("Use in your app")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
                    UIPasteboard.general.string = code
                    copied = true
                }
            }
        }
    }
}
