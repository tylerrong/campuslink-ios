import XCTest
@testable import CampusLink

final class CampusLinkTests: XCTestCase {
    func testTypedRoutePreservesDropID() {
        let state = AppState()
        state.drops = makeSampleDrops()
        state.push(.dropDetail, id: "duet-download")

        XCTAssertEqual(state.currentRoute, AppRoute(.dropDetail, id: "duet-download"))
        XCTAssertEqual(state.opportunity(id: "duet-download")?.id, "duet-download")
    }

    @MainActor
    func testClaimMarksRemoteDropApplied() async {
        let state = AppState()
        state.sessionToken = AuthStore.simulatorPreviewToken
        var drop = makeSampleDrops()[0]
        drop.isRemoteOpportunity = true
        drop.hasApplied = false
        state.drops = [drop]
        state.profileKind = .student
        state.schoolId = "usc"

        await state.applyToOpportunity(id: drop.id)

        XCTAssertTrue(state.drop(id: drop.id)?.hasApplied == true)
        XCTAssertTrue(state.appliedOpportunities.contains { $0.id == drop.id })
        XCTAssertEqual(state.currentTab, .drops)
    }

    func testOrgOnlyDropsHiddenFromStudents() {
        let state = AppState()
        state.drops = makeSampleDrops()
        state.profileKind = .student
        state.schoolId = "usc"

        let ranked = state.rankedDrops(filter: .all)
        XCTAssertFalse(ranked.contains { $0.id == "celsius-checkin" })
    }

    func testSocialFilterMatchesContentDrops() {
        let state = AppState()
        state.drops = makeSampleDrops()
        state.profileKind = .student
        state.schoolId = "usc"

        let ranked = state.rankedDrops(filter: .social)
        XCTAssertTrue(ranked.allSatisfy { $0.category == .content || $0.category == .socialPost })
    }

    func testOpportunityLookupFindsAppliedRecordOutsideFeed() {
        let state = AppState()
        let drops = makeSampleDrops()
        guard let first = drops.first, let applied = drops.dropFirst().first else {
            return XCTFail("Missing fixtures")
        }
        state.drops = [first]
        state.appliedOpportunities = [applied]

        XCTAssertEqual(state.opportunity(id: applied.id)?.id, applied.id)
        XCTAssertNil(state.opportunity(id: "missing"))
        state.drops = []
        XCTAssertNil(state.opportunity(id: first.id))
    }

    @MainActor
    func testRemoteOpportunityUsesAPIMetadataAndInclusiveDeadline() throws {
        let data = Data("""
        {
          "id": 7, "title": "Campus Reel", "description": "Film a Reel",
          "start_date": "2099-04-01", "end_date": "2099-04-05", "status": "active",
          "category": "content", "audience": "students", "steps": ["Send a sample Reel"],
          "apply_note": "We’ll reply within a week", "compensation_label": " Paid ",
          "user_has_expressed_interest": false,
          "brand": {"user_id": 3, "name": "Example"}
        }
        """.utf8)
        let remote = try JSONDecoder().decode(RemoteOpportunity.self, from: data)
        let drop = CampusDrop.fromOpportunity(remote)

        XCTAssertEqual(drop.category, .content)
        XCTAssertEqual(drop.audience, .students)
        XCTAssertEqual(drop.instructions, ["Send a sample Reel"])
        XCTAssertEqual(drop.applyNote, "We’ll reply within a week")
        XCTAssertEqual(drop.compensationLabel, "Paid")
        XCTAssertEqual(drop.endAt, ISO8601DateFormatter().date(from: "2099-04-06T00:00:00Z"))
    }

    @MainActor
    func testLegacyOpportunityDoesNotInventCategoryOrCompensation() throws {
        let data = Data("""
        {
          "id": 9, "title": "Opportunity", "description": "Details",
          "start_date": "2099-04-01", "end_date": "2099-04-05", "status": "active",
          "user_has_expressed_interest": false,
          "brand": {"user_id": 3, "name": "Example"}
        }
        """.utf8)
        let remote = try JSONDecoder().decode(RemoteOpportunity.self, from: data)
        let drop = CampusDrop.fromOpportunity(remote)

        XCTAssertEqual(drop.category, .other)
        XCTAssertEqual(drop.audience, .students)
        XCTAssertNil(drop.compensationLabel)
        XCTAssertTrue(drop.instructions.isEmpty)
        XCTAssertNil(drop.taskUrl)
    }

    @MainActor
    func testCashOutRequiresMinimum() {
        let state = AppState()
        state.ledger = [
            LedgerEntry(id: "1", dropId: "duet-download", amountCents: 1000, type: .payable, createdAt: Date(), note: "test")
        ]
        state.cashOut()
        XCTAssertEqual(state.payableBalanceCents, 1000)
    }

    func testRemotePayoutsDecodesFromMePayload() throws {
        let data = Data("""
        {
          "id": 1, "email": "a@ucla.edu", "name": "Alex", "role": "user",
          "profile_type": "student", "registration_completed": true,
          "payouts": {
            "status": "pending", "ready": false, "details_submitted": true,
            "payouts_enabled": false, "has_account": true, "eligible": true,
            "manage_url": "https://joincampuslink.com/profile/payouts"
          }
        }
        """.utf8)
        let user = try JSONDecoder().decode(RemoteUser.self, from: data)
        XCTAssertEqual(user.payouts?.status, "pending")
        XCTAssertEqual(user.payouts?.has_account, true)
        XCTAssertEqual(user.payouts?.ctaLabel, "Continue setup")
    }

    @MainActor
    func testRebuildLedgerFromClaimStatuses() {
        let state = AppState()
        state.sessionToken = "live-token"
        var drop = makeSampleDrops()[0]
        drop.isRemoteOpportunity = true
        drop.hasApplied = true
        drop.submissionStatus = "approved"
        state.appliedOpportunities = [drop]
        state.payouts = RemotePayouts(
            status: "none", ready: false, details_submitted: false,
            payouts_enabled: false, has_account: false, eligible: true,
            manage_url: nil
        )

        state.rebuildLedgerFromClaims()

        XCTAssertEqual(state.ledger.count, 1)
        XCTAssertEqual(state.ledger.first?.type, .payable)
        XCTAssertTrue(state.ledger.first?.note.contains("set up payouts") == true)
    }

    func testEventCategoryLabelIsShort() {
        XCTAssertEqual(DropCategory.event.rawValue, "Event")
        XCTAssertEqual(DropCategory(remoteValue: "event"), .event)
    }

    func testStudentAccountTypesMatchWeb() {
        XCTAssertEqual(StudentAccountType.influencer.rawValue, "influencer")
        XCTAssertEqual(StudentAccountType.ambassador.rawValue, "ambassador")
        XCTAssertEqual(StudentAccountType.both.rawValue, "both")
        XCTAssertEqual(StudentAccountType.athlete.rawValue, "athlete")
    }
}
