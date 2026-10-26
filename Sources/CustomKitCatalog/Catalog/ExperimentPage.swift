import CustomKit
import SwiftUI
import UIKit

public struct ExperimentPage<Preview: View, Controls: View>: View {
    let title: String
    let api: String
    let preview: Preview
    let controls: Controls
    @State private var showsControls = false

    public init(
        title: String,
        api: String,
        @ViewBuilder preview: () -> Preview,
        @ViewBuilder controls: () -> Controls
    ) {
        self.title = title
        self.api = api
        self.preview = preview()
        self.controls = controls()
    }

    public var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            preview
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Customize", systemImage: "slider.horizontal.3") {
                    showsControls = true
                }
                .labelStyle(.iconOnly)
                .accessibilityIdentifier("experiment.customize")
            }
        }
        .hapticSheet(isPresented: $showsControls) {
            NavigationStack {
                Form {
                    controls
                    Section {
                        NavigationLink {
                            UsageCode(api: api)
                        } label: {
                            Label("Use in your app", systemImage: "curlybraces")
                        }
                        .accessibilityIdentifier("experiment.code")
                    }
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
    }
}

private struct UsageCode: View {
    let api: String
    @State private var copied = false

    var body: some View {
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
            ToolbarItem(placement: .topBarTrailing) {
                Button(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc") {
                    UIPasteboard.general.string = "import CustomKit\n\n" + api
                    copied = true
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
