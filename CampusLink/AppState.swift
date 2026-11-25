import SwiftUI
import UIKit
import Observation

enum AppTab: Hashable { case drops, active, earnings, you }

enum AppScreen: Hashable {
    case dropDetail, proofSubmit, editProfile, payoutSettings, cashOut
}

struct AppRoute: Hashable {
    let screen: AppScreen
    let id: String

    init(_ screen: AppScreen, id: String = "") {
        self.screen = screen
        self.id = id
    }
}

/// One-shot haptic tap — call from any button action.
func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

@Observable
class AppState {
    // MARK: Branding
    static let productName = "CampusLink"
    static let webBaseURL = "https://joincampuslink.com"
    static let cashOutMinimumCents = 2500

    // MARK: Onboarding
    /// 0=splash 1=role 2=school 3=verify 4=interests/org 5=handle 6=done
    var onboardingStep: Int = 0
    var profileKind: ProfileKind = .student
    /// School short_name slug from web (empty until /me syncs).
    var schoolId: String = ""
    var schoolNumericId: Int? = nil
    var remoteSchool: School? = nil
    var year: String = ""
    var major: String = ""
    var bio: String = ""
    var interests: [String] = []
    var interestsText: String = ""
    var handle: String = ""
    var fullName: String = ""
    var orgName: String = ""
    var orgType: OrgType = .club
    var orgMemberCount: String = ""
    var instagramHandle: String = ""
    var tiktokHandle: String = ""
    var linkedinURL: String = ""
    var portfolioLink: String = ""
    var website: String = ""
    var studentType: String = ""
    var sport: String = ""
    var pictureURL: String? = nil

    // MARK: Profile / settings
    var avatarImageData: Data? = nil
    var eduEmail: String = ""
    var verificationStatus: VerificationStatus = .unverified
    private static let notificationsKey = "campuslink.alerts.enabled"
    private static let dropAlertsKey = "campuslink.alerts.drops"
    private static let payoutAlertsKey = "campuslink.alerts.payouts"

    var notificationsEnabled = UserDefaults.standard.object(forKey: notificationsKey) as? Bool ?? true {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Self.notificationsKey) }
    }
    var dropAlertsEnabled = UserDefaults.standard.object(forKey: dropAlertsKey) as? Bool ?? true {
        didSet { UserDefaults.standard.set(dropAlertsEnabled, forKey: Self.dropAlertsKey) }
    }
    var payoutAlertsEnabled = UserDefaults.standard.object(forKey: payoutAlertsKey) as? Bool ?? true {
        didSet { UserDefaults.standard.set(payoutAlertsEnabled, forKey: Self.payoutAlertsKey) }
    }
    var payoutMethodLabel: String = "Add debit card"
    var canPreviewCashOut: Bool {
        sessionToken == AuthStore.simulatorPreviewToken && payableBalanceCents >= Self.cashOutMinimumCents
    }

    // MARK: Catalog + activity
    /// Live opportunities from joincampuslink.com (empty until signed in).
    var drops: [CampusDrop] = []
    var claims: [DropClaim] = []
    var submissions: [DropSubmission] = []
    var ledger: [LedgerEntry] = []
    var notifications: [AppNotification] = []
    var appliedOpportunities: [CampusDrop] = []
    var isLoadingFeed = false
    var feedError: String = ""
    private(set) var isLoadingApplications = false
    private(set) var applicationsError = ""
    private(set) var applyingOpportunityID: String?
    private var applicationsRevision = 0
    private var applicationDates: [String: Date] = [:]

    var weeklyApplicationCount: Int {
        let now = Date()
        return applicationDates.values.filter {
            Calendar.current.isDate($0, equalTo: now, toGranularity: .weekOfYear)
        }.count
    }

    private var applicationDatesKey: String? {
        guard let userID = remoteUser?.id, let sessionToken,
              sessionToken != AuthStore.simulatorPreviewToken else { return nil }
        return "campuslink.applications.weekly.\(userID)"
    }

    // MARK: Session (mirrored from AuthStore)
    var sessionToken: String?
    var remoteUser: RemoteUser?
    /// Fired when an API call returns unauthorized — ContentView should sign out AuthStore.
    var onSessionExpired: (() -> Void)?

    // MARK: Navigation
    var currentTab: AppTab = .drops
    var navigationPath: [AppRoute] = []

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
        navigationPath.append(AppRoute(screen, id: id))
    }
    func pop() { if !navigationPath.isEmpty { navigationPath.removeLast() } }
    func setTab(_ tab: AppTab) {
        guard tab != currentTab || !navigationPath.isEmpty else { return }
        navigationPath.removeAll()
        currentTab = tab
    }

    /// Clear local session state (AuthStore clears Keychain separately).
    func logOut() {
        navigationPath.removeAll()
        currentTab = .drops
        onboardingStep = 0
        toastMessage = ""
        sessionToken = nil
        remoteUser = nil
        drops = []
        appliedOpportunities = []
        claims = []
        submissions = []
        ledger = []
        notifications = []
        payoutMethodLabel = "Add debit card"
        applicationDates = [:]
        feedError = ""
        isLoadingFeed = false
        isLoadingApplications = false
        applicationsError = ""
        applyingOpportunityID = nil
        applicationsRevision += 1
        clearProfileFields()
    }

    private func clearProfileFields() {
        schoolId = ""
        schoolNumericId = nil
        remoteSchool = nil
        year = ""
        major = ""
        bio = ""
        interests = []
        interestsText = ""
        handle = ""
        fullName = ""
        orgName = ""
        orgType = .club
        orgMemberCount = ""
        instagramHandle = ""
        tiktokHandle = ""
        linkedinURL = ""
        portfolioLink = ""
        website = ""
        studentType = ""
        sport = ""
        pictureURL = nil
        eduEmail = ""
        verificationStatus = .unverified
        avatarImageData = nil
    }

    func syncSession(token: String?, user: RemoteUser?) {
        if sessionToken != nil && sessionToken != token { logOut() }
        let sessionChanged = sessionToken != token || remoteUser?.id != user?.id
        sessionToken = token
        remoteUser = user
        if sessionChanged {
            applicationDates = applicationDatesKey.flatMap {
                UserDefaults.standard.dictionary(forKey: $0) as? [String: Date]
            } ?? [:]
        }
        guard let user else {
            clearProfileFields()
            return
        }
        applyRemoteProfile(user)
    }

    /// Map joincampuslink.com /me (and auth session) into local profile fields.
    func applyRemoteProfile(_ user: RemoteUser) {
        profileKind = user.profile_type == "campus_org" ? .org : .student
        eduEmail = user.email
        verificationStatus = user.registration_completed ? .verified : .unverified
        pictureURL = user.picture

        schoolNumericId = user.school_id ?? user.school?.id
        if let remote = user.school {
            let mapped = School.fromRemote(remote)
            remoteSchool = mapped
            schoolId = mapped.id
        } else {
            remoteSchool = nil
            schoolId = ""
        }

        if profileKind == .org {
            let org = user.org
            orgName = org?.org_name?.trimmingCharacters(in: .whitespacesAndNewlines)
                ?? (user.name.isEmpty ? "" : user.name)
            orgType = OrgType.fromWeb(org?.org_type)
            if let count = org?.member_count {
                orgMemberCount = String(count)
            } else if orgMemberCount.isEmpty {
                orgMemberCount = ""
            }
            bio = org?.bio ?? ""
            instagramHandle = Self.normalizeHandle(org?.instagram_handle)
            tiktokHandle = Self.normalizeHandle(org?.tiktok_handle)
            website = org?.website?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            portfolioLink = org?.portfolio_link?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            linkedinURL = ""
            year = ""
            major = ""
            interestsText = ""
            interests = []
            studentType = ""
            sport = ""
            fullName = orgName
            handle = orgName
        } else {
            let student = user.student
            fullName = student?.full_name?.trimmingCharacters(in: .whitespacesAndNewlines)
                ?? (user.name.isEmpty ? "" : user.name)
            handle = fullName
            if let gy = student?.graduation_year {
                year = String(gy)
            } else {
                year = ""
            }
            major = student?.major?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            bio = student?.bio ?? ""
            interestsText = student?.interests?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            interests = Self.parseInterests(interestsText)
            studentType = student?.student_type ?? ""
            sport = student?.sport ?? ""
            instagramHandle = Self.normalizeHandle(student?.instagram_handle)
            tiktokHandle = Self.normalizeHandle(student?.tiktok_handle)
            linkedinURL = student?.linkedin_url?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            portfolioLink = student?.portfolio_link?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            website = ""
            orgName = ""
            orgMemberCount = ""
        }
    }

    private static func normalizeHandle(_ raw: String?) -> String {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return ""
        }
        if value.hasPrefix("@") { value.removeFirst() }
        return value
    }

    private static func parseInterests(_ text: String) -> [String] {
        text
            .split { $0 == "," || $0 == ";" || $0 == "\n" }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Seed local sample drops when browsing without a real session (Simulator preview).
    @MainActor
    func loadSimulatorPreviewCatalog() {
#if targetEnvironment(simulator)
        if drops.isEmpty {
            drops = makePreviewOpportunities()
        }
        feedError = ""
        isLoadingFeed = false
#endif
    }

    @MainActor
    func refreshProfile() async {
        guard let token = sessionToken, token != AuthStore.simulatorPreviewToken else { return }
        do {
            let me = try await APIClient.shared.fetchMe(token: token)
            guard sessionToken == token, !Task.isCancelled else { return }
            remoteUser = me
            applyRemoteProfile(me)
        } catch {
            guard sessionToken == token, !Task.isCancelled else { return }
            if isUnauthorized(error) {
                handleSessionExpired()
            }
        }
    }

    @MainActor
    func refreshOpportunities() async {
        guard let token = sessionToken else { return }
        if token == AuthStore.simulatorPreviewToken {
            loadSimulatorPreviewCatalog()
            return
        }
        guard !isLoadingFeed else { return }
        isLoadingFeed = true
        feedError = ""
        defer {
            if sessionToken == token { isLoadingFeed = false }
        }
        do {
            let remote = try await APIClient.shared.fetchOpportunities(token: token)
            guard sessionToken == token, !Task.isCancelled else { return }
            let appliedIDs = Set(appliedOpportunities.map(\.id))
            drops = remote
                .filter { opp in
                    // Prefer Drop rows; omit partnership offers if the API ever mixes them.
                    guard let type = opp.offer_type?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                          !type.isEmpty else { return true }
                    return type == "drop"
                }
                .map {
                    var drop = CampusDrop.fromOpportunity($0)
                    drop.hasApplied = drop.hasApplied || appliedIDs.contains(drop.id)
                    return drop
                }
        } catch {
            guard sessionToken == token, !Task.isCancelled else { return }
            if isUnauthorized(error) {
                handleSessionExpired()
            } else {
                feedError = "Check your connection and try again."
            }
        }
    }

    @MainActor
    func refreshApplied() async {
        guard let token = sessionToken, token != AuthStore.simulatorPreviewToken,
              !isLoadingApplications else { return }
        let revision = applicationsRevision
        isLoadingApplications = true
        applicationsError = ""
        defer {
            if sessionToken == token { isLoadingApplications = false }
        }
        do {
            let remote = try await APIClient.shared.fetchApplied(token: token)
            guard sessionToken == token, !Task.isCancelled, revision == applicationsRevision else { return }
            appliedOpportunities = remote
                .filter { opp in
                    guard let type = opp.offer_type?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                          !type.isEmpty else { return true }
                    return type == "drop"
                }
                .map(CampusDrop.fromOpportunity)
            let appliedIDs = Set(appliedOpportunities.map(\.id))
            for i in drops.indices where appliedIDs.contains(drops[i].id) {
                drops[i].hasApplied = true
            }
        } catch {
            guard sessionToken == token, !Task.isCancelled else { return }
            if isUnauthorized(error) {
                handleSessionExpired()
            } else if revision == applicationsRevision {
                applicationsError = "Check your connection and try again."
            }
        }
    }

    private func isUnauthorized(_ error: Error) -> Bool {
        if let api = error as? APIError, case .unauthorized = api { return true }
        return false
    }

    private func handleSessionExpired() {
        sessionToken = nil
        remoteUser = nil
        KeychainStore.clearToken()
        onSessionExpired?()
    }

    @MainActor
    func applyToOpportunity(id: String) async {
        guard applyingOpportunityID == nil,
              var drop = drop(id: id), !drop.hasApplied, isEligible(drop) else { return }
        guard let token = sessionToken else {
            showToast("Sign in to claim", icon: "xmark")
            return
        }
        let submittedFrom = currentRoute
        applyingOpportunityID = id
        defer {
            if sessionToken == token { applyingOpportunityID = nil }
        }
        do {
            let isNewClaim: Bool
            if token == AuthStore.simulatorPreviewToken {
                isNewClaim = true
            } else {
                isNewClaim = try await APIClient.shared.apply(opportunityId: id, token: token)
            }
            guard sessionToken == token else { return }
            if isNewClaim { recordApplication(id: id) }
            applicationsRevision += 1
            applicationsError = ""
            drop.hasApplied = true
            if let index = drops.firstIndex(where: { $0.id == id }) {
                drops[index].hasApplied = true
            }
            if !appliedOpportunities.contains(where: { $0.id == id }) {
                appliedOpportunities.insert(drop, at: 0)
            }
            showToast(isNewClaim ? "Drop claimed" : "Already claimed", icon: "checkmark")
            if submittedFrom == AppRoute(.dropDetail, id: id), currentRoute == submittedFrom {
                setTab(.active)
            }
        } catch {
            guard sessionToken == token else { return }
            if isUnauthorized(error) {
                handleSessionExpired()
            } else if let err = error as? APIError, case .registrationRequired(let url) = err {
                showToast(err.localizedDescription ?? "Finish your profile", icon: "xmark")
                if let url { await UIApplication.shared.open(url) }
            } else {
                showToast(error.localizedDescription, icon: "xmark")
            }
        }
    }

    private func recordApplication(id: String) {
        let now = Date()
        let calendar = Calendar.current
        applicationDates = applicationDates.filter {
            calendar.isDate($0.value, equalTo: now, toGranularity: .weekOfYear)
        }
        applicationDates[id] = now
        if let key = applicationDatesKey {
            UserDefaults.standard.set(applicationDates, forKey: key)
        }
    }

    var currentRoute: AppRoute? { navigationPath.last }
    var detailId: String { currentRoute?.id ?? "" }

    var school: School {
        if let remoteSchool { return remoteSchool }
        if !schoolId.isEmpty, let match = sampleSchools.first(where: { $0.id == schoolId }) {
            return match
        }
        return .placeholder
    }

    var displayName: String {
        if profileKind == .org {
            return orgName.isEmpty ? "Your org" : orgName
        }
        if !fullName.isEmpty { return fullName }
        if !handle.isEmpty { return handle }
        return "You"
    }

    var profileSubtitle: String {
        if profileKind == .org {
            let members = orgMemberCount.isEmpty ? nil : "\(orgMemberCount) members"
            return [orgType.label, members].compactMap { $0 }.joined(separator: " · ")
        }
        var parts: [String] = []
        if !year.isEmpty { parts.append("Class of \(year)") }
        if !major.isEmpty { parts.append(major) }
        if parts.isEmpty { parts.append("Student") }
        return parts.joined(separator: " · ")
    }

    var unreadNotificationCount: Int { notifications.filter { !$0.read }.count }

    var activeClaims: [DropClaim] {
        claims.filter { $0.status == .claimed || $0.status == .submitted }
            .sorted { $0.acceptedAt > $1.acceptedAt }
    }

    var pendingBalanceCents: Int {
        ledger.filter { $0.type == .pending }.reduce(0) { $0 + $1.amountCents }
    }

    var payableBalanceCents: Int {
        ledger.filter { $0.type == .payable }.reduce(0) { $0 + $1.amountCents }
    }

    var paidTotalCents: Int {
        ledger.filter { $0.type == .paid }.reduce(0) { $0 + $1.amountCents }
    }

    var lifetimeEarnedCents: Int { payableBalanceCents + paidTotalCents + pendingBalanceCents }

    // MARK: Lookups
    func drop(id: String) -> CampusDrop? { drops.first { $0.id == id } }
    func claim(id: String) -> DropClaim? { claims.first { $0.id == id } }
    func claim(forDropId dropId: String) -> DropClaim? {
        claims.first { $0.dropId == dropId && ($0.status == .claimed || $0.status == .submitted) }
    }
    func submission(forClaimId claimId: String) -> DropSubmission? {
        submissions.first { $0.claimId == claimId }
    }
    func opportunity(id: String) -> CampusDrop? {
        appliedOpportunities.first { $0.id == id } ?? drop(id: id)
    }

    // MARK: Eligibility + ranking
    func isEligible(_ drop: CampusDrop) -> Bool {
        guard drop.isLive else { return false }
        if !drop.schools.isEmpty && !drop.schools.contains(schoolId) { return false }
        switch drop.audience {
        case .students: return profileKind == .student
        case .orgs: return profileKind == .org
        case .both: return true
        }
    }

    func rankedDrops(filter: DropFeedFilter = .all) -> [CampusDrop] {
        drops.filter { isEligible($0) && filter.matches($0) }
            .sorted { dropScore($0) > dropScore($1) }
    }

    private func dropScore(_ drop: CampusDrop) -> Int {
        var score = drop.payoutCents / 100
        if drop.endAt != .distantFuture { score += max(0, 48 - Int(drop.endAt.timeIntervalSinceNow / 3600)) }
        if !drop.isRemoteOpportunity && drop.remainingSlots < 20 { score += 15 }
        if profileKind == .student {
            for interest in interests {
                let hay = "\(drop.title) \(drop.description) \(drop.brand) \(drop.category.rawValue)".lowercased()
                if interest == "apps" && drop.category == .appInstall { score += 20 }
                if interest == "content" && drop.category == .socialPost { score += 20 }
                if hay.contains(interest.lowercased()) { score += 8 }
            }
        } else if drop.audience == .orgs {
            score += 30
        }
        return score
    }

    // MARK: Actions
    @discardableResult
    func expireStaleClaimsIfNeeded() -> Bool {
        let now = Date()
        var changed = false
        for i in claims.indices where claims[i].status == .claimed && claims[i].expiresAt < now {
            let dropId = claims[i].dropId
            claims[i].status = .expired
            if let di = drops.firstIndex(where: { $0.id == dropId }) {
                drops[di].remainingSlots = min(drops[di].maxCompletions, drops[di].remainingSlots + 1)
            }
            pushNotification(
                kind: .claimExpiring,
                title: "Claim expired",
                body: "Your reserved spot on \(drop(id: dropId)?.title ?? "a Drop") returned to the pool.",
                dropId: dropId
            )
            changed = true
        }
        for i in drops.indices where drops[i].status == .live && drops[i].endAt < now {
            drops[i].status = .ended
            changed = true
        }
        return changed
    }

    @MainActor
    func acceptDrop(id: String) {
        if let drop = drop(id: id), drop.isRemoteOpportunity {
            Task { await applyToOpportunity(id: id) }
            return
        }
        expireStaleClaimsIfNeeded()
        guard let idx = drops.firstIndex(where: { $0.id == id }) else { return }
        let drop = drops[idx]
        guard isEligible(drop) else {
            showToast("You’re not eligible for this Drop", icon: "xmark")
            return
        }
        if claim(forDropId: id) != nil {
            showToast("Already claimed", icon: "checkmark")
            push(.dropDetail, id: id)
            return
        }
        guard drop.remainingSlots > 0 else {
            showToast("No spots left", icon: "xmark")
            return
        }

        drops[idx].remainingSlots -= 1
        let claim = DropClaim(
            id: "claim-\(id)-\(UUID().uuidString.prefix(6))",
            dropId: id,
            acceptedAt: Date(),
            expiresAt: Date().addingTimeInterval(drop.completionWindowSeconds),
            status: .claimed
        )
        claims.insert(claim, at: 0)
        showToast("Drop accepted — timer started", icon: "bolt.fill")
        pushNotification(
            kind: .newDrop,
            title: "Drop claimed",
            body: "Finish \(drop.title) before the timer ends.",
            dropId: id
        )
        pop()
        setTab(.active)
    }

    @MainActor
    func submitProof(claimId: String, imageData: Data?, link: String, answer: String) {
        guard let cIdx = claims.firstIndex(where: { $0.id == claimId }) else { return }
        guard claims[cIdx].status == .claimed ||
                (claims[cIdx].status == .submitted &&
                 submission(forClaimId: claimId)?.reviewStatus == .needsInfo) else { return }

        let dropId = claims[cIdx].dropId
        if let existing = submissions.firstIndex(where: { $0.claimId == claimId }) {
            submissions[existing].imageData = imageData ?? submissions[existing].imageData
            submissions[existing].link = link
            submissions[existing].answer = answer
            submissions[existing].reviewStatus = .pending
            submissions[existing].rejectionReason = nil
            submissions[existing].submittedAt = Date()
            submissions[existing].reviewedAt = nil
        } else {
            let sub = DropSubmission(
                id: "sub-\(UUID().uuidString.prefix(8))",
                claimId: claimId,
                dropId: dropId,
                imageData: imageData,
                link: link,
                answer: answer,
                reviewStatus: .pending,
                rejectionReason: nil,
                submittedAt: Date(),
                reviewedAt: nil
            )
            submissions.insert(sub, at: 0)
        }

        claims[cIdx].status = .submitted

        if let drop = drop(id: dropId) {
            ledger.insert(
                LedgerEntry(
                    id: "led-\(UUID().uuidString.prefix(8))",
                    dropId: dropId,
                    amountCents: drop.payoutCents,
                    type: .pending,
                    createdAt: Date(),
                    note: "Held in escrow — \(drop.title)"
                ),
                at: 0
            )
        }

        showToast("Proof submitted", icon: "paperplane.fill")
        pushNotification(
            kind: .approved,
            title: "Under review",
            body: "We’ll verify your proof. Funds stay in escrow until approved.",
            dropId: dropId
        )
        pop()

        let outcomeRoll = Int.random(in: 0...9)
        let delay = Double.random(in: 2.5...4.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            let outcome: ReviewStatus
            switch outcomeRoll {
            case 0: outcome = .rejected
            case 1, 2: outcome = .needsInfo
            default: outcome = .approved
            }
            self.simulateReview(claimId: claimId, outcome: outcome)
        }
    }

    @MainActor
    func simulateReview(claimId: String, outcome: ReviewStatus) {
        guard let sIdx = submissions.firstIndex(where: { $0.claimId == claimId }) else { return }
        let dropId = submissions[sIdx].dropId
        submissions[sIdx].reviewStatus = outcome
        submissions[sIdx].reviewedAt = Date()

        switch outcome {
        case .approved:
            if let lIdx = ledger.firstIndex(where: { $0.dropId == dropId && $0.type == .pending }) {
                ledger[lIdx].type = .payable
                ledger[lIdx].note = "Approved — ready to cash out"
            }
            showToast("Drop approved — payout unlocked", icon: "checkmark.seal.fill")
            pushNotification(
                kind: .approved,
                title: "Proof approved",
                body: "\(drop(id: dropId)?.payoutLabel ?? "Payout") is now payable.",
                dropId: dropId
            )
        case .rejected:
            submissions[sIdx].rejectionReason = "Proof didn’t match the required screen. Read the instructions and try a different Drop."
            if let lIdx = ledger.firstIndex(where: { $0.dropId == dropId && $0.type == .pending }) {
                ledger[lIdx].type = .reversed
                ledger[lIdx].note = "Rejected — escrow released"
            }
            if let cIdx = claims.firstIndex(where: { $0.id == claimId }) {
                claims[cIdx].status = .expired
            }
            if let dIdx = drops.firstIndex(where: { $0.id == dropId }) {
                drops[dIdx].remainingSlots = min(drops[dIdx].maxCompletions, drops[dIdx].remainingSlots + 1)
            }
            showToast("Proof rejected", icon: "xmark")
            pushNotification(
                kind: .rejected,
                title: "Proof rejected",
                body: submissions[sIdx].rejectionReason ?? "See Active for details.",
                dropId: dropId
            )
        case .needsInfo:
            submissions[sIdx].rejectionReason = "We need a clearer screenshot of the final screen. Resubmit when ready."
            if let cIdx = claims.firstIndex(where: { $0.id == claimId }) {
                claims[cIdx].status = .claimed
                claims[cIdx].expiresAt = Date().addingTimeInterval(60 * 60)
            }
            showToast("More info needed", icon: "exclamationmark.bubble")
            pushNotification(
                kind: .needsInfo,
                title: "Needs more info",
                body: submissions[sIdx].rejectionReason ?? "Resubmit your proof.",
                dropId: dropId
            )
        case .pending:
            break
        }
    }

    @MainActor
    func cashOut() {
        let available = payableBalanceCents
        guard available >= Self.cashOutMinimumCents else {
            showToast("Minimum cash out is \(Self.cashOutMinimumCents.dollarsCompact)", icon: "xmark")
            return
        }
        for i in ledger.indices where ledger[i].type == .payable {
            ledger[i].type = .paid
            ledger[i].note = "Cashed out"
        }
        showToast("\(available.dollarsCompact) on the way", icon: "banknote")
        pushNotification(
            kind: .payout,
            title: "Payout sent",
            body: "\(available.dollarsCompact) is headed to \(payoutMethodLabel).",
            dropId: nil
        )
        pop()
    }

    @MainActor
    func submitVerification(email: String) {
        eduEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        verificationStatus = .pending
        showToast("Verification submitted", icon: "envelope.fill")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.verificationStatus = .verified
            self?.showToast("School verified", icon: "checkmark.seal.fill")
        }
    }

    func markNotificationsRead() {
        for i in notifications.indices { notifications[i].read = true }
    }

    func pushNotification(kind: AppNotificationKind, title: String, body: String, dropId: String?) {
        guard notificationsEnabled,
              (kind == .payout ? payoutAlertsEnabled : dropAlertsEnabled) else { return }
        notifications.insert(
            AppNotification(
                id: "n-\(UUID().uuidString.prefix(8))",
                kind: kind,
                title: title,
                body: body,
                createdAt: Date(),
                read: false,
                relatedDropId: dropId
            ),
            at: 0
        )
    }

    func claimTimeRemaining(for claim: DropClaim) -> TimeInterval {
        max(0, claim.expiresAt.timeIntervalSinceNow)
    }

    func claimTimeLabel(for claim: DropClaim) -> String {
        let t = claimTimeRemaining(for: claim)
        if t <= 0 { return "Expired" }
        let h = Int(t) / 3600
        let m = (Int(t) % 3600) / 60
        let s = Int(t) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d:%02d", m, s)
    }

    static func shareURL(path: String) -> URL {
        URL(string: "\(webBaseURL)/\(path)")!
    }
}
