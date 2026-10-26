import SwiftUI
import UIKit

struct ComponentPage<Element: View, Controls: View>: View {
    let title: String
    var fillsCanvas = false
    let code: String
    let reset: () -> Void
    let element: Element
    let controls: Controls

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsCustomization = false
    @State private var selectedDetent = PresentationDetent.medium

    init(
        title: String,
        fillsCanvas: Bool = false,
        code: String,
        reset: @escaping () -> Void,
        @ViewBuilder element: () -> Element,
        @ViewBuilder controls: () -> Controls
    ) {
        self.title = title
        self.fillsCanvas = fillsCanvas
        self.code = code
        self.reset = reset
        self.element = element()
        self.controls = controls()
    }

    var body: some View {
        GeometryReader { geometry in
            let height = showsCustomization && selectedDetent == .medium
                ? geometry.size.height / 2 : geometry.size.height
            Group {
                if fillsCanvas {
                    element.frame(width: geometry.size.width, height: height)
                } else {
                    element
                        .frame(maxWidth: max(0, geometry.size.width - 40))
                        .position(x: geometry.size.width / 2, y: height / 2)
                }
            }
            .animation(reduceMotion ? nil : .snappy, value: height)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle(title)
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
                    controls
                    Section {
                        Button("Reset", role: .destructive, action: reset)
                            .accessibilityIdentifier("component.reset")
                        NavigationLink("Use in your app") { UsageCode(code: code) }
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
}

struct ValueControl: View {
    let title: String
    @Binding var value: CGFloat
    let range: ClosedRange<Double>
    var suffix = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: "\(Double(value).formatted(.number.precision(.fractionLength(1))))\(suffix)")
            Slider(value: Binding(get: { Double(value) }, set: { value = CGFloat($0) }), in: range)
                .accessibilityLabel(title)
        }
    }
}

struct UsageCode: View {
    let code: String
    @State private var copied = false

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
