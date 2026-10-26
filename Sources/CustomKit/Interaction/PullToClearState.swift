import CoreGraphics

struct PullToClearState: Equatable {
    enum Phase: Equatable {
        case idle
        case tracking
        case armed
    }

    let threshold: CGFloat
    private(set) var phase = Phase.idle
    private(set) var distance: CGFloat = 0

    init(threshold: CGFloat = 140) {
        self.threshold = threshold.isFinite ? max(48, threshold) : 140
    }

    mutating func update(distance: CGFloat, isEmpty: Bool) {
        self.distance = distance.isFinite ? max(0, distance) : 0
        phase = !isEmpty && self.distance >= threshold ? .armed : .tracking
    }

    mutating func release(isEmpty: Bool) -> Bool {
        let shouldClear = phase == .armed && !isEmpty
        reset()
        return shouldClear
    }

    mutating func reset() {
        phase = .idle
        distance = 0
    }
}
