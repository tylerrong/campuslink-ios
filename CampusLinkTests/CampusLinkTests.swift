import XCTest
@testable import CampusLink

final class CampusLinkTests: XCTestCase {
    func testTypedRoutePreservesDropID() {
        let state = AppState()
        state.push(.dropDetail, id: "duet-download")

        XCTAssertEqual(state.currentRoute, AppRoute(.dropDetail, id: "duet-download"))
        XCTAssertEqual(state.detailDrop?.id, "duet-download")
    }

    @MainActor
    func testAcceptDropReservesSlotAndCreatesClaim() {
        let state = AppState()
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
        state.profileKind = .student
        state.schoolId = "usc"

        let ranked = state.rankedDrops(filter: "all")
        XCTAssertFalse(ranked.contains { $0.id == "celsius-checkin" })
    }

    func testOrgSeesOrgDrops() {
        let state = AppState()
        state.profileKind = .org
        state.schoolId = "usc"

        let ranked = state.rankedDrops(filter: "orgs")
        XCTAssertTrue(ranked.contains { $0.audience == .orgs || $0.audience == .both })
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
