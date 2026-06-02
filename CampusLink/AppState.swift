import SwiftUI
import UIKit
import Observation

enum AppRole { case student, org }
enum AppTab  { case home, brands, drops, opps, me, events, pitch }
enum AppScreen: Equatable {
    case event, brand, opp, dm, drop, inbox, earnings, editProfile, dealDetail
}

/// One-shot haptic tap — call from any button action.
func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

@Observable
class AppState {
    // MARK: Onboarding
    var onboardingStep: Int = 0   // 0=splash 1=school 2=role 3=interests 4=handle 5=done
    var schoolId: String = "usc"
    var obRole: AppRole = .student
    var year: String = "Junior"
    var interests: [String] = []
    var handle: String = "maya"

    // MARK: App runtime
    var appRole: AppRole = .student
    var xp: Int = 1240
    var streak: Int = 5
    var dropTimer: String = "2d 14h"
    var rsvps: [String] = ["tridelt-philanthropy"]
    var applied: [String] = ["celsius-tabling"]
    var following: [String] = []           // brand IDs the student follows
    var acceptedDeals: [String] = []       // offer IDs the org has accepted

    // MARK: Navigation
    var currentTab: AppTab = .home
    var navStack: [AppScreen] = []
    var detailId: String = ""

    // MARK: Toast
    var toastMessage: String = ""
    var toastIcon: String = "checkmark"

    @MainActor func showToast(_ message: String, icon: String = "checkmark") {
        toastMessage = message
        toastIcon = icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            withAnimation(.easeOut(duration: 0.25)) { self?.toastMessage = "" }
        }
    }

    // MARK: Nav helpers
    func push(_ screen: AppScreen, id: String = "") {
        detailId = id
        navStack.append(screen)
    }
    func pop() { if !navStack.isEmpty { navStack.removeLast() } }
    func setTab(_ tab: AppTab) { navStack.removeAll(); currentTab = tab }
    func setRole(_ role: AppRole) { appRole = role; interests = []; navStack.removeAll(); currentTab = .home }

    var currentScreen: AppScreen? { navStack.last }

    // Convenience for computed detail objects
    var detailEvent: CLEvent?    { sampleEvents.first { $0.id == detailId } ?? sampleEvents.first }
    var detailBrand: Brand?      { sampleBrands.first { $0.id == detailId } ?? sampleBrands.first }
    var detailOpp: Opportunity?  { sampleOpportunities.first { $0.id == detailId } ?? sampleOpportunities.first }
    var detailDM: DM?            { sampleDMs.first { $0.id == detailId } ?? sampleDMs.first }
    var detailOffer: DealOffer?  { sampleOffers.first { $0.id == detailId } ?? sampleOffers.first }
}
