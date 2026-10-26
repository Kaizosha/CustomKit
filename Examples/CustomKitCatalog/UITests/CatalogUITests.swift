import XCTest

@MainActor
final class CatalogUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testEveryElementOpensCustomizationAndUsage() {
        let routes = ["logo", "launch", "together-start", "pinch-start", "skeleton-start", "liquid-list", "buttons", "button-neutral", "button-destructive", "button-reset", "button-success", "button-working", "switcher", "segments", "slider", "haptic-sheet", "made-by", "pull-clear", "playerkit", "captionkit", "sekaikit"]
        for route in routes {
            if route != routes.first { app.terminate(); app.launch() }
            open(route)
            let customize = app.buttons["experiment.customize"]
            XCTAssertTrue(customize.waitForExistence(timeout: 8), route)
            XCTAssertTrue(app.navigationBars.buttons["experiment.customize"].exists, route)
            XCTAssertFalse(app.buttons["experiment.code"].exists, route)
            XCTAssertFalse(app.staticTexts["This example is live. Try it, then open the controls to make it yours."].exists, route)
            attach(route)
            customize.tap()
            XCTAssertTrue(app.buttons["customize.done"].waitForExistence(timeout: 4), route)
            attach("\(route)-controls")
            let code = app.buttons["experiment.code"]
            reveal(code)
            code.tap()
            XCTAssertTrue(app.navigationBars["Use in your app"].waitForExistence(timeout: 4), route)
            XCTAssertTrue(app.buttons["Copy"].exists, route)
        }
    }

    func testIndividualButtonsAndLiveLabel() {
        for route in ["buttons", "button-neutral", "button-destructive", "button-reset", "button-success", "button-working"] {
            if route != "buttons" { app.terminate(); app.launch() }
            open(route)
            let button = app.buttons["button.element"]
            XCTAssertTrue(button.waitForExistence(timeout: 4), route)
            XCTAssertEqual(app.buttons.matching(identifier: "button.element").count, 1, route)
            XCTAssertFalse(app.staticTexts["1 clip in your queue."].exists)
            button.tap()
        }
        app.terminate(); app.launch()
        open("buttons")
        app.buttons["experiment.customize"].tap()
        let label = app.textFields["Label"]
        XCTAssertTrue(label.waitForExistence(timeout: 4))
        label.tap()
        let current = label.value as? String ?? ""
        label.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count) + "Open")
        app.buttons["customize.done"].tap()
        XCTAssertEqual(app.buttons["button.element"].label, "Open")
        attach("button-customized")
    }

    func testSwitcherAndSegments() {
        open("switcher")
        let toggle = app.switches.firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 4))
        XCTAssertEqual(toggle.value as? String, "1")
        toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.93, dy: 0.5)).tap()
        XCTAssertEqual(toggle.value as? String, "0")
        XCTAssertFalse(app.staticTexts["Where shall we go today?"].exists)
        app.terminate(); app.launch()
        open("segments")
        let original = app.segmentedControls.buttons["Original"]
        XCTAssertTrue(original.waitForExistence(timeout: 4))
        original.tap()
        XCTAssertTrue(original.isSelected)
    }

    func testStartRemainsStartAndCreditsSheet() {
        open("together-start")
        let play = app.buttons["Play"]
        XCTAssertTrue(play.waitForExistence(timeout: 6))
        play.tap()
        XCTAssertTrue(play.exists)
        XCTAssertFalse(app.staticTexts["Your next watch."].exists)
        attach("together-start-full")
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
        play.tap()
        XCTAssertTrue(app.buttons["Pause"].waitForExistence(timeout: 8))
        app.buttons["Pause"].tap()
        XCTAssertFalse(app.buttons["player.choose"].exists)
        attach("player-playing")
        app.terminate(); app.launch()
        open("captionkit")
        let caption = app.buttons["0:08, A little closer, in every language."]
        XCTAssertTrue(caption.waitForExistence(timeout: 4))
        caption.tap()
        XCTAssertTrue(caption.isSelected)
        attach("captions-seeked")
    }

    func testPullClearAndRestoreFromCustomization() {
        open("pull-clear")
        let conversation = app.descendants(matching: .any)["pull.conversation"].firstMatch
        XCTAssertTrue(conversation.waitForExistence(timeout: 4))
        let start = conversation.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.12))
        let end = conversation.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.75))
        start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)
        XCTAssertTrue(app.staticTexts["pull.empty"].waitForExistence(timeout: 5))
        start.press(forDuration: 0.1, thenDragTo: end, withVelocity: .slow, thenHoldForDuration: 0.1)
        XCTAssertTrue(app.staticTexts["pull.empty"].exists)
        XCTAssertFalse(app.buttons["Restore"].exists)
        attach("pull-empty")
        app.buttons["experiment.customize"].tap()
        let restore = app.buttons["Restore conversation"]
        reveal(restore)
        restore.tap()
        app.buttons["customize.done"].tap()
        XCTAssertTrue(app.staticTexts["Shall we take the long way home?"].exists)
    }

    func testLiveCustomizationAndNativeSheetDetents() {
        open("liquid-list")
        XCTAssertTrue(app.staticTexts["日本語"].exists)
        app.buttons["experiment.customize"].tap()
        let nativeNames = app.switches["Native language names"]
        XCTAssertTrue(nativeNames.waitForExistence(timeout: 4))
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
        for _ in 0..<12 {
            if row.exists && row.isHittable && row.frame.midY < app.frame.maxY - 120 { break }
            if row.exists && row.frame.midY < 120 { scroll.swipeDown() }
            else { scroll.swipeUp() }
        }
        XCTAssertTrue(row.exists && row.isHittable, "Missing route \(route)")
        row.tap()
    }

    private func reveal(_ element: XCUIElement) {
        for _ in 0..<8 {
            if element.exists && element.isHittable { return }
            let form = app.collectionViews.firstMatch
            if form.exists { form.swipeUp() }
            else { app.swipeUp() }
        }
        XCTAssertTrue(element.exists && element.isHittable)
    }

    private func attach(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
