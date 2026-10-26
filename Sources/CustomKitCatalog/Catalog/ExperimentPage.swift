import CustomKit
import SwiftUI
import UIKit

public struct ExperimentPage<Preview: View, Controls: View>: View {
    let title: String
    let subtitle: String
    let source: String
    let api: String
    let preview: Preview
    let controls: Controls
    @State private var showsControls = false
    @State private var showsCode = false
    @State private var copied = false

    public init(
        title: String,
        subtitle: String,
        source: String,
        api: String,
        @ViewBuilder preview: () -> Preview,
        @ViewBuilder controls: () -> Controls
    ) {
        self.title = title
        self.subtitle = subtitle
        self.source = source
        self.api = api
        self.preview = preview()
        self.controls = controls()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(source.uppercased())
                        .font(.system(.caption2, design: .monospaced))
                        .tracking(1.8)
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.system(.largeTitle, design: .serif))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                preview
                    .frame(maxWidth: .infinity, minHeight: 320)
                    .padding(20)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: .rect(cornerRadius: 28))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(.primary.opacity(0.07), lineWidth: 0.5)
                    }
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "hand.draw")
                    Text("This example is live. Try it, then open the controls to make it yours.")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding(24)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .scrollEdgeEffectStyle(.soft, for: .bottom)
        .background(Color(uiColor: .systemGroupedBackground).opacity(0.45))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showsCode = true
                } label: {
                    Image(systemName: "curlybraces")
                }
                .accessibilityLabel("Show usage code")
                .accessibilityIdentifier("experiment.code")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                showsControls = true
            } label: {
                Label("Customize", systemImage: "slider.horizontal.3")
                    .frame(maxWidth: .infinity)
                    .padding(12)
            }
            .customKitButton(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .frame(maxWidth: 760)
            .accessibilityIdentifier("experiment.customize")
        }
        .hapticSheet(isPresented: $showsControls) {
            NavigationStack {
                Form {
                    controls
                }
                .navigationTitle("Customize")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") { showsControls = false }
                            .accessibilityIdentifier("customize.done")
                    }
                }
            }
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
        }
        .hapticSheet(isPresented: $showsCode) {
            NavigationStack {
                ScrollView {
                    Text("import CustomKit\n\n" + api)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                }
                .navigationTitle("Use in your app")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
                            UIPasteboard.general.string = "import CustomKit\n\n" + api
                            copied = true
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showsCode = false }
                    }
                }
            }
        }
    }
}

struct ValueControl: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var suffix = ""

    init(title: String, value: Binding<Double>, range: ClosedRange<Double>, suffix: String = "") {
        self.title = title
        _value = value
        self.range = range
        self.suffix = suffix
    }

    init(title: String, value: Binding<CGFloat>, range: ClosedRange<Double>, suffix: String = "") {
        self.title = title
        _value = Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = CGFloat($0) })
        self.range = range
        self.suffix = suffix
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: "\(value.formatted(.number.precision(.fractionLength(1))))\(suffix)")
            SwiftUI.Slider(value: $value, in: range)
                .accessibilityLabel(title)
        }
    }
}
