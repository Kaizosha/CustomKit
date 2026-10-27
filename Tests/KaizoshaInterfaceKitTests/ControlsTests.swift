import SwiftUI
import Testing
import UIKit
@testable import KaizoshaInterfaceKit

@Suite("Reusable Together controls")
@MainActor
struct ControlsTests {
    @Test("Unlock action accepts repeated activation and respects disabled state")
    func repeatedUnlockActivation() {
        let control = UnlockSegmentedControl(configuration: .init())
        var activations = 0
        control.action = { activations += 1 }
        #expect(control.accessibilityActivate())
        #expect(control.accessibilityActivate())
        #expect(activations == 2)
        control.isEnabled = false
        #expect(!control.accessibilityActivate())
        control.activate()
        #expect(activations == 2)
        #expect(control.selectedSegmentIndex == 0)
        #expect(control.keyCommands?.map(\.input) == [" ", "\r"])
    }

    @Test("Long customized titles retain intrinsic room and a 44-point target")
    func customizedUnlockTitle() {
        let control = UnlockSegmentedControl(configuration: .init())
        let initialWidth = control.intrinsicContentSize.width
        control.setTitle("Unlock every Together feature for your library", forSegmentAt: 0)
        #expect(control.intrinsicContentSize.width > initialWidth)
        #expect(control.intrinsicContentSize.height >= 44)
        control.isUnlocked = true
        control.setTitle("Together x You", forSegmentAt: 0)
        #expect(control.titleForSegment(at: 0) == "Together x You")
        #expect(control.accessibilityActivate())
    }

    @Test("Available selections update the host binding")
    func strategySelectionUpdatesHost() {
        var selection = TranslationStrategy.lowLatency
        let coordinator = makeSwitcher(selection: .init(get: { selection }, set: { selection = $0 })).makeCoordinator()
        let sender = UISegmentedControl(items: ["Low", "High"])
        sender.selectedSegmentIndex = 1
        coordinator.selectionChanged(sender)
        #expect(selection == .highFidelity)
        #expect(sender.accessibilityValue == "High Fidelity")
        sender.selectedSegmentIndex = 0
        coordinator.selectionChanged(sender)
        #expect(selection == .lowLatency)
        #expect(sender.accessibilityValue == "Low Latency")
    }

    @Test("Unavailable High reverts native selection and informs the host")
    func unavailableSelectionReverts() {
        var selection = TranslationStrategy.lowLatency
        var refusals = 0
        let coordinator = makeSwitcher(
            selection: .init(get: { selection }, set: { selection = $0 }),
            isHighFidelityAvailable: false,
            onUnavailable: { refusals += 1 }
        ).makeCoordinator()
        let sender = UISegmentedControl(items: ["Low", "High"])
        sender.selectedSegmentIndex = 1
        coordinator.selectionChanged(sender)
        #expect(selection == .lowLatency)
        #expect(sender.selectedSegmentIndex == 0)
        #expect(refusals == 1)
    }

    @Test("Disabled and invalid selections have no host effect")
    func disabledAndInvalidSelection() {
        var selection = TranslationStrategy.lowLatency
        var refusals = 0
        let coordinator = makeSwitcher(
            selection: .init(get: { selection }, set: { selection = $0 }),
            isEnabled: false,
            isHighFidelityAvailable: false,
            onUnavailable: { refusals += 1 }
        ).makeCoordinator()
        let sender = UISegmentedControl(items: ["Low", "High"])
        sender.selectedSegmentIndex = 1
        coordinator.selectionChanged(sender)
        #expect(selection == .lowLatency)
        #expect(sender.selectedSegmentIndex == 0)
        #expect(refusals == 0)
        sender.selectedSegmentIndex = UISegmentedControl.noSegment
        coordinator.selectionChanged(sender)
        #expect(selection == .lowLatency)
        #expect(refusals == 0)
    }

    private func makeSwitcher(
        selection: Binding<TranslationStrategy>,
        isEnabled: Bool = true,
        isHighFidelityAvailable: Bool = true,
        onUnavailable: @escaping () -> Void = {}
    ) -> NativeTranslationStrategySwitcher {
        .init(
            selection: selection,
            isEnabled: isEnabled,
            isHighFidelityAvailable: isHighFidelityAvailable,
            configuration: .init(),
            onUnavailableHighFidelitySelection: onUnavailable
        )
    }
}
