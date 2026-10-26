import Testing
@testable import CustomKit

@Test func pullMustCrossThresholdAndRelease() {
    var state = PullToClearState()
    state.update(distance: 139, isEmpty: false)
    let shortPull = state.release(isEmpty: false)
    #expect(!shortPull)
    state.update(distance: 140, isEmpty: false)
    let armedPull = state.release(isEmpty: false)
    #expect(armedPull)
    let repeatedRelease = state.release(isEmpty: false)
    #expect(!repeatedRelease)
}

@Test func reversingThePullDisarmsClear() {
    var state = PullToClearState()
    state.update(distance: 180, isEmpty: false)
    state.update(distance: 70, isEmpty: false)
    let release = state.release(isEmpty: false)
    #expect(!release)
}

@Test func emptyContentsAndCancelledPullNeverClear() {
    var state = PullToClearState()
    state.update(distance: 300, isEmpty: true)
    let emptyPull = state.release(isEmpty: true)
    #expect(!emptyPull)
    state.update(distance: 300, isEmpty: false)
    state.reset()
    let cancelledPull = state.release(isEmpty: false)
    #expect(!cancelledPull)
    state.update(distance: 300, isEmpty: false)
    let emptiedDuringPull = state.release(isEmpty: true)
    #expect(!emptiedDuringPull)
}

@Test func customThresholdAndInvalidDistance() {
    var state = PullToClearState(threshold: 200)
    state.update(distance: 180, isEmpty: false)
    let shortPull = state.release(isEmpty: false)
    #expect(!shortPull)
    state.update(distance: .infinity, isEmpty: false)
    let invalidPull = state.release(isEmpty: false)
    #expect(!invalidPull)
    state.update(distance: 200, isEmpty: false)
    let armedPull = state.release(isEmpty: false)
    #expect(armedPull)
}
