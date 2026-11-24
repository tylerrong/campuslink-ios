import SwiftUI

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

enum OrgType: String, CaseIterable, Identifiable {
    case greek = "Greek life"
    case club = "Club"
    case team = "Team"
    case creator = "Creator collective"

    var id: String { rawValue }
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

struct Interest: Identifiable {
    let id: String
    let label: String
    let icon: String
}

// MARK: - Drops

enum DropCategory: String, CaseIterable, Identifiable {
    case appInstall = "App install"
    case survey = "Survey"
    case socialPost = "Social post"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .appInstall: "arrow.down.app"
        case .survey: "list.bullet.clipboard"
        case .socialPost: "camera"
        }
    }

    var estimatedMinutes: Int {
        switch self {
        case .appInstall: 10
        case .survey: 8
        case .socialPost: 15
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
        estimatedMinutes: Int
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
    }

    var payoutLabel: String { payoutCents.dollarsCompact }

    var isLive: Bool {
        status == .live && endAt > Date() && remainingSlots > 0
    }

    var schoolLabel: String {
        if schools.isEmpty { return "All campuses" }
        let names = schools.compactMap { id in sampleSchools.first { $0.id == id }?.name }
        if names.count <= 2 { return names.joined(separator: ", ") }
        return "\(names.prefix(2).joined(separator: ", ")) +\(names.count - 2)"
    }

    var spotsLabel: String {
        "\(remainingSlots)/\(maxCompletions) spots left"
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

    /// Real brand mark — Clearbit is dead; prefer explicit URL, else icon.horse PNG.
    var logoUrl: String? {
        if let brandLogoUrl { return brandLogoUrl }
        guard let domain = brandDomain else { return nil }
        return "https://icon.horse/icon/\(domain)"
    }
}

enum ClaimStatus: String {
    case claimed, submitted, expired
}

struct DropClaim: Identifiable, Hashable {
    let id: String
    let dropId: String
    let acceptedAt: Date
    var expiresAt: Date
    var status: ClaimStatus
}

enum ReviewStatus: String, CaseIterable, Identifiable {
    case pending = "Pending review"
    case approved = "Approved"
    case rejected = "Rejected"
    case needsInfo = "Needs more info"

    var id: String { rawValue }
}

struct DropSubmission: Identifiable, Hashable {
    let id: String
    let claimId: String
    let dropId: String
    var imageData: Data?
    var link: String
    var answer: String
    var reviewStatus: ReviewStatus
    var rejectionReason: String?
    var submittedAt: Date
    var reviewedAt: Date?
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
    School(id: "ucsb",     name: "UCSB",           sub: "UC Santa Barbara",                     color: Color(hex: "003660"), students: "1.5k", logoUrl: espn(12)),
    School(id: "sdsu",     name: "SDSU",           sub: "San Diego State University",           color: Color(hex: "A6192E"), students: "1.8k", logoUrl: espn(21)),
    School(id: "stanford", name: "Stanford",       sub: "Stanford University",                  color: Color(hex: "8C1515"), students: "1.8k", logoUrl: espn(24)),
    School(id: "umich",    name: "Michigan",       sub: "University of Michigan",               color: Color(hex: "00274C"), students: "1.9k", logoUrl: espn(130)),
    School(id: "utexas",   name: "UT Austin",      sub: "University of Texas at Austin",        color: Color(hex: "BF5700"), students: "2.8k", logoUrl: espn(251)),
    School(id: "nyu",      name: "NYU",            sub: "New York University",                  color: Color(hex: "57068C"), students: "2.2k", logoUrl: nil),
]

let studentInterests: [Interest] = [
    Interest(id: "apps", label: "Apps & tech", icon: "iphone"),
    Interest(id: "content", label: "Content", icon: "video"),
    Interest(id: "foodbev", label: "Food & bev", icon: "cup.and.saucer"),
    Interest(id: "fitness", label: "Fitness", icon: "figure.run"),
    Interest(id: "finance", label: "Finance", icon: "dollarsign.circle"),
    Interest(id: "fashion", label: "Fashion", icon: "tshirt"),
    Interest(id: "gaming", label: "Gaming", icon: "gamecontroller"),
    Interest(id: "social", label: "Social impact", icon: "heart"),
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
            description: "Answer five questions about how you plan your week. Honest answers only — no wrong responses.",
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
            description: "Download Robinhood, reach the identity verification screen, and submit a screenshot. Do not submit sensitive ID details — only the in-app progress screen.",
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
                "Screenshot that screen only — never photograph your ID"
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
            description: "Tell us how you discover new music on campus. Short written answers — about five minutes.",
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
