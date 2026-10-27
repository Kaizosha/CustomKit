import XCTest

@MainActor
final class ComponentUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testEveryComponentHasCustomizationResetAndImportCode() {
        let ids = ["made-by-kaizosha", "unlock-together", "translation-pill", "language-switcher", "strategy-switcher", "masonry-layout"]
        for id in ids {
            app.buttons["catalog.\(id)"].tap()
            XCTAssertTrue(app.buttons["component.customize"].waitForExistence(timeout: 4))
            attach(id)
            app.buttons["component.customize"].tap()
            XCTAssertTrue(app.navigationBars["Customize"].waitForExistence(timeout: 4))
            attach("\(id)-customization")
            reveal(app.buttons["component.reset"])
            app.buttons["component.reset"].tap()
            reveal(app.buttons["component.code"])
            app.buttons["component.code"].tap()
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "import KaizoshaInterfaceKit")).firstMatch.exists)
            app.buttons["Copy"].tap()
            XCTAssertTrue(app.buttons["Copied"].exists)
            app.navigationBars["Use in your app"].buttons["Customize"].tap()
            app.buttons["customize.done"].tap()
            app.navigationBars.buttons.element(boundBy: 0).tap()
            XCTAssertTrue(app.navigationBars["KaizoshaInterfaceKit"].waitForExistence(timeout: 4))
        }
    }

    func testCreditsPreserveTogetherAndAcceptCustomTitle() {
        app.buttons["catalog.made-by-kaizosha"].tap()
        app.buttons["credits.open"].tap()
        XCTAssertTrue(app.staticTexts["Made by Kaizōsha."].waitForExistence(timeout: 4))
        XCTAssertTrue(app.descendants(matching: .any)["credits.purpose"].firstMatch.exists)
        attach("made-by-kaizosha-sheet")
        app.buttons["credits.close"].tap()
        app.buttons["component.customize"].tap()
        let title = app.textFields["Title"]
        XCTAssertTrue(title.waitForExistence(timeout: 4))
        title.tap()
        title.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 30) + "Made for Kaizōsha.")
        app.buttons["customize.done"].tap()
        app.buttons["credits.open"].tap()
        XCTAssertTrue(app.staticTexts["Made for Kaizōsha."].waitForExistence(timeout: 4))
        app.buttons["credits.close"].tap()
    }

    func testNativeSelectorsAndUnavailableHigh() {
        app.buttons["catalog.language-switcher"].tap()
        let language = app.segmentedControls.firstMatch
        XCTAssertTrue(language.waitForExistence(timeout: 4))
        language.buttons["Translate"].tap()
        XCTAssertTrue(language.buttons["Translate"].isSelected)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["catalog.strategy-switcher"].tap()
        let strategy = app.segmentedControls.firstMatch
        XCTAssertTrue(strategy.waitForExistence(timeout: 4))
        strategy.buttons["High"].tap()
        XCTAssertTrue(strategy.buttons["High"].isSelected)
        strategy.buttons["Low"].tap()
        XCTAssertTrue(strategy.buttons["Low"].isSelected)
        app.buttons["component.customize"].tap()
        let available = app.switches["High fidelity available"]
        XCTAssertTrue(available.waitForExistence(timeout: 4))
        available.switches.firstMatch.tap()
        XCTAssertEqual(available.value as? String, "0")
        app.buttons["customize.done"].tap()
        strategy.buttons["High"].tap()
        XCTAssertTrue(strategy.buttons["Low"].isSelected)
        attach("unavailable-high-remains-low")
    }

    func testUnlockRepeatedTapsAndMasonryTiles() {
        app.buttons["catalog.unlock-together"].tap()
        let unlock = app.segmentedControls.firstMatch
        XCTAssertTrue(unlock.waitForExistence(timeout: 4))
        unlock.buttons["Unlock Together"].tap()
        unlock.buttons["Unlock Together"].tap()
        app.buttons["component.customize"].tap()
        let activations = app.descendants(matching: .any)["unlock.activations"].firstMatch
        reveal(activations)
        attach("unlock-repeated-activations")
        XCTAssertEqual(activations.value as? String, "2")
        let unlocked = app.switches["Unlocked"]
        unlocked.switches.firstMatch.tap()
        app.buttons["customize.done"].tap()
        XCTAssertTrue(app.buttons["Together x You"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.buttons["catalog.masonry-layout"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["masonry.tile.0"].firstMatch.waitForExistence(timeout: 4))
        let first = app.descendants(matching: .any)["masonry.tile.0"].firstMatch.frame
        let second = app.descendants(matching: .any)["masonry.tile.1"].firstMatch.frame
        XCTAssertGreaterThan(second.minX, first.minX)
        XCTAssertNotEqual(first.height, second.height)
        attach("masonry-layout")
    }

    func testPillGuidanceAndCompactState() {
        app.buttons["catalog.translation-pill"].tap()
        app.buttons["kaizosha.translation-strategy-info"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["kaizosha.translation-strategy-guidance"].firstMatch.waitForExistence(timeout: 4))
        attach("translation-guidance")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).tap()
        let guidance = app.descendants(matching: .any)["kaizosha.translation-strategy-guidance"].firstMatch
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: guidance)
        waitForExpectations(timeout: 4)
        app.buttons["component.customize"].tap()
        let compact = app.switches["Compact"]
        XCTAssertTrue(compact.waitForExistence(timeout: 4))
        compact.switches.firstMatch.tap()
        app.buttons["customize.done"].tap()
        XCTAssertTrue(app.buttons["kaizosha.translation-strategy-info"].exists)
        XCTAssertTrue(app.segmentedControls.firstMatch.exists)
        attach("translation-compact")
    }

    private func reveal(_ element: XCUIElement) {
        for _ in 0..<8 {
            if element.exists && element.isHittable { return }
            app.collectionViews.firstMatch.swipeUp()
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
