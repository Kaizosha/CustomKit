import SwiftUI

/// Plays the shared opening animation before presenting a reusable start screen.
public struct StartExperience: View {
    private enum Phase { case opening, welcome }

    public var configuration: StartConfiguration
    public var launch: LaunchConfiguration
    private let onPrimaryAction: () -> Void
    private let onControls: (() -> Void)?
    @State private var phase = Phase.opening

    public init(
        configuration: StartConfiguration,
        launch: LaunchConfiguration = .init(),
        onPrimaryAction: @escaping () -> Void,
        onControls: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.launch = launch
        self.onPrimaryAction = onPrimaryAction
        self.onControls = onControls
    }

    public var body: some View {
        switch phase {
        case .opening:
            LaunchAnimation(configuration: launch) { phase = .welcome }
        case .welcome:
            StartTemplate(configuration: configuration, onPrimaryAction: onPrimaryAction, onControls: onControls)
        }
    }
}
