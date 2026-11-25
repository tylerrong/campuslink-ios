import Foundation
import AuthenticationServices
import UIKit

@Observable
@MainActor
final class AuthStore {
    static let simulatorPreviewToken = "simulator-preview"

    var sessionToken: String?
    var user: RemoteUser?
#if targetEnvironment(simulator)
    var isRestoring = false
#else
    var isRestoring = true
#endif
    var authMessage: String = ""
    var isBusy = false
    /// True when browsing with the local demo catalog (Simulator Preview or App Review). No live network.
    var isSimulatorPreview = false

    var isSignedIn: Bool { sessionToken != nil && user != nil && !(user?.isBrand ?? true) }
    var needsWebOnboarding: Bool {
        if isSimulatorPreview { return false }
        return user?.needsOnboarding == true
    }

    private var webAuthSession: ASWebAuthenticationSession?

    /// Temporary App Store / TestFlight review credentials. Remove after approval.
    /// Put these in App Store Connect → TestFlight → Test Information (Sign-in required).
    enum AppReviewLogin {
        static let username = "apple@review.campuslink.com"
        static let password = "CampusLinkReview1"
    }

    init() {
#if targetEnvironment(simulator)
        // Simulator starts signed out so Welcome → Sign in can be reviewed.
        // Use App Review fields or “Preview app (Simulator)” to open the main shell.
        isSimulatorPreview = false
        sessionToken = nil
        user = nil
        isRestoring = false
#else
        Task { await restoreSession() }
#endif
    }

    func restoreSession() async {
        isRestoring = true
        defer { isRestoring = false }
        guard let token = KeychainStore.loadToken() else {
            sessionToken = nil
            user = nil
            isSimulatorPreview = false
            return
        }
        if token == Self.simulatorPreviewToken || token.count < 20 {
            // Never persist simulator preview across launches via Keychain.
            KeychainStore.clearToken()
            sessionToken = nil
            user = nil
            isSimulatorPreview = false
            return
        }
        do {
            let me = try await APIClient.shared.fetchMe(token: token)
            sessionToken = token
            user = me
            isSimulatorPreview = false
        } catch {
            KeychainStore.clearToken()
            sessionToken = nil
            user = nil
            isSimulatorPreview = false
        }
    }

    /// Local demo session with sample Drops (no live API). Used by Simulator Preview + App Review login.
    func enterDemoPreview(asOrg: Bool = false) {
        KeychainStore.clearToken()
        isSimulatorPreview = true
        sessionToken = Self.simulatorPreviewToken
        user = .simulatorPreview(asOrg: asOrg)
        authMessage = ""
        isBusy = false
        isRestoring = false
    }

#if targetEnvironment(simulator)
    /// Skip magic/Google auth so UI can be reviewed in Simulator.
    func enterSimulatorPreview(asOrg: Bool = false) {
        enterDemoPreview(asOrg: asOrg)
    }
#endif

    /// Username / password path for Apple App Review (maps to ASC demo account fields).
    func signInWithAppReview(username: String, password: String) throws {
        let user = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard user.compare(AppReviewLogin.username, options: .caseInsensitive) == .orderedSame,
              pass == AppReviewLogin.password else {
            throw APIError.message("Invalid username or password.")
        }
        enterDemoPreview(asOrg: false)
    }

    func requestMagicLink(email: String) async throws {
        isBusy = true
        defer { isBusy = false }
        authMessage = try await APIClient.shared.requestMagicLink(email: email)
    }

    func completeMagicLink(token t: String) async throws {
        isBusy = true
        defer { isBusy = false }
        let result = try await APIClient.shared.exchangeMagicToken(t)
        // Auth exchange returns a thin user - load full campus profile from /me.
        await persist(token: result.token, user: result.user, refreshProfile: true)
    }

    func completeSessionToken(_ token: String) async throws {
        isBusy = true
        defer { isBusy = false }
        let me = try await APIClient.shared.fetchMe(token: token)
        await persist(token: token, user: me, refreshProfile: false)
    }

    func signInWithGoogle() async throws {
        isBusy = true
        defer {
            isBusy = false
            webAuthSession = nil
        }

        let startURL = await APIClient.shared.googleStartURL

        let token: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            let session = ASWebAuthenticationSession(
                url: startURL,
                callbackURLScheme: "campuslink"
            ) { callbackURL, error in
                if let error {
                    let ns = error as NSError
                    if ns.domain == ASWebAuthenticationSessionErrorDomain,
                       ns.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: APIError.message("Google sign-in cancelled."))
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                guard let callbackURL else {
                    continuation.resume(throwing: APIError.message("Google sign-in was cancelled."))
                    return
                }

                let path = [callbackURL.host, callbackURL.path]
                    .compactMap { $0 }
                    .joined(separator: "/")
                    .lowercased()
                let items = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems

                if path.contains("error") {
                    let reason = items?.first(where: { $0.name == "reason" })?.value
                    if reason == "brand_not_supported" {
                        continuation.resume(throwing: APIError.brandNotSupported)
                    } else {
                        continuation.resume(throwing: APIError.message(reason ?? "Google sign-in failed"))
                    }
                    return
                }

                if let token = items?.first(where: { $0.name == "token" })?.value,
                   !token.isEmpty {
                    continuation.resume(returning: token.removingPercentEncoding ?? token)
                } else {
                    continuation.resume(throwing: APIError.message("Missing session from Google sign-in."))
                }
            }
            session.prefersEphemeralWebBrowserSession = false
            session.presentationContextProvider = WebAuthPresenter.shared
            self.webAuthSession = session
            if !session.start() {
                continuation.resume(throwing: APIError.message("Could not start Google sign-in."))
            }
        }

        try await completeSessionToken(token)
    }

    func handleIncomingURL(_ url: URL) async {
        guard url.scheme == "campuslink" else { return }
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let path = [url.host, url.path]
            .compactMap { $0 }
            .joined(separator: "/")
            .lowercased()

        if path.contains("error") {
            let reason = items?.first(where: { $0.name == "reason" })?.value
            authMessage = reason == "brand_not_supported"
                ? (APIError.brandNotSupported.localizedDescription ?? "")
                : (reason ?? "Sign-in failed")
            return
        }

        if path.contains("magic"), let t = items?.first(where: { $0.name == "t" })?.value {
            let token = t.removingPercentEncoding ?? t
            do {
                try await completeMagicLink(token: token)
            } catch {
                authMessage = error.localizedDescription
            }
            return
        }

        if path.contains("session"), let token = items?.first(where: { $0.name == "token" })?.value {
            let session = token.removingPercentEncoding ?? token
            do {
                try await completeSessionToken(session)
            } catch {
                authMessage = error.localizedDescription
            }
        }
    }

    func completeOnboarding(_ body: OnboardingRequest) async throws {
        guard let token = sessionToken, !isSimulatorPreview else {
            throw APIError.message("Sign in again to finish your profile.")
        }
        isBusy = true
        defer { isBusy = false }
        let result = try await APIClient.shared.completeOnboarding(token: token, body: body)
        // Prefer reminted JWT so subsequent /me and Claim see registration_completed.
        if let newToken = result.token, !newToken.isEmpty {
            await persist(token: newToken, user: result.user, refreshProfile: true)
        } else {
            self.user = result.user
            authMessage = ""
        }
    }

    func signOut() {
        KeychainStore.clearToken()
        sessionToken = nil
        user = nil
        isSimulatorPreview = false
        authMessage = ""
        isBusy = false
    }

    private func persist(token: String, user: RemoteUser, refreshProfile: Bool = false) async {
        if user.isBrand {
            KeychainStore.clearToken()
            sessionToken = nil
            self.user = nil
            authMessage = APIError.brandNotSupported.localizedDescription ?? ""
            return
        }
        KeychainStore.saveToken(token)
        sessionToken = token
        if refreshProfile, let me = try? await APIClient.shared.fetchMe(token: token) {
            self.user = me
        } else {
            self.user = user
        }
        authMessage = ""
    }
}

private final class WebAuthPresenter: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = WebAuthPresenter()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        return scene?.windows.first(where: \.isKeyWindow)
            ?? scene?.windows.first
            ?? ASPresentationAnchor()
    }
}
