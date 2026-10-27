import XCTest

@MainActor
final class NativeGlassButtonUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        let destination = app.buttons["catalog.native-glass-button"]
        reveal(destination)
        destination.tap()
        XCTAssertTrue(element.waitForExistence(timeout: 4))
    }

    func testRepeatedActivationAndLocalAndAncestorDisabling() {
        element.tap()
        element.tap()
        assertActivations(2)
        app.buttons["component.customize"].tap()
        let current = app.descendants(matching: .any)["glass.customization-activations"].firstMatch
        XCTAssertTrue(current.waitForExistence(timeout: 4))
        XCTAssertEqual(current.value as? String, "2")
        toggle("glass.enabled")
        app.buttons["customize.done"].tap()
        assertDisabledCannotActivate(expected: 2)

        app.buttons["component.customize"].tap()
        toggle("glass.enabled")
        toggle("glass.ancestor-disabled")
        app.buttons["customize.done"].tap()
        assertDisabledCannotActivate(expected: 2)

        app.buttons["component.customize"].tap()
        toggle("glass.ancestor-disabled")
        app.buttons["customize.done"].tap()
        XCTAssertTrue(element.isEnabled)
        element.tap()
        assertActivations(3)
    }

    func testNativeMenuCommandAndDisabledMenu() {
        app.buttons["component.customize"].tap()
        selectPreset("Menu")
        app.buttons["customize.done"].tap()
        element.tap()
        let command = app.buttons["glass.menu-command"]
        XCTAssertTrue(command.waitForExistence(timeout: 4))
        command.tap()
        assertActivations(1)
        element.tap()
        XCTAssertTrue(command.waitForExistence(timeout: 4))
        command.tap()
        assertActivations(2)

        app.buttons["component.customize"].tap()
        toggle("glass.ancestor-disabled")
        app.buttons["customize.done"].tap()
        assertDisabledCannotActivate(expected: 2)
        XCTAssertFalse(command.exists)

        app.buttons["component.customize"].tap()
        toggle("glass.ancestor-disabled")
        toggle("glass.enabled")
        app.buttons["customize.done"].tap()
        assertDisabledCannotActivate(expected: 2)
        XCTAssertFalse(command.exists)
    }

    func testPresetsAndResetRestoreTheWorkingDefault() {
        for preset in ["Confirm", "Help", "Reset", "Destructive"] {
            app.buttons["component.customize"].tap()
            selectPreset(preset)
            app.buttons["customize.done"].tap()
            let title = preset == "Confirm" ? "Done" : preset == "Destructive" ? "Delete" : preset
            XCTAssertEqual(element.label, title)
            XCTAssertTrue(element.isEnabled)
            element.tap()
        }
        assertActivations(4)
        app.buttons["component.customize"].tap()
        toggle("glass.ancestor-disabled")
        let reset = app.buttons["component.reset"]
        reveal(reset)
        reset.tap()
        app.buttons["customize.done"].tap()
        XCTAssertEqual(element.label, "Continue")
        XCTAssertTrue(element.isEnabled)
        assertActivations(0)
        element.tap()
        assertActivations(1)
    }

    func testCustomTitleUpdatesTheNativeButton() {
        app.buttons["component.customize"].tap()
        let title = app.textFields["glass.title"]
        reveal(title)
        title.tap()
        title.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8) + "Save changes")
        app.buttons["customize.done"].tap()
        XCTAssertEqual(element.label, "Save changes")
        element.tap()
        assertActivations(1)
    }

    private var element: XCUIElement { app.buttons["glass.element"] }

    private func selectPreset(_ title: String) {
        let picker = app.buttons["glass.preset"]
        XCTAssertTrue(picker.waitForExistence(timeout: 4))
        picker.tap()
        let option = app.buttons[title].firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 4))
        option.tap()
    }

    private func toggle(_ identifier: String) {
        let control = app.switches[identifier]
        reveal(control)
        control.switches.firstMatch.tap()
    }

    private func assertActivations(_ count: Int, file: StaticString = #filePath, line: UInt = #line) {
        let value = app.descendants(matching: .any)["glass.activations"].firstMatch
        XCTAssertEqual(value.value as? String, String(count), file: file, line: line)
    }

    private func assertDisabledCannotActivate(expected: Int, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(element.isEnabled, file: file, line: line)
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        assertActivations(expected, file: file, line: line)
    }

    private func reveal(_ element: XCUIElement) {
        for _ in 0..<10 {
            if element.exists && element.isHittable { return }
            app.collectionViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(element.exists && element.isHittable)
    }
}
