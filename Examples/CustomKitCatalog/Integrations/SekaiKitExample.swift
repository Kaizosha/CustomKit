import CustomKitCatalog
import SekaiKit
import SwiftUI

struct SekaiKitExample: View {
    private enum Appearance: String, CaseIterable, Identifiable {
        case system = "System", light = "Light", dark = "Dark"
        var id: String { rawValue }
    }

    @State private var camera = SekaiCamera.standard
    @State private var rotationSpeed = 0.08
    @State private var rotates = true
    @State private var showsOverlays = true
    @State private var dotSize = 0.008
    @State private var density = 16_000.0
    @State private var glow = 0.12
    @State private var appearance = Appearance.system
    @State private var status = SekaiRenderStatus.preparing
    private let chicago = SekaiCoordinate(latitude: 41.8781, longitude: -87.6298)
    private let tokyo = SekaiCoordinate(latitude: 35.6762, longitude: 139.6503)

    var body: some View {
        ExperimentPage(
            title: "SekaiKit",
            subtitle: "A language connection between Chicago and Tokyo.",
            source: "Sekai · Native Metal globe",
            api: """
            import SekaiKit

            Sekai(
                camera: $camera,
                style: .automatic,
                activity: .active(rotationSpeed: 0.08),
                markers: markers,
                arcs: arcs
            )
            """
        ) {
            VStack(spacing: 20) {
                Sekai(
                    camera: $camera,
                    style: style,
                    activity: .active(rotationSpeed: rotates ? rotationSpeed : 0),
                    interaction: .rotationAndZoom,
                    markers: markers,
                    arcs: arcs,
                    onStatusChange: { status = $0 }
                )
                .frame(maxWidth: 460)
                .accessibilityIdentifier("sekai.globe")
                if case .failed = status {
                    Label("Metal rendering is unavailable.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Chicago → Tokyo")
                            .font(.system(.title3, design: .serif))
                        Text("ENGLISH / 日本語")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "globe.americas")
                        .font(.title2)
                        .foregroundStyle(.teal)
                }
                HStack(spacing: 12) {
                    Button("Chicago") { camera.focus(on: chicago) }
                    Button("Tokyo") { camera.focus(on: tokyo) }
                }
                .buttonStyle(.glass)
                .controlSize(.large)
                Text("Drag to rotate. Pinch to zoom.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        } controls: {
            Section("Globe") {
                Picker("Appearance", selection: $appearance) {
                    ForEach(Appearance.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                Toggle("Rotate globe", isOn: $rotates)
                Toggle("Show cities and connection", isOn: $showsOverlays)
                LabeledContent("Rotation", value: rotationSpeed.formatted(.number.precision(.fractionLength(2))))
                SwiftUI.Slider(value: $rotationSpeed, in: 0.01...0.3)
                    .accessibilityLabel("Rotation speed")
                LabeledContent("Dot size", value: dotSize.formatted(.number.precision(.fractionLength(3))))
                SwiftUI.Slider(value: $dotSize, in: 0.003...0.018)
                    .accessibilityLabel("Dot size")
                LabeledContent("Density", value: Int(density).formatted())
                SwiftUI.Slider(value: $density, in: 4_000...40_000, step: 2_000)
                    .accessibilityLabel("Dot density")
                LabeledContent("Glow", value: glow.formatted(.percent))
                SwiftUI.Slider(value: $glow, in: 0...0.6)
                    .accessibilityLabel("Glow")
            }
            Section {
                Button("Reset globe", systemImage: "arrow.counterclockwise") {
                    camera = .standard
                    rotationSpeed = 0.08
                    rotates = true
                    showsOverlays = true
                    dotSize = 0.008
                    density = 16_000
                    glow = 0.12
                    appearance = .system
                }
            }
        }
    }

    private var style: SekaiStyle {
        SekaiStyle(
            appearance: appearance == .system ? .automatic : appearance == .light ? .light : .dark,
            sampleCount: Int(density),
            dotSize: dotSize,
            glow: glow
        )
    }

    private var markers: [SekaiMarker] {
        showsOverlays ? [
            .init(id: "chicago", coordinate: chicago),
            .init(id: "tokyo", coordinate: tokyo)
        ] : []
    }

    private var arcs: [SekaiArc] {
        showsOverlays ? [.init(id: "chicago-tokyo", from: chicago, to: tokyo)] : []
    }
}
