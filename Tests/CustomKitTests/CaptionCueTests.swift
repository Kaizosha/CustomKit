import Testing
import CustomKit

@Test func captionUsesHalfOpenIntervals() {
    let first = CaptionCue(id: "first", start: 0, end: 4, text: "Hello")
    let next = CaptionCue(id: "next", start: 4, end: 8, text: "World")
    #expect(first.contains(0))
    #expect(first.contains(3.99))
    #expect(!first.contains(4))
    #expect(next.contains(4))
    #expect(!next.contains(.nan))
}

@Test func captionNormalizesInvalidInitialTiming() {
    let cue = CaptionCue(id: "invalid", start: .nan, end: -.infinity, text: "Hello")
    #expect(cue.start == 0)
    #expect(cue.end == 0)
}
