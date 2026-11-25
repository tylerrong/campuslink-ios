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
    func testAcceptDropReservesSlotAndCreatesClaim() {
        let state = AppState()
        state.drops = makeSampleDrops()
        state.profileKind = .student
        state.schoolId = "usc"
        let id = "duet-download"
        let before = state.drop(id: id)!.remainingSlots

        state.acceptDrop(id: id)

        XCTAssertEqual(state.drop(id: id)?.remainingSlots, before - 1)
        XCTAssertNotNil(state.claim(forDropId: id))
        XCTAssertEqual(state.currentTab, .active)
    }

    @MainActor
    func testSubmitProofCreatesPendingLedger() {
        let state = AppState()
        state.drops = makeSampleDrops()
        state.profileKind = .student
        state.schoolId = "usc"
        state.acceptDrop(id: "notion-survey")
        guard let claim = state.claim(forDropId: "notion-survey") else {
            return XCTFail("Missing claim")
        }

        state.submitProof(claimId: claim.id, imageData: nil, link: "", answer: "I plan my week with Notion every Sunday night.")

        XCTAssertEqual(state.submission(forClaimId: claim.id)?.reviewStatus, .pending)
        XCTAssertTrue(state.ledger.contains { $0.dropId == "notion-survey" && $0.type == .pending })
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
}
