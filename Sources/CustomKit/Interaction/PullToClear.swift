import SwiftUI

public struct PullToClear<Content: View>: View {
    private enum Contact {
        case waiting
        case rejected
        case tracking(origin: CGFloat)
    }

    private let isEmpty: Bool
    private let threshold: CGFloat
    private let hapticsEnabled: Bool
    private let onClear: () -> Void
    private let content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var state: PullToClearState
    @State private var contact = Contact.waiting
    @State private var isScrollAtTop = true
    @State private var feedbackTrigger = 0
    @GestureState private var isDragging = false

    public init(
        isEmpty: Bool,
        threshold: CGFloat = 140,
        hapticsEnabled: Bool = true,
        onClear: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isEmpty = isEmpty
        self.threshold = threshold
        self.hapticsEnabled = hapticsEnabled
        self.onClear = onClear
        self.content = content()
        _state = State(initialValue: PullToClearState(threshold: threshold))
    }

    public var body: some View {
        ScrollView {
            content
                .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.always)
        .onScrollGeometryChange(for: Bool.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top <= 1
        } action: { _, atTop in
            isScrollAtTop = atTop
        }
        .simultaneousGesture(pullGesture)
        .overlay(alignment: .top) {
            if state.distance > 48 {
                Text(isEmpty ? "Nothing to clear" : state.phase == .armed ? "Release to clear" : "Pull to clear")
                    .textCase(.uppercase)
                    .font(.footnote.monospaced())
                    .foregroundStyle(state.phase == .armed ? .primary : .secondary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: .capsule)
                    .scaleEffect(state.phase == .armed && !reduceMotion ? 1.06 : 1)
                    .animation(reduceMotion ? nil : .snappy(duration: 0.18), value: state.phase)
                    .padding(.top, 12)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: feedbackTrigger)
        .accessibilityAction(named: Text("Clear contents")) {
            if !isEmpty { onClear() }
        }
        .onChange(of: isEmpty) { _, _ in cancelContact() }
        .onChange(of: isDragging) { _, active in
            if !active { cancelContact() }
        }
        .onChange(of: threshold) { _, value in
            state = PullToClearState(threshold: value)
            contact = .waiting
        }
        .onChange(of: scenePhase) { _, value in
            if value != .active { cancelContact() }
        }
        .onDisappear { cancelContact() }
    }

    private var pullGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($isDragging) { _, active, _ in active = true }
            .onChanged { value in
                let translation = value.translation
                switch contact {
                case .rejected:
                    return
                case .waiting:
                    guard translation.height > abs(translation.width) * 1.5 else {
                        contact = .rejected
                        return
                    }
                    guard isScrollAtTop else { return }
                    contact = .tracking(origin: translation.height < 20 ? 0 : translation.height)
                case .tracking:
                    break
                }
                guard case .tracking(let origin) = contact else { return }
                let wasArmed = state.phase == .armed
                state.update(distance: translation.height - origin, isEmpty: isEmpty)
                if state.phase == .armed && !wasArmed && hapticsEnabled {
                    feedbackTrigger += 1
                }
            }
            .onEnded { _ in
                let shouldClear = state.release(isEmpty: isEmpty)
                contact = .waiting
                if shouldClear { onClear() }
            }
    }

    private func cancelContact() {
        state.reset()
        contact = .waiting
    }
}
