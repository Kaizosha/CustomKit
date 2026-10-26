import Foundation

public struct CaptionCue: Identifiable, Equatable, Sendable {
    public let id: String
    public let start: Double
    public let end: Double
    public var text: String
    public var translation: String

    public init(id: String, start: Double, end: Double, text: String, translation: String = "") {
        self.id = id
        self.start = start.isFinite ? max(0, start) : 0
        self.end = end.isFinite ? max(self.start, end) : self.start
        self.text = text
        self.translation = translation
    }

    public func contains(_ position: Double) -> Bool {
        position >= start && position < end
    }
}
