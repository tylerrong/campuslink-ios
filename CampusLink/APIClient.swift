import Foundation

actor APIClient {
    static let shared = APIClient()

    private let baseURL = URL(string: "https://joincampuslink.com/api/mobile/v1")!
    private let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 30
        // Don't stall forever on sim/poor networks during session restore
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()

    func requestMagicLink(email: String) async throws -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmed.contains("@"), trimmed.contains(".") else {
            throw APIError.message("Enter a valid email address.")
        }
        let body = try JSONEncoder().encode(["email": trimmed])
        let (data, status) = try await send(path: "auth/magic", method: "POST", body: body, authed: false)
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(MagicSendResponse.self, from: data)
        guard res.success else { throw APIError.message(res.error ?? "Could not send email") }
        return res.message ?? "Check your email for a sign-in link."
    }

    func exchangeMagicToken(_ t: String) async throws -> (token: String, user: RemoteUser) {
        let body = try JSONEncoder().encode(["t": t])
        let (data, status) = try await send(path: "auth/magic/exchange", method: "POST", body: body, authed: false)
        try throwIfHTTPError(status: status, data: data)
        return try decodeSession(data)
    }

    func signInWithGoogleIDToken(_ idToken: String) async throws -> (token: String, user: RemoteUser) {
        let body = try JSONEncoder().encode(["idToken": idToken])
        let (data, status) = try await send(path: "auth/google", method: "POST", body: body, authed: false)
        try throwIfHTTPError(status: status, data: data)
        return try decodeSession(data)
    }

    func fetchMe(token: String) async throws -> RemoteUser {
        let (data, status) = try await send(path: "me", method: "GET", body: nil, authed: true, token: token)
        if status == 401 { throw APIError.unauthorized }
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(MeResponse.self, from: data)
        guard res.success, let user = res.user else {
            throw APIError.message(res.error ?? "Could not load profile")
        }
        if user.isBrand { throw APIError.brandNotSupported }
        return user
    }

    func fetchSchools(token: String, query: String = "", limit: Int = 40) async throws -> [RemoteSchool] {
        var path = "schools?limit=\(limit)"
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty, let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            path += "&q=\(encoded)"
        }
        let (data, status) = try await send(path: path, method: "GET", body: nil, authed: true, token: token)
        if status == 401 { throw APIError.unauthorized }
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(SchoolsResponse.self, from: data)
        guard res.success else { throw APIError.message(res.error ?? "Could not load schools") }
        return res.schools ?? []
    }

    func completeOnboarding(token: String, body: OnboardingRequest) async throws -> (token: String?, user: RemoteUser) {
        let encoded = try JSONEncoder().encode(body)
        let (data, status) = try await send(path: "onboarding", method: "POST", body: encoded, authed: true, token: token)
        if status == 401 { throw APIError.unauthorized }
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(MeResponse.self, from: data)
        guard res.success, let user = res.user else {
            throw APIError.message(res.error ?? "Could not complete profile")
        }
        if user.isBrand { throw APIError.brandNotSupported }
        return (res.token, user)
    }

    func fetchOpportunities(token: String) async throws -> [RemoteOpportunity] {
        let (data, status) = try await send(path: "opportunities", method: "GET", body: nil, authed: true, token: token)
        if status == 401 { throw APIError.unauthorized }
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(OpportunitiesResponse.self, from: data)
        guard res.success else { throw APIError.message(res.error ?? "Could not load opportunities") }
        return res.opportunities ?? []
    }

    func fetchApplied(token: String) async throws -> [RemoteOpportunity] {
        let (data, status) = try await send(path: "opportunities/applied", method: "GET", body: nil, authed: true, token: token)
        if status == 401 { throw APIError.unauthorized }
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(OpportunitiesResponse.self, from: data)
        guard res.success else { throw APIError.message(res.error ?? "Could not load applied list") }
        return res.opportunities ?? []
    }

    func apply(opportunityId: String, token: String) async throws -> Bool {
        let (data, status) = try await send(
            path: "opportunities/\(opportunityId)/apply",
            method: "POST",
            body: nil,
            authed: true,
            token: token
        )
        if let res = try? JSONDecoder().decode(ApplyResponse.self, from: data),
           res.code == "registration_required" {
            let url = res.onboarding_url.flatMap(URL.init(string:))
            throw APIError.registrationRequired(url)
        }
        if status == 401 { throw APIError.unauthorized }
        try throwIfHTTPError(status: status, data: data)
        let res = try JSONDecoder().decode(ApplyResponse.self, from: data)
        guard res.success else { throw APIError.message(res.error ?? "Could not apply") }
        return res.already_applied != true
    }

    var googleStartURL: URL {
        URL(string: baseURL.absoluteString + "/auth/google/start")!
    }

    private func decodeSession(_ data: Data) throws -> (token: String, user: RemoteUser) {
        let res = try JSONDecoder().decode(AuthSessionResponse.self, from: data)
        if res.code == "brand_not_supported" { throw APIError.brandNotSupported }
        guard res.success, let token = res.token, let user = res.user else {
            throw APIError.message(res.error ?? "Sign-in failed")
        }
        if user.isBrand { throw APIError.brandNotSupported }
        return (token, user)
    }

    private func throwIfHTTPError(status: Int, data: Data) throws {
        if status == 403 {
            if let res = try? JSONDecoder().decode(AuthSessionResponse.self, from: data),
               res.code == "brand_not_supported" {
                throw APIError.brandNotSupported
            }
            if let res = try? JSONDecoder().decode(ApplyResponse.self, from: data),
               res.code == "registration_required" {
                throw APIError.registrationRequired(res.onboarding_url.flatMap(URL.init(string:)))
            }
            let msg = (try? JSONDecoder().decode(AuthSessionResponse.self, from: data))?.error
            throw APIError.message(msg ?? "Forbidden")
        }
        if status >= 500 {
            let msg = (try? JSONDecoder().decode(AuthSessionResponse.self, from: data))?.error
            throw APIError.message(msg ?? "Server error. Try again in a moment.")
        }
        if status == 404 {
            throw APIError.message("Service unavailable. Please update the app or try again later.")
        }
        if !(200..<300).contains(status), status != 401 {
            let msg = (try? JSONDecoder().decode(AuthSessionResponse.self, from: data))?.error
            throw APIError.message(msg ?? "Request failed (\(status))")
        }
    }

    private func send(
        path: String,
        method: String,
        body: Data?,
        authed: Bool,
        token: String? = nil
    ) async throws -> (Data, Int) {
        guard let url = URL(string: baseURL.absoluteString + "/" + path) else {
            throw APIError.message("Invalid request URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        if authed, let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            return (data, status)
        } catch let error as URLError where error.code == .timedOut {
            throw APIError.message("Connection timed out. Check your network and try again.")
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw APIError.message("No internet connection.")
        } catch {
            throw APIError.message(error.localizedDescription)
        }
    }
}
