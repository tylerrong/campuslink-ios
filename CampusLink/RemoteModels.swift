import Foundation
import SwiftUI

struct RemoteUser: Hashable {
    let id: Int
    let email: String
    let name: String
    let role: String
    let profile_type: String?
    let registration_completed: Bool
    let picture: String?
    var school_id: Int? = nil

    var isCampusProfile: Bool {
        profile_type == nil || profile_type == "student" || profile_type == "campus_org"
    }

    var isBrand: Bool { profile_type == "brand" }

    var needsOnboarding: Bool {
        // Admins can use the app without campus onboarding
        if role == "admin" { return false }
        return !registration_completed || profile_type == nil
    }
}

extension RemoteUser: Codable {
    enum CodingKeys: String, CodingKey {
        case id, email, name, role, profile_type, registration_completed, picture, school_id
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
