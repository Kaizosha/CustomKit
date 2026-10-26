import SwiftUI
import UIKit

public struct UnlockTogetherConfiguration {
    public var lockedTitle: String
    public var unlockedTitle: String
    public var tint: UIColor

    public init(
        lockedTitle: String = "Unlock Together",
        unlockedTitle: String = "Together x You",
        tint: UIColor = .systemOrange
    ) {
        self.lockedTitle = lockedTitle
        self.unlockedTitle = unlockedTitle
        self.tint = tint
    }
}

/// Together's single-segment action control. The host owns purchase or navigation behavior.
public struct UnlockTogetherControl: View {
    private var isUnlocked: Bool
    private var configuration: UnlockTogetherConfiguration
    private var action: () -> Void

    public init(
        isUnlocked: Bool = false,
        configuration: UnlockTogetherConfiguration = .init(),
        action: @escaping () -> Void
    ) {
        self.isUnlocked = isUnlocked
        self.configuration = configuration
        self.action = action
    }

    public var body: some View {
        NativeUnlockTogetherControl(
            isUnlocked: isUnlocked,
            configuration: configuration,
            action: action
        )
    }
}

struct NativeUnlockTogetherControl: UIViewRepresentable {
    @Environment(\.isEnabled) private var isEnabled
    var isUnlocked: Bool
    var configuration: UnlockTogetherConfiguration
    var action: () -> Void

    func makeUIView(context: Context) -> UnlockSegmentedControl {
        let control = UnlockSegmentedControl(configuration: configuration)
        control.setContentHuggingPriority(.required, for: .horizontal)
        update(control)
        return control
    }

    func updateUIView(_ control: UnlockSegmentedControl, context: Context) {
        update(control)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UnlockSegmentedControl, context: Context) -> CGSize? {
        let size = uiView.intrinsicContentSize
        return CGSize(width: min(size.width, proposal.width ?? size.width), height: size.height)
    }

    private func update(_ control: UnlockSegmentedControl) {
        let title = isUnlocked ? configuration.unlockedTitle : configuration.lockedTitle
        control.action = action
        control.setTitle(title, forSegmentAt: 0)
        control.isUnlocked = isUnlocked
        control.glassTint = configuration.tint
        control.isEnabled = isEnabled
        control.accessibilityLabel = title
        control.accessibilityHint = isUnlocked ? "Open Together" : "Open subscription options"
        control.accessibilityIdentifier = "kaizosha.unlock-together"
    }
}

@MainActor
final class UnlockSegmentedControl: UISegmentedControl, UIGestureRecognizerDelegate {
    var action: () -> Void = {}
    var isUnlocked = false {
        didSet {
            guard oldValue != isUnlocked else { return }
            updateSelectedAppearance()
        }
    }
    var glassTint: UIColor {
        didSet {
            guard !oldValue.isEqual(glassTint) else { return }
            let glass = UIGlassEffect(style: .regular)
            glass.tintColor = glassTint
            selectedGlass.effect = glass
        }
    }
    private lazy var activationTap = UITapGestureRecognizer(target: self, action: #selector(activate))
    private let selectedGlass = UIVisualEffectView()
    private let selectedTitle = UILabel()
    private lazy var emptySelection = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }

    init(configuration: UnlockTogetherConfiguration) {
        glassTint = configuration.tint
        super.init(items: [configuration.lockedTitle])
        apportionsSegmentWidthsByContent = true
        selectedSegmentIndex = 0
        let glass = UIGlassEffect(style: .regular)
        glass.tintColor = glassTint
        selectedGlass.effect = glass
        selectedGlass.cornerConfiguration = .capsule()
        selectedGlass.isUserInteractionEnabled = false
        selectedGlass.accessibilityElementsHidden = true
        selectedTitle.text = configuration.lockedTitle
        selectedTitle.textAlignment = .center
        selectedTitle.textColor = .label
        selectedGlass.contentView.addSubview(selectedTitle)
        addSubview(selectedGlass)
        setBackgroundImage(emptySelection, for: .selected, barMetrics: .default)
        updateTitleAppearance()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) {
            (control: UnlockSegmentedControl, _: UITraitCollection) in
            control.updateTitleAppearance()
        }
        isAccessibilityElement = true
        accessibilityTraits = [.button, .selected]
        activationTap.cancelsTouchesInView = false
        activationTap.delegate = self
        addGestureRecognizer(activationTap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setTitle(_ title: String?, forSegmentAt segment: Int) {
        super.setTitle(title, forSegmentAt: segment)
        if segment == 0 { selectedTitle.text = title }
        invalidateIntrinsicContentSize()
    }

    private var titleFont: UIFont {
        let size = UIFont.preferredFont(forTextStyle: .subheadline, compatibleWith: traitCollection).pointSize
        return UIFont.monospacedSystemFont(ofSize: size, weight: .semibold)
    }

    private func updateTitleAppearance() {
        setTitleTextAttributes([.font: titleFont], for: .normal)
        setTitleTextAttributes([
            .font: titleFont,
            .foregroundColor: isUnlocked ? UIColor.label : UIColor.clear
        ], for: .selected)
        selectedTitle.font = titleFont
        invalidateIntrinsicContentSize()
    }

    private func updateSelectedAppearance() {
        if isUnlocked {
            selectedGlass.removeFromSuperview()
            setBackgroundImage(nil, for: .selected, barMetrics: .default)
        } else {
            addSubview(selectedGlass)
            setBackgroundImage(emptySelection, for: .selected, barMetrics: .default)
        }
        updateTitleAppearance()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isUnlocked else { return }
        selectedGlass.frame = bounds.insetBy(dx: 6, dy: 6)
        selectedTitle.frame = selectedGlass.bounds
        bringSubviewToFront(selectedGlass)
    }

    override var intrinsicContentSize: CGSize {
        let nativeSize = super.intrinsicContentSize
        let titleSize = (titleForSegment(at: 0) ?? "").size(withAttributes: [.font: titleFont])
        return CGSize(
            width: max(nativeSize.width, ceil(titleSize.width) + 32),
            height: max(nativeSize.height, max(44, ceil(titleFont.lineHeight) + 16))
        )
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gestureRecognizer === activationTap || otherGestureRecognizer === activationTap
    }

    override var canBecomeFirstResponder: Bool { true }
    override var keyCommands: [UIKeyCommand]? {
        [" ", "\r"].map { UIKeyCommand(input: $0, modifierFlags: [], action: #selector(activate)) }
    }
    override func accessibilityActivate() -> Bool {
        guard isEnabled else { return false }
        activate()
        return true
    }
    @objc func activate() {
        guard isEnabled else { return }
        action()
    }
}
