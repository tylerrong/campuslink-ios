import XCTest

final class CampusLinkUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testPrimaryNavigation() {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        XCTAssertTrue(app.buttons["Drops"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Drops"].exists)
        XCTAssertTrue(app.staticTexts["This week"].exists)

        app.buttons["My Drops"].tap()
        XCTAssertTrue(app.staticTexts["No claimed Drops yet"].waitForExistence(timeout: 3))

        app.buttons["Earnings"].tap()
        XCTAssertTrue(app.staticTexts["Earnings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Cash out"].exists)
        XCTAssertFalse(app.buttons["Cash out"].isEnabled)

        app.buttons["You"].tap()
        XCTAssertTrue(app.staticTexts["You"].waitForExistence(timeout: 3))
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Alert preferences"].exists)
        XCTAssertTrue(app.switches["Drop alerts"].exists)
        XCTAssertTrue(app.switches["Payout alerts"].exists)
        XCTAssertTrue(app.switches["All notifications"].exists)
        XCTAssertTrue(app.staticTexts["CampusLink Drops - joincampuslink.com"].exists)
    }

    @MainActor
    func testDropsFilterAndClaimFlow() {
        let app = XCUIApplication()
        XCUIDevice.shared.orientation = .portrait
        app.launch()

        let reel = app.buttons["drop-1"]
        XCTAssertTrue(reel.waitForExistence(timeout: 5))

        app.buttons["App Install"].tap()
        XCTAssertTrue(app.buttons["drop-4"].exists)
        XCTAssertFalse(reel.exists)

        app.buttons["Survey"].tap()
        XCTAssertTrue(app.buttons["drop-2"].exists)
        XCTAssertFalse(reel.exists)

        app.buttons["Social"].tap()
        XCTAssertTrue(reel.exists)
        XCTAssertFalse(app.buttons["drop-2"].exists)

        reel.tap()
        XCTAssertTrue(app.staticTexts["What you need to do"].waitForExistence(timeout: 3))
        app.buttons["Claim"].tap()

        let claimed = app.buttons["claimed-drop-1"]
        XCTAssertTrue(claimed.waitForExistence(timeout: 5))
        claimed.tap()
        XCTAssertTrue(app.staticTexts["Create a campus Reel for Olipop"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["claim-status"].exists)
        XCTAssertFalse(app.buttons["Claim"].exists)

        app.buttons["Back"].tap()
        app.buttons["Drops"].tap()
        XCTAssertTrue(app.staticTexts["1/5 Drops claimed"].waitForExistence(timeout: 3))
    }
}
