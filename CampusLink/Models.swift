import SwiftUI
import Hugeicons

// MARK: - Profile

enum ProfileKind: String, CaseIterable, Identifiable {
    case student
    case org

    var id: String { rawValue }

    var label: String {
        switch self {
        case .student: "Student"
        case .org: "Campus org"
        }
    }
}

/// Matches web onboarding `student_type` (influencer / ambassador / both / athlete).
enum StudentAccountType: String, CaseIterable, Identifiable {
    case influencer
    case ambassador
    case both
    case athlete

    var id: String { rawValue }

    var label: String {
        switch self {
        case .influencer: return "Influencer"
        case .ambassador: return "Campus Ambassador"
        case .both: return "Both"
        case .athlete: return "Athlete"
        }
    }

    var detail: String {
        switch self {
        case .influencer: return "2k+ followers"
        case .ambassador: return "Campus partnerships"
        case .both: return "Creator + campus ambassador"
        case .athlete: return "NIL / sports"
        }
    }
}

enum OrgType: String, CaseIterable, Identifiable {
    case fraternity
    case sorority
    case club
    case team
    case officialUniversity = "official_university"
    case independent
    case other
    /// Legacy local onboarding values (still accepted when decoding UI state).
    case greek
    case creator

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fraternity: return "Fraternity"
        case .sorority: return "Sorority"
        case .club: return "Club"
        case .team: return "Team"
        case .officialUniversity: return "Official university"
        case .independent: return "Independent"
        case .other: return "Other"
        case .greek: return "Greek life"
        case .creator: return "Creator collective"
        }
    }

    static func fromWeb(_ raw: String?) -> OrgType {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !raw.isEmpty else { return .club }
        switch raw {
        case "fraternity": return .fraternity
        case "sorority": return .sorority
        case "club": return .club
        case "team": return .team
        case "official_university": return .officialUniversity
        case "independent": return .independent
        case "corporate", "other": return .other
        case "greek", "greek life": return .greek
        case "creator", "creator collective": return .creator
        default: return .other
        }
    }
}

extension School {
    static func fromRemote(_ remote: RemoteSchool) -> School {
        let slug = remote.short_name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let sample = sampleSchools.first { $0.id == slug }
        let hex = remote.primary_color?.trimmingCharacters(in: CharacterSet(charactersIn: "#")) ?? ""
        let color: Color = {
            if !hex.isEmpty { return Color(hex: hex) }
            return sample?.color ?? Color(hex: "111114")
        }()
        let remoteLogo = remote.logo_url?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return School(
            id: slug.isEmpty ? String(remote.id) : slug,
            name: remote.short_name.isEmpty ? remote.name : remote.short_name,
            sub: remote.name,
            color: color,
            students: remote.city ?? "",
            logoUrl: remoteLogo.isEmpty ? sample?.logoUrl : remoteLogo
        )
    }

    static let placeholder = School(
        id: "",
        name: "Your school",
        sub: "Finish your profile on CampusLink",
        color: Color(hex: "6E6E76"),
        students: "",
        logoUrl: nil
    )
}

enum VerificationStatus: String {
    case unverified, pending, verified
}

struct School: Identifiable, Hashable {
    let id: String
    let name: String
    let sub: String
    let color: Color
    let students: String
    var logoUrl: String? = nil
}

// MARK: - Drops

enum DropFeedFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case appInstall = "App Install"
    case social = "Social"
    case survey = "Survey"
    case referral = "Referral"
    case review = "Review"
    case checkIn = "Check-in"
    case follow = "Follow"
    case signup = "Sign-up"

    var id: Self { self }

    /// Matches web `paidTaskTypeIcons` (Hugeicons) for filter chips.
    var hugeIcon: HugeiconsAsset? {
        switch self {
        case .all: return Hugeicons.gridView
        case .appInstall: return Hugeicons.download01
        case .social: return Hugeicons.camera01
        case .survey: return Hugeicons.clipboardList
        case .referral: return Hugeicons.userAdd01
        case .review: return Hugeicons.star
        case .checkIn: return Hugeicons.location01
        case .follow: return Hugeicons.favourite
        case .signup: return Hugeicons.userCircle
        }
    }

    func matches(_ drop: CampusDrop) -> Bool {
        switch self {
        case .all: true
        case .appInstall: drop.category == .appInstall
        case .social: drop.category == .content || drop.category == .socialPost
        case .survey: drop.category == .survey
        case .referral: drop.category == .referral
        case .review: drop.category == .review
        case .checkIn: drop.category == .checkIn
        case .follow: drop.category == .follow
        case .signup: drop.category == .signup
        }
    }
}

enum DropCategory: String, CaseIterable, Identifiable {
    case appInstall = "App Install"
    case survey = "Survey"
    case socialPost = "Social post"
    case referral = "Referral"
    case review = "Review"
    case checkIn = "Check-in"
    case follow = "Follow"
    case signup = "Sign-up"
    case activation = "Campus activation"
    case ambassador = "Ambassador"
    case content = "Social"
    case event = "Event"
    case other = "Other"

    init(remoteValue: String?) {
        switch remoteValue {
        case "app_install": self = .appInstall
        case "survey": self = .survey
        case "content": self = .content
        case "referral": self = .referral
        case "review": self = .review
        case "check_in": self = .checkIn
        case "follow_social": self = .follow
        case "signup": self = .signup
        case "activation": self = .activation
        case "ambassador": self = .ambassador
        case "event": self = .event
        default: self = .other
        }
    }

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .appInstall: "arrow.down.app"
        case .survey: "list.bullet.clipboard"
        case .socialPost, .content: "camera"
        case .referral: "person.badge.plus"
        case .review: "star"
        case .checkIn: "mappin.and.ellipse"
        case .follow: "heart"
        case .signup: "person.crop.circle.badge.plus"
        case .activation: "megaphone"
        case .ambassador: "person.2"
        case .event: "calendar"
        case .other: "briefcase"
        }
    }

    /// Matches web `paidTaskTypeIcons` where the category is a Drop type.
    var hugeIcon: HugeiconsAsset? {
        switch self {
        case .appInstall: return Hugeicons.download01
        case .content, .socialPost: return Hugeicons.camera01
        case .survey: return Hugeicons.clipboardList
        case .referral: return Hugeicons.userAdd01
        case .review: return Hugeicons.star
        case .checkIn: return Hugeicons.location01
        case .follow: return Hugeicons.favourite
        case .signup: return Hugeicons.userCircle
        default: return nil
        }
    }

    /// Safari / in-app button label for `task_url` (mirrors web Drop detail).
    var taskUrlButtonLabel: String {
        switch self {
        case .appInstall: return "Open app link"
        case .survey: return "Open survey"
        case .referral: return "Open referral link"
        case .review: return "Open review page"
        case .follow: return "Open profile to follow"
        case .signup: return "Open sign-up"
        case .checkIn: return "Open location / event"
        case .content, .socialPost: return "Open creative brief"
        default: return "Open Drop link"
        }
    }

    var estimatedMinutes: Int {
        switch self {
        case .appInstall: 10
        case .survey: 8
        case .follow, .signup, .checkIn: 5
        case .referral, .review: 10
        case .socialPost, .activation, .ambassador, .content, .event, .other: 15
        }
    }
}

enum DropStatus: String {
    case live, ended
}

enum AudienceFilter: String {
    case students, orgs, both
}

struct ProofRequirement: Identifiable, Hashable {
    let id: String
    let label: String
    let kind: Kind

    enum Kind: String { case screenshot, link, text, receipt }
}

struct CampusDrop: Identifiable, Hashable {
    let id: String
    let brand: String
    let brandDomain: String?
    /// Optional direct PNG/JPEG logo URL when domain lookup is weak.
    let brandLogoUrl: String?
    let brandColor: Color
    let title: String
    let description: String
    let category: DropCategory
    let payoutCents: Int
    let maxCompletions: Int
    var remainingSlots: Int
    let schools: [String] // school ids; empty = all
    let startAt: Date
    let endAt: Date
    let completionWindowSeconds: TimeInterval
    let proofRequirements: [ProofRequirement]
    let instructions: [String]
    let eligibilityTags: [String]
    let audience: AudienceFilter
    var status: DropStatus
    let estimatedMinutes: Int
    /// True when this card is a joincampuslink.com Drop (not a local mock).
    var isRemoteOpportunity: Bool
    var hasApplied: Bool
    let compensationLabel: String?
    let capacityHint: String?
    let applyNote: String?
    /// External Drop link (App Store, survey, etc.).
    let taskUrl: String?
    /// Remote claim status: pending | approved | rejected | paid
    var submissionStatus: String?

    init(
        id: String,
        brand: String,
        brandDomain: String? = nil,
        brandLogoUrl: String? = nil,
        brandColor: Color,
        title: String,
        description: String,
        category: DropCategory,
        payoutCents: Int,
        maxCompletions: Int,
        remainingSlots: Int,
        schools: [String],
        startAt: Date,
        endAt: Date,
        completionWindowSeconds: TimeInterval,
        proofRequirements: [ProofRequirement],
        instructions: [String],
        eligibilityTags: [String],
        audience: AudienceFilter,
        status: DropStatus,
        estimatedMinutes: Int,
        isRemoteOpportunity: Bool = false,
        hasApplied: Bool = false,
        compensationLabel: String? = nil,
        capacityHint: String? = nil,
        applyNote: String? = nil,
        taskUrl: String? = nil,
        submissionStatus: String? = nil
    ) {
        self.id = id
        self.brand = brand
        self.brandDomain = brandDomain
        self.brandLogoUrl = brandLogoUrl
        self.brandColor = brandColor
        self.title = title
        self.description = description
        self.category = category
        self.payoutCents = payoutCents
        self.maxCompletions = maxCompletions
        self.remainingSlots = remainingSlots
        self.schools = schools
        self.startAt = startAt
        self.endAt = endAt
        self.completionWindowSeconds = completionWindowSeconds
        self.proofRequirements = proofRequirements
        self.instructions = instructions
        self.eligibilityTags = eligibilityTags
        self.audience = audience
        self.status = status
        self.estimatedMinutes = estimatedMinutes
        self.isRemoteOpportunity = isRemoteOpportunity
        self.hasApplied = hasApplied
        self.compensationLabel = compensationLabel
        self.capacityHint = capacityHint
        self.applyNote = applyNote
        self.taskUrl = taskUrl
        self.submissionStatus = submissionStatus
    }

    /// Map remote submission_status → ledger bucket (nil / rejected excluded).
    var ledgerType: LedgerEntryType? {
        switch submissionStatus?.lowercased() {
        case "pending": return .pending
        case "approved": return .payable
        case "paid": return .paid
        case "rejected": return .reversed
        default: return nil
        }
    }

    var submissionStatusLabel: String {
        switch submissionStatus?.lowercased() {
        case "pending": return "Proof under review"
        case "approved": return "Approved - payout pending"
        case "paid": return "Paid"
        case "rejected": return "Rejected"
        default: return hasApplied ? "Claimed" : "Open"
        }
    }

    var payoutLabel: String {
        if payoutCents > 0 { return payoutCents.dollarsCompact }
        if let compensationLabel, !compensationLabel.isEmpty { return compensationLabel }
        return "Payout TBD"
    }

    var isLive: Bool {
        let open = status == .live && endAt > Date()
        if isRemoteOpportunity {
            return open && (hasApplied || remainingSlots > 0)
        }
        return open && remainingSlots > 0
    }

    var schoolLabel: String {
        if schools.isEmpty { return "All campuses" }
        let names = schools.compactMap { id in sampleSchools.first { $0.id == id }?.name }
        if names.count <= 2 { return names.joined(separator: ", ") }
        return "\(names.prefix(2).joined(separator: ", ")) +\(names.count - 2)"
    }

    var spotsLabel: String {
        if hasApplied { return "Claimed" }
        if remainingSlots <= 0 { return "Full" }
        return remainingSlots == 1 ? "1 spot left" : "\(remainingSlots) spots left"
    }

    /// Submission deadline for display (API end date is inclusive UTC day).
    var deadlineLabel: String? {
        guard endAt != .distantFuture else { return nil }
        let style = Date.FormatStyle(
            date: .abbreviated, time: .omitted, timeZone: .gmt
        )
        return endAt.addingTimeInterval(-1).formatted(style)
    }

    /// Legacy alias used by older call sites.
    var applicationDeadlineLabel: String? { deadlineLabel }

    /// Blurb under the title on Discover cards (web uses action_description).
    var cardBlurb: String {
        if let first = instructions.first, !first.isEmpty { return first }
        return description
    }

    /// Web proof URL after claim (`/offers/gigs/{id}`).
    var webProofURL: URL? {
        guard isRemoteOpportunity else { return nil }
        return URL(string: "https://joincampuslink.com/offers/gigs/\(id)")
    }

    var taskLinkURL: URL? {
        guard let taskUrl, let url = URL(string: taskUrl), url.scheme == "https" else { return nil }
        return url
    }

    var timeLeftLabel: String {
        let remaining = endAt.timeIntervalSinceNow
        if remaining <= 0 { return "Ended" }
        let hours = Int(remaining / 3600)
        if hours >= 48 { return "\(hours / 24)d left" }
        if hours >= 1 { return "\(hours)h left" }
        let mins = max(1, Int(remaining / 60))
        return "\(mins)m left"
    }

    var initials: String {
        brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined()
    }

    /// Real brand mark - Clearbit is dead; prefer explicit URL, else icon.horse PNG.
    var logoUrl: String? {
        if let brandLogoUrl { return brandLogoUrl }
        guard let domain = brandDomain else { return nil }
        return "https://icon.horse/icon/\(domain)"
    }
}

enum LedgerEntryType: String {
    case pending
    case payable
    case paid
    case reversed
}

struct LedgerEntry: Identifiable, Hashable {
    let id: String
    let dropId: String
    let amountCents: Int
    var type: LedgerEntryType
    let createdAt: Date
    var note: String
}

enum AppNotificationKind: String {
    case newDrop, spotsLow, claimExpiring, approved, rejected, needsInfo, payout
}

struct AppNotification: Identifiable, Hashable {
    let id: String
    let kind: AppNotificationKind
    let title: String
    let body: String
    let createdAt: Date
    var read: Bool
    var relatedDropId: String?
}

// MARK: - Sample data helpers

private func espn(_ id: Int) -> String { "https://a.espncdn.com/i/teamlogos/ncaa/500/\(id).png" }

let sampleSchools: [School] = [
    School(id: "usc",      name: "USC",           sub: "University of Southern California",   color: Color(hex: "990000"), students: "2.1k", logoUrl: espn(30)),
    School(id: "ucla",     name: "UCLA",           sub: "University of California, Los Angeles", color: Color(hex: "2774AE"), students: "3.4k", logoUrl: espn(26)),
    School(id: "ucsb",     name: "UCSB",           sub: "UC Santa Barbara",                     color: Color(hex: "003660"), students: "1.5k", logoUrl: espn(2540)),
    School(id: "sdsu",     name: "SDSU",           sub: "San Diego State University",           color: Color(hex: "A6192E"), students: "1.8k", logoUrl: espn(21)),
    School(id: "stanford", name: "Stanford",       sub: "Stanford University",                  color: Color(hex: "8C1515"), students: "1.8k", logoUrl: espn(24)),
    School(id: "umich",    name: "Michigan",       sub: "University of Michigan",               color: Color(hex: "00274C"), students: "1.9k", logoUrl: espn(130)),
    School(id: "utexas",   name: "UT Austin",      sub: "University of Texas at Austin",        color: Color(hex: "BF5700"), students: "2.8k", logoUrl: espn(251)),
    School(id: "nyu",      name: "NYU",            sub: "New York University",                  color: Color(hex: "57068C"), students: "2.2k", logoUrl: nil),
]

func makeSampleDrops(now: Date = Date()) -> [CampusDrop] {
    [
        CampusDrop(
            id: "duet-download",
            brand: "Duet",
            brandDomain: "duetdisplay.com",
            brandColor: Color(hex: "5B5FFF"),
            title: "Install Duet and finish onboarding",
            description: "Download Duet, create an account with your school email, and complete the first tutorial screen. Submit a screenshot of the home dashboard.",
            category: .appInstall,
            payoutCents: 2500,
            maxCompletions: 100,
            remainingSlots: 92,
            schools: ["usc", "ucla", "ucsb"],
            startAt: now.addingTimeInterval(-3600),
            endAt: now.addingTimeInterval(60 * 60 * 22),
            completionWindowSeconds: 2 * 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "shot", label: "Screenshot of home dashboard", kind: .screenshot)
            ],
            instructions: [
                "Install Duet from the App Store",
                "Sign up with your .edu email",
                "Complete onboarding until you see the home dashboard",
                "Screenshot the dashboard and submit"
            ],
            eligibilityTags: ["iPhone", "Students"],
            audience: .students,
            status: .live,
            estimatedMinutes: 10
        ),
        CampusDrop(
            id: "notion-survey",
            brand: "Notion",
            brandDomain: "notion.so",
            brandColor: Color(hex: "0B0B0D"),
            title: "2-minute campus productivity survey",
            description: "Answer five questions about how you plan your week. Honest answers only. No wrong responses.",
            category: .survey,
            payoutCents: 1200,
            maxCompletions: 200,
            remainingSlots: 148,
            schools: [],
            startAt: now.addingTimeInterval(-7200),
            endAt: now.addingTimeInterval(60 * 60 * 48),
            completionWindowSeconds: 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "answers", label: "Survey responses", kind: .text)
            ],
            instructions: [
                "Open the survey brief on the next screen",
                "Answer all five prompts in your own words",
                "Submit before your claim timer ends"
            ],
            eligibilityTags: ["Any device", "Students"],
            audience: .students,
            status: .live,
            estimatedMinutes: 8
        ),
        CampusDrop(
            id: "olipop-reel",
            brand: "Olipop",
            brandDomain: "drinkolipop.com",
            brandLogoUrl: "https://drinkolipop.com/cdn/shop/files/favicon.png",
            brandColor: Color(hex: "FF6B9B"),
            title: "Post a campus taste-test Reel",
            description: "Film a short Reel tasting Olipop on campus. Keep the can visible and tag @drinkolipop. Submit the live post link.",
            category: .socialPost,
            payoutCents: 4000,
            maxCompletions: 40,
            remainingSlots: 27,
            schools: ["usc", "ucla"],
            startAt: now.addingTimeInterval(-1800),
            endAt: now.addingTimeInterval(60 * 60 * 36),
            completionWindowSeconds: 6 * 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "link", label: "Public Reel link", kind: .link),
                ProofRequirement(id: "shot", label: "Screenshot of the posted Reel", kind: .screenshot)
            ],
            instructions: [
                "Film on campus with the product in frame",
                "Post publicly and tag @drinkolipop",
                "Paste the live link and a screenshot"
            ],
            eligibilityTags: ["Creators", "Students"],
            audience: .students,
            status: .live,
            estimatedMinutes: 15
        ),
        CampusDrop(
            id: "celsius-checkin",
            brand: "Celsius",
            brandDomain: "celsius.com",
            brandColor: Color(hex: "FFD60A"),
            title: "Chapter sampling check-in",
            description: "For campus orgs only. Confirm you can host a 90-minute sampling window this week and upload a venue photo.",
            category: .survey,
            payoutCents: 7500,
            maxCompletions: 12,
            remainingSlots: 8,
            schools: ["usc", "ucla", "sdsu"],
            startAt: now.addingTimeInterval(-4000),
            endAt: now.addingTimeInterval(60 * 60 * 70),
            completionWindowSeconds: 12 * 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "shot", label: "Venue / house photo", kind: .screenshot),
                ProofRequirement(id: "text", label: "Proposed time window", kind: .text)
            ],
            instructions: [
                "Confirm org leadership approval",
                "Photo the proposed sampling location",
                "List your preferred 90-minute window"
            ],
            eligibilityTags: ["Campus orgs", "Greek / clubs"],
            audience: .orgs,
            status: .live,
            estimatedMinutes: 12
        ),
        CampusDrop(
            id: "robinhood-app",
            brand: "Robinhood",
            brandDomain: "robinhood.com",
            brandLogoUrl: "https://t1.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://robinhood.com&size=256",
            brandColor: Color(hex: "00C805"),
            title: "Open Robinhood and verify identity step",
            description: "Download Robinhood, reach the identity verification screen, and submit a screenshot. Do not submit sensitive ID details. Only the in-app progress screen.",
            category: .appInstall,
            payoutCents: 3000,
            maxCompletions: 80,
            remainingSlots: 61,
            schools: ["usc", "stanford", "ucla"],
            startAt: now.addingTimeInterval(-5000),
            endAt: now.addingTimeInterval(60 * 60 * 28),
            completionWindowSeconds: 3 * 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "shot", label: "Identity step screenshot", kind: .screenshot)
            ],
            instructions: [
                "Install Robinhood",
                "Create an account with your school email",
                "Advance to the identity verification step",
                "Screenshot that screen only. Never photograph your ID"
            ],
            eligibilityTags: ["iPhone", "18+", "Students"],
            audience: .students,
            status: .live,
            estimatedMinutes: 12
        ),
        CampusDrop(
            id: "duolingo-streak",
            brand: "Duolingo",
            brandDomain: "duolingo.com",
            brandColor: Color(hex: "58CC02"),
            title: "Share a 7-day streak screenshot",
            description: "Show a 7-day (or longer) learning streak in Duolingo. New or existing accounts both qualify.",
            category: .appInstall,
            payoutCents: 1500,
            maxCompletions: 150,
            remainingSlots: 119,
            schools: [],
            startAt: now.addingTimeInterval(-8000),
            endAt: now.addingTimeInterval(60 * 60 * 96),
            completionWindowSeconds: 24 * 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "shot", label: "Streak screenshot", kind: .screenshot)
            ],
            instructions: [
                "Open Duolingo",
                "Reach at least a 7-day streak",
                "Screenshot the streak badge or profile streak count",
                "Submit before your claim expires"
            ],
            eligibilityTags: ["Any device", "Students"],
            audience: .both,
            status: .live,
            estimatedMinutes: 5
        ),
        CampusDrop(
            id: "liquid-death-org",
            brand: "Liquid Death",
            brandDomain: "liquiddeath.com",
            brandLogoUrl: "https://liquiddeath.com/cdn/shop/files/Liquiddeath-Skull-Favicon.png",
            brandColor: Color(hex: "0E0B0B"),
            title: "Org Instagram story takeover brief",
            description: "Campus orgs: post a story frame with the Liquid Death creative kit and submit the story link plus a screenshot.",
            category: .socialPost,
            payoutCents: 10000,
            maxCompletions: 10,
            remainingSlots: 6,
            schools: ["usc", "ucla", "ucsb", "sdsu"],
            startAt: now.addingTimeInterval(-2000),
            endAt: now.addingTimeInterval(60 * 60 * 50),
            completionWindowSeconds: 8 * 60 * 60,
            proofRequirements: [
                ProofRequirement(id: "link", label: "Story or highlight link", kind: .link),
                ProofRequirement(id: "shot", label: "Screenshot of the posted story", kind: .screenshot)
            ],
            instructions: [
                "Use the provided creative guidelines",
                "Post from the official org account",
                "Submit link + screenshot within the claim window"
            ],
            eligibilityTags: ["Campus orgs", "Instagram"],
            audience: .orgs,
            status: .live,
            estimatedMinutes: 20
        ),
        CampusDrop(
            id: "spotify-feedback",
            brand: "Spotify",
            brandDomain: "spotify.com",
            brandColor: Color(hex: "1DB954"),
            title: "Campus listening habits feedback",
            description: "Tell us how you discover new music on campus. Short written answers. About five minutes.",
            category: .survey,
            payoutCents: 1000,
            maxCompletions: 300,
            remainingSlots: 244,
            schools: ["usc", "ucla", "nyu", "umich"],
            startAt: now.addingTimeInterval(-10000),
            endAt: now.addingTimeInterval(60 * 60 * 60),
            completionWindowSeconds: 45 * 60,
            proofRequirements: [
                ProofRequirement(id: "text", label: "Written responses", kind: .text)
            ],
            instructions: [
                "Answer each prompt thoughtfully",
                "No screenshots required",
                "Submit before the claim timer ends"
            ],
            eligibilityTags: ["Students", "Any device"],
            audience: .students,
            status: .live,
            estimatedMinutes: 5
        ),
    ]
}
