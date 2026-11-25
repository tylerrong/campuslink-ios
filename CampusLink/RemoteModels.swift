import Foundation
import SwiftUI

struct RemoteSchool: Codable, Hashable {
    let id: Int
    let name: String
    let short_name: String
    let primary_color: String?
    let secondary_color: String?
    let city: String?
    /// Absolute ESPN/catalog PNG from mobile /me when available.
    let logo_url: String?
}

struct RemoteStudentProfile: Codable, Hashable {
    let full_name: String?
    let graduation_year: Int?
    let major: String?
    let bio: String?
    let interests: String?
    let student_type: String?
    let sport: String?
    let instagram_handle: String?
    let tiktok_handle: String?
    let linkedin_url: String?
    let portfolio_link: String?
}

struct RemoteOrgProfile: Codable, Hashable {
    let org_name: String?
    let org_type: String?
    let member_count: Int?
    let bio: String?
    let instagram_handle: String?
    let tiktok_handle: String?
    let website: String?
    let portfolio_link: String?
}

struct RemoteUser: Hashable {
    let id: Int
    let email: String
    let name: String
    let role: String
    let profile_type: String?
    let registration_completed: Bool
    let picture: String?
    var school_id: Int? = nil
    var school: RemoteSchool? = nil
    var student: RemoteStudentProfile? = nil
    var org: RemoteOrgProfile? = nil

    init(
        id: Int,
        email: String,
        name: String,
        role: String,
        profile_type: String?,
        registration_completed: Bool,
        picture: String?,
        school_id: Int? = nil,
        school: RemoteSchool? = nil,
        student: RemoteStudentProfile? = nil,
        org: RemoteOrgProfile? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.profile_type = profile_type
        self.registration_completed = registration_completed
        self.picture = picture
        self.school_id = school_id
        self.school = school
        self.student = student
        self.org = org
    }

    var isCampusProfile: Bool {
        profile_type == nil || profile_type == "student" || profile_type == "campus_org"
    }

    var isBrand: Bool { profile_type == "brand" }

    var needsOnboarding: Bool {
        // Admins can use the app without campus onboarding
        if role == "admin" { return false }
        return !registration_completed || profile_type == nil
    }

    var displayFullName: String {
        if profile_type == "campus_org" {
            let orgName = org?.org_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !orgName.isEmpty { return orgName }
        } else {
            let full = student?.full_name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !full.isEmpty { return full }
        }
        let fallback = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return fallback.isEmpty ? "You" : fallback
    }

    /// Local-only mock used to skip auth in the iOS Simulator.
    static func simulatorPreview(asOrg: Bool = false) -> RemoteUser {
        let school = RemoteSchool(
            id: 1,
            name: "University of California, Los Angeles",
            short_name: "UCLA",
            primary_color: "#2774AE",
            secondary_color: "#FFD100",
            city: "Los Angeles",
            logo_url: "https://a.espncdn.com/i/teamlogos/ncaa/500/26.png"
        )
        if asOrg {
            return RemoteUser(
                id: -1,
                email: "preview@ucla.edu",
                name: "Campus Preview Org",
                role: "user",
                profile_type: "campus_org",
                registration_completed: true,
                picture: nil,
                school_id: school.id,
                school: school,
                org: RemoteOrgProfile(
                    org_name: "Campus Preview Org",
                    org_type: "club",
                    member_count: 120,
                    bio: "Simulator preview profile — not a live account.",
                    instagram_handle: "campuslink",
                    tiktok_handle: "campuslink",
                    website: "https://joincampuslink.com",
                    portfolio_link: nil
                )
            )
        }
        return RemoteUser(
            id: -1,
            email: "preview@ucla.edu",
            name: "Alex Preview",
            role: "user",
            profile_type: "student",
            registration_completed: true,
            picture: nil,
            school_id: school.id,
            school: school,
            student: RemoteStudentProfile(
                full_name: "Alex Preview",
                graduation_year: 2027,
                major: "Computer Science",
                bio: "Simulator preview profile — not a live account.",
                interests: "Apps & tech, Content, Startups",
                student_type: "ambassador",
                sport: nil,
                instagram_handle: "alexpreview",
                tiktok_handle: "alexpreview",
                linkedin_url: "https://linkedin.com/in/alexpreview",
                portfolio_link: nil
            )
        )
    }
}

extension RemoteUser: Codable {
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, profile_type, registration_completed, picture, school_id
        case school, student, org
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        email = try c.decode(String.self, forKey: .email)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        role = try c.decodeIfPresent(String.self, forKey: .role) ?? "user"
        profile_type = try c.decodeIfPresent(String.self, forKey: .profile_type)
        picture = try c.decodeIfPresent(String.self, forKey: .picture)
        school_id = try c.decodeIfPresent(Int.self, forKey: .school_id)
        school = try c.decodeIfPresent(RemoteSchool.self, forKey: .school)
        student = try c.decodeIfPresent(RemoteStudentProfile.self, forKey: .student)
        org = try c.decodeIfPresent(RemoteOrgProfile.self, forKey: .org)
        // Accept bool or 0/1 from older JWTs / D1 coercion
        if let b = try? c.decode(Bool.self, forKey: .registration_completed) {
            registration_completed = b
        } else if let i = try? c.decode(Int.self, forKey: .registration_completed) {
            registration_completed = i != 0
        } else {
            registration_completed = false
        }
    }
}

struct RemoteOpportunityBrand: Codable, Hashable {
    let user_id: Int
    let name: String
    let company_name: String?
    let industry: String?
    let website: String?
    let picture: String?
}

struct RemoteOpportunity: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let start_date: String
    let end_date: String
    let status: String
    let offer_type: String?
    let image_url: String?
    let user_has_expressed_interest: Bool
    let brand: RemoteOpportunityBrand
}

struct AuthSessionResponse: Codable {
    let success: Bool
    let token: String?
    let user: RemoteUser?
    let error: String?
    let code: String?
}

struct MeResponse: Codable {
    let success: Bool
    let user: RemoteUser?
    let error: String?
}

struct OpportunitiesResponse: Codable {
    let success: Bool
    let opportunities: [RemoteOpportunity]?
    let error: String?
}

struct ApplyResponse: Codable {
    let success: Bool
    let message: String?
    let already_applied: Bool?
    let error: String?
    let code: String?
    let onboarding_url: String?
}

struct MagicSendResponse: Codable {
    let success: Bool
    let message: String?
    let error: String?
}

enum APIError: LocalizedError {
    case message(String)
    case brandNotSupported
    case unauthorized
    case registrationRequired(URL?)

    var errorDescription: String? {
        switch self {
        case .message(let m): return m
        case .brandNotSupported:
            return "Brand accounts manage opportunities on joincampuslink.com. This app is for students and campus orgs."
        case .unauthorized: return "Please sign in again."
        case .registrationRequired: return "Finish setting up your profile on joincampuslink.com."
        }
    }
}

extension CampusDrop {
    /// Map a joincampuslink opportunity into the existing Drop card model.
    static func fromOpportunity(_ opp: RemoteOpportunity) -> CampusDrop {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        let start = formatter.date(from: opp.start_date) ?? Date()
        let end = formatter.date(from: opp.end_date) ?? Date().addingTimeInterval(86400 * 14)
        let domain: String? = {
            guard let site = opp.brand.website, let host = URL(string: site)?.host else { return nil }
            return host.replacingOccurrences(of: "www.", with: "")
        }()

        let palette: [Color] = [
            Color(red: 0.91, green: 0.27, blue: 0.35),
            Color(red: 0.20, green: 0.45, blue: 0.95),
            Color(red: 0.18, green: 0.72, blue: 0.55),
            Color(red: 0.95, green: 0.55, blue: 0.18),
            Color(red: 0.45, green: 0.30, blue: 0.85)
        ]
        let color = palette[abs(opp.id) % palette.count]

        return CampusDrop(
            id: String(opp.id),
            brand: opp.brand.company_name ?? opp.brand.name,
            brandDomain: domain,
            brandLogoUrl: opp.brand.picture ?? opp.image_url,
            brandColor: color,
            title: opp.title,
            description: opp.description,
            category: .survey,
            payoutCents: 0,
            maxCompletions: 1,
            remainingSlots: 1,
            schools: [],
            startAt: start,
            endAt: end,
            completionWindowSeconds: 0,
            proofRequirements: [],
            instructions: [
                "Review the opportunity details.",
                "Tap Apply to express interest.",
                "The brand will follow up on CampusLink if you're a fit."
            ],
            eligibilityTags: [opp.brand.industry].compactMap { $0 }.filter { !$0.isEmpty },
            audience: .both,
            status: opp.status == "active" && end > Date() ? .live : .ended,
            estimatedMinutes: 5,
            isRemoteOpportunity: true,
            hasApplied: opp.user_has_expressed_interest
        )
    }
}
