import SwiftUI
import UIKit

public enum TranslationStrategy: String, CaseIterable, Identifiable, Sendable {
    case lowLatency
    case highFidelity

    public var id: Self { self }
    public var compactTitle: String {
        switch self {
        case .lowLatency: "Low"
        case .highFidelity: "High"
        }
    }
    public var title: String {
        switch self {
        case .lowLatency: "Low Latency"
        case .highFidelity: "High Fidelity"
        }
    }
}

public struct TranslationStrategySwitcherConfiguration {
    public var foregroundColor: UIColor
    public var selectedForegroundColor: UIColor
    public var lowTint: UIColor
    public var highTint: UIColor
    public var width: CGFloat
    public var height: CGFloat

    public init(
        foregroundColor: UIColor = .label,
        selectedForegroundColor: UIColor = .systemBackground,
        lowTint: UIColor = .label,
        highTint: UIColor = .systemOrange,
        width: CGFloat = 128,
        height: CGFloat = 28
    ) {
        self.foregroundColor = foregroundColor
        self.selectedForegroundColor = selectedForegroundColor
        self.lowTint = lowTint
        self.highTint = highTint
        self.width = width
        self.height = height
    }

    public static var onGlass: Self {
        .init(foregroundColor: .systemBackground)
    }
}

/// A native Low/High selector. Availability and translation work belong to the host.
public struct TranslationStrategySwitcher: View {
    @Binding private var selection: TranslationStrategy
    private var isEnabled: Bool
    private var isHighFidelityAvailable: Bool
    private var configuration: TranslationStrategySwitcherConfiguration
    private var onUnavailableHighFidelitySelection: () -> Void

    public init(
        selection: Binding<TranslationStrategy>,
        isEnabled: Bool = true,
        isHighFidelityAvailable: Bool = true,
        configuration: TranslationStrategySwitcherConfiguration = .init(),
        onUnavailableHighFidelitySelection: @escaping () -> Void = {}
    ) {
        self._selection = selection
        self.isEnabled = isEnabled
        self.isHighFidelityAvailable = isHighFidelityAvailable
        self.configuration = configuration
        self.onUnavailableHighFidelitySelection = onUnavailableHighFidelitySelection
    }

    public var body: some View {
        NativeTranslationStrategySwitcher(
            selection: $selection,
            isEnabled: isEnabled,
            isHighFidelityAvailable: isHighFidelityAvailable,
            configuration: configuration,
            onUnavailableHighFidelitySelection: onUnavailableHighFidelitySelection
        )
        .frame(width: configuration.width, height: configuration.height)
    }
}

struct NativeTranslationStrategySwitcher: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var environmentEnabled
    @Binding var selection: TranslationStrategy
    var isEnabled: Bool
    var isHighFidelityAvailable: Bool
    var configuration: TranslationStrategySwitcherConfiguration
    var onUnavailableHighFidelitySelection: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(control: self) }

    func makeUIView(context: Context) -> UISegmentedControl {
        let control = UISegmentedControl(items: TranslationStrategy.allCases.map(\.compactTitle))
        control.apportionsSegmentWidthsByContent = false
        control.addTarget(context.coordinator, action: #selector(Coordinator.selectionChanged(_:)), for: .valueChanged)
        update(control)
        return control
    }

    func updateUIView(_ control: UISegmentedControl, context: Context) {
        context.coordinator.control = self
        update(control)
    }

    private func update(_ control: UISegmentedControl) {
        let traits = UITraitCollection(userInterfaceStyle: colorScheme == .dark ? .dark : .light)
        let foreground = configuration.foregroundColor.resolvedColor(with: traits)
        let selectedForeground = configuration.selectedForegroundColor.resolvedColor(with: traits)
        let selectedTint = selection == .lowLatency ? configuration.lowTint : configuration.highTint
        control.selectedSegmentTintColor = selectedTint.resolvedColor(with: traits)
        control.tintColor = foreground
        let normal: [NSAttributedString.Key: Any] = [.foregroundColor: foreground]
        let selected: [NSAttributedString.Key: Any] = [.foregroundColor: selectedForeground]
        control.setTitleTextAttributes(normal, for: .normal)
        control.setTitleTextAttributes(selected, for: .selected)
        control.setTitleTextAttributes(normal, for: .highlighted)
        control.setTitleTextAttributes(selected, for: [.selected, .highlighted])
        for (index, strategy) in TranslationStrategy.allCases.enumerated() {
            control.setTitle(strategy.compactTitle, forSegmentAt: index)
            control.setEnabled(isEnabled && environmentEnabled, forSegmentAt: index)
        }
        control.isEnabled = isEnabled && environmentEnabled
        control.selectedSegmentIndex = TranslationStrategy.allCases.firstIndex(of: selection) ?? UISegmentedControl.noSegment
        control.accessibilityLabel = "Translation Strategy"
        control.accessibilityValue = selection.title
        control.accessibilityHint = isHighFidelityAvailable
            ? "The control switches between Low Latency and High Fidelity translation."
            : "High Fidelity is unavailable. Low Latency remains available."
        control.accessibilityIdentifier = "kaizosha.translation-strategy-switcher"
    }

    @MainActor
    final class Coordinator: NSObject {
        var control: NativeTranslationStrategySwitcher
        init(control: NativeTranslationStrategySwitcher) { self.control = control }

        @objc func selectionChanged(_ sender: UISegmentedControl) {
            let strategies = TranslationStrategy.allCases
            guard strategies.indices.contains(sender.selectedSegmentIndex) else { return }
            let strategy = strategies[sender.selectedSegmentIndex]
            guard control.isEnabled, sender.isEnabled else {
                sender.selectedSegmentIndex = strategies.firstIndex(of: control.selection) ?? UISegmentedControl.noSegment
                return
            }
            guard strategy != .highFidelity || control.isHighFidelityAvailable else {
                sender.selectedSegmentIndex = strategies.firstIndex(of: control.selection) ?? UISegmentedControl.noSegment
                control.onUnavailableHighFidelitySelection()
                return
            }
            control.selection = strategy
            sender.accessibilityValue = strategy.title
        }
    }
}
