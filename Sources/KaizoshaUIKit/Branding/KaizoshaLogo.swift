import SwiftUI

/// The canonical Kaizōsha mark, with Together's direct drag, device lighting,
/// release-velocity spring, and accumulated-travel haptics.
public struct KaizoshaLogo: View {
    public var configuration: LogoConfiguration
    private let onOpenCredits: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.scenePhase) private var scenePhase
    @GestureState private var isDragging = false
    @State private var lighting = KaizoshaLogoLightingState()
    @State private var haptics = KaizoshaLogoHapticDriver()
    @State private var translation = CGSize.zero
    @State private var velocity = CGSize.zero
    @State private var isVisible = false

    public init(
        configuration: LogoConfiguration = .init(),
        onOpenCredits: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.onOpenCredits = onOpenCredits
    }

    public var body: some View {
        let presentation = KaizoshaLogoInteractionPolicy.presentation(
            translation: translation,
            velocity: velocity,
            reduceMotion: reduceMotion
        )
        let size = configuration.size.isFinite ? max(24, configuration.size) : 160
        let refraction = configuration.refraction.isFinite ? min(max(configuration.refraction, 0), 2) : 1

        Group {
            if let onOpenCredits {
                mark(presentation: presentation, refraction: refraction)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.6, maximumDistance: 10)
                            .onEnded { _ in
                                if configuration.hapticsEnabled { haptics.creditsOpened() }
                                onOpenCredits()
                            }
                    )
                    .accessibilityActions {
                        Button("Open Credits", action: onOpenCredits)
                    }
            } else {
                mark(presentation: presentation, refraction: refraction)
            }
        }
        .scaleEffect(size / KaizoshaLogoArtworkLayout.artworkWidth)
        .frame(width: size, height: size * 151 / 160)
        .onAppear {
            isVisible = true
            synchronizeLighting()
        }
        .onDisappear {
            isVisible = false
            lighting.stop()
            haptics.invalidate()
            translation = .zero
            velocity = .zero
        }
        .onChange(of: scenePhase) { _, phase in
            synchronizeLighting()
            if phase != .active { cancelDrag() }
        }
        .onChange(of: reduceMotion) { _, _ in synchronizeLighting() }
        .onChange(of: reduceTransparency) { _, _ in synchronizeLighting() }
        .onChange(of: configuration.motionEnabled) { _, _ in synchronizeLighting() }
        .onChange(of: configuration.interactive) { _, enabled in
            if !enabled { cancelDrag() }
        }
        .onChange(of: configuration.hapticsEnabled) { _, enabled in
            if !enabled { haptics.invalidate() }
        }
        .onChange(of: isDragging) { _, active in
            if !active && translation != .zero { cancelDrag() }
        }
    }

    private func mark(presentation: KaizoshaLogoInteractionPresentation, refraction: CGFloat) -> some View {
        KaizoshaGlassMark(
            lightDirection: configuration.motionEnabled ? lighting.direction : configuration.lightDirection,
            interaction: presentation,
            refraction: refraction,
            reduceMotion: reduceMotion,
            reduceTransparency: reduceTransparency
        )
        .scaleEffect(x: presentation.scaleX, y: presentation.scaleY)
        .rotation3DEffect(
            .degrees(presentation.tiltDegrees),
            axis: (x: -presentation.direction.dy * 0.42, y: presentation.direction.dx, z: 0),
            perspective: 0.32
        )
        .offset(presentation.offset)
        .contentShape(Rectangle())
        .gesture(drag, isEnabled: configuration.interactive)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Kaizōsha")
        .accessibilityAddTraits(.isImage)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .global)
            .updating($isDragging) { _, active, _ in active = true }
            .onChanged { value in
                if configuration.hapticsEnabled {
                    haptics.dragChanged(translation: value.translation, velocity: value.velocity, location: value.location)
                }
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    translation = value.translation
                    velocity = value.velocity
                }
            }
            .onEnded { value in
                if configuration.hapticsEnabled {
                    haptics.dragEnded(
                        translation: value.translation,
                        velocity: value.velocity,
                        location: value.location,
                        completion: KaizoshaLogoDragPolicy.magnitude(of: value.translation)
                            >= KaizoshaLogoInteractionPolicy.minimumReleaseFeedbackDistance
                            ? .returnedToAnchor : .cancelled
                    )
                }
                settle(translation: value.translation, velocity: value.velocity)
            }
    }

    private func cancelDrag() {
        haptics.cancelDrag()
        settle(translation: translation, velocity: velocity)
    }

    private func settle(translation: CGSize, velocity: CGSize) {
        let animation = reduceMotion
            ? Animation.easeOut(duration: 0.16)
            : Animation.interpolatingSpring(
                mass: 1,
                stiffness: 155,
                damping: 12.5,
                initialVelocity: KaizoshaLogoDragPolicy.springInitialVelocity(translation: translation, velocity: velocity)
            )
        withAnimation(animation) {
            self.translation = .zero
            self.velocity = .zero
        }
    }

    private func synchronizeLighting() {
        if isVisible && scenePhase == .active && configuration.motionEnabled && !reduceMotion && !reduceTransparency {
            lighting.start()
        } else {
            lighting.stop()
        }
    }
}
