//
//  SliderRepresentable.swift
//  CustomKit
//
//  Copyright 2026 Kaizōsha. Developed by Kaizō Konpaku.
//

import SwiftUI
import UIKit

@MainActor
struct SliderRepresentable: UIViewRepresentable {
    @Binding var value: Double
    let stops: [Double]
    let style: SliderStyle
    let direction: SliderResolvedDirection
    let isEnabled: Bool
    let reduceMotion: Bool
    let accessibilityLabel: String
    let accessibilityValue: (Double) -> String
    let onEditingChanged: (Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> SliderControl {
        let control = SliderControl()
        context.coordinator.connect(to: control)
        update(control, coordinator: context.coordinator)
        return control
    }

    func updateUIView(_ control: SliderControl, context: Context) {
        context.coordinator.parent = self
        context.coordinator.connect(to: control)
        update(control, coordinator: context.coordinator)
    }

    static func dismantleUIView(
        _ control: SliderControl,
        coordinator: Coordinator
    ) {
        control.cancelActiveTracking()
        control.removeTarget(coordinator, action: nil, for: .allEvents)
        coordinator.disconnect()
    }

    private func update(
        _ control: SliderControl,
        coordinator: Coordinator
    ) {
        control.configure(
            stops: stops,
            style: style,
            direction: direction,
            isEnabled: isEnabled,
            reduceMotion: reduceMotion,
            accessibilityLabel: accessibilityLabel,
            accessibilityValue: accessibilityValue
        )

        if !control.isTracking && !control.hasActiveTracking {
            control.value = value
        }
    }

    @MainActor
    final class Coordinator: NSObject {
        var parent: SliderRepresentable
        private weak var control: SliderControl?

        init(parent: SliderRepresentable) {
            self.parent = parent
        }

        func connect(to control: SliderControl) {
            guard self.control !== control else {
                return
            }

            self.control?.removeTarget(self, action: nil, for: .allEvents)
            self.control = control
            control.addTarget(
                self,
                action: #selector(editingDidBegin(_:)),
                for: .editingDidBegin
            )
            control.addTarget(
                self,
                action: #selector(valueChanged(_:)),
                for: .valueChanged
            )
            control.addTarget(
                self,
                action: #selector(editingDidEnd(_:)),
                for: [.editingDidEnd, .editingDidEndOnExit]
            )
        }

        func disconnect() {
            control = nil
        }

        @objc private func editingDidBegin(_ sender: SliderControl) {
            parent.onEditingChanged(true)
        }

        @objc private func valueChanged(_ sender: SliderControl) {
            parent.value = sender.value
        }

        @objc private func editingDidEnd(_ sender: SliderControl) {
            parent.value = sender.value
            parent.onEditingChanged(false)
        }
    }
}

@MainActor
final class SliderControl: UIControl {
    var value: Double {
        get { stops[selectedIndex] }
        set {
            selectedIndex = SliderMath.nearestIndex(to: newValue, in: stops)
            updatePresentation()
        }
    }

    private(set) var stops: [Double] = [0]
    private(set) var hasActiveTracking = false
    private(set) var resolvedStyle = ResolvedSliderStyle(.init())
    private(set) var resolvedDirection = SliderResolvedDirection.leftToRight
    var eventObserver: ((UIControl.Event) -> Void)?

    private let trackView = UIView()
    private let fillView = UIView()
    private let knobView = UIView()
    private var stopViews: [UIView] = []
    private var selectedIndex = 0
    private var initialTouchPoint = CGPoint.zero
    private var lastTouchPoint = CGPoint.zero
    private var trackingPosition: CGFloat = 0
    private var ignoresTrackingUntilTouchEnds = false
    private var reduceMotion = false
    private var valueDescription: (Double) -> String = { String(describing: $0) }
    private let feedbackGenerator = UISelectionFeedbackGenerator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: resolvedStyle.controlHeight)
    }

    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                if isTracking {
                    ignoresTrackingUntilTouchEnds = true
                }
                cancelActiveTracking()
            }
            updateAccessibilityTraits()
            alpha = isEnabled ? 1 : 0.45
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let railHeight = hasActiveTracking
            ? resolvedStyle.activeRailHeight
            : resolvedStyle.restingRailHeight
        let railFrame = CGRect(
            x: 0,
            y: (bounds.height - railHeight) / 2,
            width: bounds.width,
            height: railHeight
        )
        trackView.frame = railFrame
        trackView.layer.cornerRadius = railHeight / 2

        let knobCenterX = SliderMath.position(
            for: selectedIndex,
            count: stops.count,
            width: railFrame.width,
            railHeight: railHeight,
            direction: resolvedDirection
        )
        fillView.frame = SliderMath.fillFrame(
            knobCenterX: knobCenterX,
            railWidth: railFrame.width,
            railHeight: railHeight,
            direction: resolvedDirection
        )
        fillView.layer.cornerRadius = railHeight / 2

        for index in stopViews.indices {
            let centerX = SliderMath.position(
                for: index,
                count: stops.count,
                width: railFrame.width,
                railHeight: railHeight,
                direction: resolvedDirection
            )
            let diameter = min(resolvedStyle.stopDiameter, railHeight)
            stopViews[index].frame = CGRect(
                x: centerX - (diameter / 2),
                y: (railHeight - diameter) / 2,
                width: diameter,
                height: diameter
            )
            stopViews[index].layer.cornerRadius = diameter / 2
        }

        let knobDiameter = hasActiveTracking
            ? resolvedStyle.activeKnobDiameter
            : resolvedStyle.restingKnobDiameter
        knobView.frame = CGRect(
            x: knobCenterX - (knobDiameter / 2),
            y: (bounds.height - knobDiameter) / 2,
            width: knobDiameter,
            height: knobDiameter
        )
        knobView.layer.cornerRadius = knobDiameter / 2
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard
            isEnabled,
            stops.count > 1,
            !hasActiveTracking,
            !ignoresTrackingUntilTouchEnds
        else {
            return false
        }

        initialTouchPoint = touch.location(in: self)
        lastTouchPoint = initialTouchPoint
        trackingPosition = CGFloat(selectedIndex)
        feedbackGenerator.prepare()
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard !ignoresTrackingUntilTouchEnds else {
            return true
        }

        guard isEnabled, stops.count > 1 else {
            return false
        }

        let point = touch.location(in: self)
        let horizontalDelta = point.x - initialTouchPoint.x
        let verticalDelta = point.y - initialTouchPoint.y

        if !hasActiveTracking {
            guard hypot(horizontalDelta, verticalDelta)
                >= SliderMath.dragActivationDistance
            else {
                return true
            }

            hasActiveTracking = true
            animateGeometryChange()
            emit(.editingDidBegin)
        }

        trackingPosition = SliderMath.adjustedPosition(
            from: trackingPosition,
            horizontalTranslation: point.x - lastTouchPoint.x,
            width: bounds.width,
            railHeight: resolvedStyle.activeRailHeight,
            count: stops.count,
            sensitivity: SliderMath.sensitivity(
                verticalDistance: verticalDelta,
                force: touch.force,
                maximumPossibleForce: touch.maximumPossibleForce
            ),
            direction: resolvedDirection
        )
        lastTouchPoint = point
        let nextIndex = SliderMath.index(
            for: trackingPosition,
            count: stops.count
        )

        guard nextIndex != selectedIndex else {
            return true
        }

        selectedIndex = nextIndex
        updatePresentation()
        if resolvedStyle.source.hapticsEnabled {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
        emit(.valueChanged)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if let touch, hasActiveTracking, !ignoresTrackingUntilTouchEnds {
            _ = continueTracking(touch, with: event)
        }
        super.endTracking(touch, with: event)
        finishTracking(cancelled: false)
        ignoresTrackingUntilTouchEnds = false
    }

    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        finishTracking(cancelled: true)
        ignoresTrackingUntilTouchEnds = false
    }

    override func accessibilityIncrement() {
        adjustAccessibilityValue(by: 1)
    }

    override func accessibilityDecrement() {
        adjustAccessibilityValue(by: -1)
    }

    func configure(
        stops newStops: [Double],
        style: SliderStyle,
        direction: SliderResolvedDirection,
        isEnabled: Bool,
        reduceMotion: Bool,
        accessibilityLabel: String,
        accessibilityValue: @escaping (Double) -> String
    ) {
        if stops != newStops || resolvedDirection != direction {
            if isTracking {
                ignoresTrackingUntilTouchEnds = true
            }
            cancelActiveTracking()
        }

        let previousValue = value
        stops = newStops.isEmpty ? [previousValue] : newStops
        selectedIndex = SliderMath.nearestIndex(to: previousValue, in: stops)

        resolvedStyle = ResolvedSliderStyle(style)
        resolvedDirection = direction
        self.reduceMotion = reduceMotion
        valueDescription = accessibilityValue
        self.accessibilityLabel = accessibilityLabel
        self.isEnabled = isEnabled

        rebuildStopsIfNeeded()
        applyAppearance()
        updateAccessibilityTraits()
        invalidateIntrinsicContentSize()
        updatePresentation()
    }

    func cancelActiveTracking() {
        finishTracking(cancelled: true)
    }

    private func configureView() {
        isAccessibilityElement = true
        clipsToBounds = false

        trackView.isUserInteractionEnabled = false
        trackView.clipsToBounds = true

        fillView.isUserInteractionEnabled = false
        trackView.addSubview(fillView)
        addSubview(trackView)

        knobView.isUserInteractionEnabled = false
        addSubview(knobView)

        rebuildStopsIfNeeded()
        applyAppearance()
        updateAccessibilityTraits()
        updatePresentation()

        registerForTraitChanges(
            [UITraitUserInterfaceStyle.self, UITraitAccessibilityContrast.self]
        ) { (control: SliderControl, _) in
            control.applyAppearance()
        }
    }

    private func rebuildStopsIfNeeded() {
        guard stopViews.count != stops.count else {
            return
        }

        stopViews.forEach { $0.removeFromSuperview() }
        stopViews = stops.map { _ in
            let stop = UIView()
            stop.isUserInteractionEnabled = false
            trackView.addSubview(stop)
            return stop
        }
    }

    private func applyAppearance() {
        trackView.backgroundColor = UIColor(resolvedStyle.source.trackColor)
        fillView.backgroundColor = UIColor(resolvedStyle.source.fillColor)
        knobView.backgroundColor = UIColor(resolvedStyle.source.knobColor)
        knobView.layer.shadowColor = UIColor(
            resolvedStyle.source.knobShadowColor
        ).cgColor
        knobView.layer.shadowOpacity = 1
        knobView.layer.shadowRadius = resolvedStyle.knobShadowRadius
        knobView.layer.shadowOffset = resolvedStyle.knobShadowOffset
    }

    private func updatePresentation() {
        accessibilityValue = valueDescription(value)

        for index in stopViews.indices {
            stopViews[index].backgroundColor = UIColor(
                index <= selectedIndex
                    ? resolvedStyle.source.passedStopColor
                    : resolvedStyle.source.remainingStopColor
            )
        }

        setNeedsLayout()
    }

    private func updateAccessibilityTraits() {
        var traits: UIAccessibilityTraits = stops.count > 1
            ? [.adjustable]
            : [.staticText]
        if !isEnabled {
            traits.insert(.notEnabled)
        }
        accessibilityTraits = traits
    }

    private func adjustAccessibilityValue(by offset: Int) {
        guard isEnabled, stops.count > 1 else {
            return
        }

        let nextIndex = min(max(selectedIndex + offset, 0), stops.count - 1)
        guard nextIndex != selectedIndex else {
            return
        }

        emit(.editingDidBegin)
        selectedIndex = nextIndex
        updatePresentation()
        if resolvedStyle.source.hapticsEnabled {
            feedbackGenerator.selectionChanged()
            feedbackGenerator.prepare()
        }
        emit(.valueChanged)
        emit(.editingDidEnd)
    }

    private func finishTracking(cancelled: Bool) {
        guard hasActiveTracking else {
            return
        }

        hasActiveTracking = false
        animateGeometryChange()
        emit(cancelled ? .editingDidEndOnExit : .editingDidEnd)
    }

    private func emit(_ event: UIControl.Event) {
        eventObserver?(event)
        sendActions(for: event)
    }

    private func animateGeometryChange() {
        let changes = {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        guard !reduceMotion, resolvedStyle.animationDuration > 0 else {
            changes()
            return
        }

        UIView.animate(
            withDuration: resolvedStyle.animationDuration,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: changes
        )
    }
}
