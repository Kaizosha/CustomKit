import XCTest

@MainActor
final class CatalogUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testEveryTemplateOpensControlsAndUsage() {
        let routes = ["logo", "launch", "together-start", "pinch-start", "skeleton-start", "liquid-list", "buttons", "switcher", "segments", "slider", "haptic-sheet", "made-by", "pull-clear", "playerkit", "captionkit", "sekaikit"]
        for route in routes {
            if route != routes.first { app.terminate(); app.launch() }
            open(route)
            let customize = app.buttons["experiment.customize"]
            XCTAssertTrue(customize.waitForExistence(timeout: 8), route)
            attach(route)
            customize.tap()
            let done = app.buttons["customize.done"]
            XCTAssertTrue(done.waitForExistence(timeout: 4), "Missing controls for \(route)")
            attach("\(route)-controls")
            done.tap()
            app.buttons["experiment.code"].tap()
            XCTAssertTrue(app.navigationBars["Use in your app"].waitForExistence(timeout: 4), route)
            XCTAssertTrue(app.buttons["Copy"].exists)
            app.buttons["Done"].tap()
        }
    }

    func testQueueActionsAndReadingSwitcher() {
        open("buttons")
        app.buttons["Add clip"].tap()
        XCTAssertTrue(app.staticTexts["2 clips in your queue."].exists)
        app.buttons["Export captions"].tap()
        XCTAssertTrue(app.staticTexts["Ready to keep."].exists)
        app.buttons["Clear queue"].tap()
        XCTAssertTrue(app.staticTexts["0 clips in your queue."].exists)
        XCTAssertFalse(app.buttons["Clear queue"].isEnabled)
        app.terminate(); app.launch()
        open("switcher")
        XCTAssertTrue(app.staticTexts["Where shall we go today?"].exists)
        app.switches.firstMatch.tap()
        XCTAssertFalse(app.staticTexts["Where shall we go today?"].exists)
    }

    func testStartActionAndCreditsSheet() {
        open("together-start")
        let play = app.buttons["Play"]
        if !play.isHittable { app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(play.waitForExistence(timeout: 4))
        play.tap()
        XCTAssertTrue(app.staticTexts["Your next watch."].waitForExistence(timeout: 4))
        app.terminate(); app.launch()
        open("made-by")
        app.buttons["credits.open"].tap()
        XCTAssertTrue(app.staticTexts["Made by Kaizōsha."].waitForExistence(timeout: 4))
        attach("credits-full")
        app.buttons["Close credits"].tap()
    }

    func testRealPlayerAndCaptionSeeking() {
        open("playerkit")
        let play = app.buttons["Play"]
        XCTAssertTrue(play.waitForExistence(timeout: 12))
        if !play.isHittable { app.scrollViews.firstMatch.swipeUp() }
        play.tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 8))
        app.buttons["Pause"].tap()
        attach("player-playing")
        app.terminate(); app.launch()
        open("captionkit")
        let position = app.sliders["Playback position"]
        if !position.isHittable { app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(position.waitForExistence(timeout: 4))
        position.adjust(toNormalizedSliderPosition: 0.6)
        attach("captions-seeked")
    }

    func testPullClearAndEmptyState() {
        open("pull-clear")
        let conversation = app.descendants(matching: .any)["pull.conversation"].firstMatch
        XCTAssertTrue(conversation.waitForExistence(timeout: 4))
        let start = conversation.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        let end = conversation.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95))
        start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)
        XCTAssertTrue(app.staticTexts["0 messages · 1 clears"].waitForExistence(timeout: 5))
        start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)
        XCTAssertTrue(app.staticTexts["0 messages · 1 clears"].exists)
        attach("pull-empty")
        app.buttons["Restore"].tap()
        XCTAssertTrue(app.staticTexts["3 messages · 1 clears"].exists)
    }

    func testLiveCustomizationAndNativeSheetDetents() {
        open("liquid-list")
        XCTAssertTrue(app.staticTexts["日本語"].exists)
        app.buttons["experiment.customize"].tap()
        let nativeNames = app.switches["Native language names"]
        attach("customize-before-toggle")
        nativeNames.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        XCTAssertEqual(nativeNames.value as? String, "0")
        attach("customize-without-native-names")
        app.buttons["customize.done"].tap()
        XCTAssertTrue(app.staticTexts["日本語"].waitForNonExistence(timeout: 4))
        app.terminate(); app.launch()
        open("haptic-sheet")
        app.buttons["sheet.open"].tap()
        let navigationBar = app.navigationBars["Reading controls"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 4))
        let originalTop = navigationBar.frame.minY
        let handle = navigationBar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: -0.12))
        let expanded = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        handle.press(forDuration: 0.15, thenDragTo: expanded)
        XCTAssertLessThan(navigationBar.frame.minY, originalTop - 80)
        attach("sheet-expanded")
        app.buttons["Done"].tap()
    }

    private func open(_ route: String) {
        let row = app.buttons["catalog.\(route)"]
        let scroll = app.scrollViews.firstMatch
        for _ in 0..<10 {
            if row.exists && row.isHittable && row.frame.midY < app.frame.maxY - 180 { break }
            if row.exists && row.frame.midY < 120 { scroll.swipeDown() }
            else { scroll.swipeUp() }
        }
        XCTAssertTrue(row.exists && row.isHittable, "Missing route \(route)")
        row.tap()
    }

    private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
