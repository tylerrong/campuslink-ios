import Foundation
import AuthenticationServices
import UIKit

@Observable
@MainActor
final class AuthStore {
    var sessionToken: String?
    var user: RemoteUser?
    var isRestoring = true
    var authMessage: String = ""
    var isBusy = false

    var isSignedIn: Bool { sessionToken != nil && user != nil && !(user?.isBrand ?? true) }
    var needsWebOnboarding: Bool { user?.needsOnboarding == true }

    private var webAuthSession: ASWebAuthenticationSession?

    init() {
        Task { await restoreSession() }
    }

    func restoreSession() async {
        isRestoring = true
        defer { isRestoring = false }
        guard let token = KeychainStore.loadToken() else {
            sessionToken = nil
            user = nil
            return
        }
        do {
            let me = try await APIClient.shared.fetchMe(token: token)
            sessionToken = token
            user = me
        } catch {
            KeychainStore.clearToken()
            sessionToken = nil
            user = nil
        }
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
        persist(token: result.token, user: result.user)
    }

    func completeSessionToken(_ token: String) async throws {
        isBusy = true
        defer { isBusy = false }
        let me = try await APIClient.shared.fetchMe(token: token)
        persist(token: token, user: me)
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

    func signOut() {
        KeychainStore.clearToken()
        sessionToken = nil
        user = nil
        authMessage = ""
        isBusy = false
    }

    private func persist(token: String, user: RemoteUser) {
        if user.isBrand {
            KeychainStore.clearToken()
            sessionToken = nil
            self.user = nil
            authMessage = APIError.brandNotSupported.localizedDescription ?? ""
            return
        }
        KeychainStore.saveToken(token)
        sessionToken = token
        self.user = user
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
