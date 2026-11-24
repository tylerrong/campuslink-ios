import XCTest

final class CampusLinkUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPrimaryNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-onboardingDone", "YES"]
        app.launch()

        XCTAssertTrue(app.buttons["Drops"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Drops"].exists)

        app.buttons["Active"].tap()
        XCTAssertTrue(app.staticTexts["Active"].waitForExistence(timeout: 2))

        app.buttons["Earnings"].tap()
        XCTAssertTrue(app.staticTexts["Earnings"].waitForExistence(timeout: 2))

        app.buttons["You"].tap()
        XCTAssertTrue(app.staticTexts["You"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testDropsOpensDetail() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-onboardingDone", "YES"]
        app.launch()

        let match = app.staticTexts["Install Duet and finish onboarding"]
        XCTAssertTrue(match.waitForExistence(timeout: 5))
        match.tap()
        XCTAssertTrue(app.buttons["Accept Drop"].waitForExistence(timeout: 3))
    }
}
