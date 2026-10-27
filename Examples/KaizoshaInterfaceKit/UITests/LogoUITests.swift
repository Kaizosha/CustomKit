import XCTest

@MainActor
final class LogoUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCatalogContainsTheRequestedOrder() {
        XCTAssertTrue(app.navigationBars["KaizoshaInterfaceKit"].exists)
        let titles = ["Kaizosha Logo", "Made by Kaizosha", "Unlock Together", "Translation Strategy Pill", "Language Switcher", "Low/High Switcher", "Masonry Layout"]
        XCTAssertEqual(app.cells.count, titles.count)
        for (index, title) in titles.enumerated() {
            XCTAssertTrue(app.cells.element(boundBy: index).staticTexts[title].exists)
        }
        XCTAssertTrue(app.buttons["catalog.kaizosha-logo"].exists)
        XCTAssertFalse(app.buttons["catalog.playerkit"].exists)
        XCTAssertFalse(app.buttons["catalog.buttons"].exists)
        attach("kaizosha-interfacekit-list")
        openLogo()
        XCTAssertTrue(app.navigationBars.buttons["component.customize"].exists)
        XCTAssertFalse(app.buttons["component.code"].exists)
        attach("kaizosha-logo")
    }

    func testLiveCustomizationResetAndUsageCode() {
        openLogo()
        let logo = app.descendants(matching: .any)["logo.element"].firstMatch
        XCTAssertTrue(logo.waitForExistence(timeout: 4))
        let initialWidth = logo.frame.width
        app.buttons["component.customize"].tap()
        let size = app.sliders["Size"]
        XCTAssertTrue(size.waitForExistence(timeout: 4))
        XCTAssertLessThan(logo.frame.maxY, app.navigationBars["Customize"].frame.minY)
        attach("kaizosha-logo-customization")
        size.adjust(toNormalizedSliderPosition: 0.8)
        app.buttons["customize.done"].tap()
        XCTAssertGreaterThan(logo.frame.width, initialWidth + 30)
        attach("kaizosha-logo-customized")
        app.buttons["component.customize"].tap()
        reveal(app.buttons["component.reset"])
        app.buttons["component.reset"].tap()
        app.buttons["customize.done"].tap()
        XCTAssertEqual(logo.frame.width, initialWidth, accuracy: 2)
        app.buttons["component.customize"].tap()
        reveal(app.buttons["component.code"])
        app.buttons["component.code"].tap()
        XCTAssertTrue(app.navigationBars["Use in your app"].waitForExistence(timeout: 4))
        app.buttons["Copy"].tap()
        XCTAssertTrue(app.buttons["Copied"].exists)
        attach("kaizosha-logo-usage")
    }

    func testLogoReturnsToItsAnchorAfterDrag() {
        openLogo()
        let logo = app.descendants(matching: .any)["logo.element"].firstMatch
        XCTAssertTrue(logo.waitForExistence(timeout: 4))
        let anchor = logo.frame
        let start = logo.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 100, dy: 70))
        start.press(forDuration: 0.1, thenDragTo: end)
        let settled = NSPredicate { _, _ in
            abs(logo.frame.midX - anchor.midX) < 2 && abs(logo.frame.midY - anchor.midY) < 2
        }
        expectation(for: settled, evaluatedWith: nil)
        waitForExpectations(timeout: 5)
        attach("kaizosha-logo-after-drag")
    }

    private func openLogo() {
        app.buttons["catalog.kaizosha-logo"].tap()
        XCTAssertTrue(app.buttons["component.customize"].waitForExistence(timeout: 4))
    }

    private func reveal(_ element: XCUIElement) {
        for _ in 0..<6 {
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
