import SwiftUI

struct SignInView: View {
    @Bindable var auth: AuthStore
    let theme: CLTheme

    @State private var email = ""
    @State private var linkSent = false
    @State private var localError = ""
    @State private var reviewUsername = ""
    @State private var reviewPassword = ""

    var body: some View {
        ZStack {
            theme.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 48)

                    VStack(spacing: 12) {
                        CLLogo(size: 36, tone: .black, style: .wordmark)
                            .accessibilityLabel("CampusLink")

                        Text("Sign in or create an account. Students and campus orgs only.")
                            .font(.bodyFont(15))
                            .foregroundColor(theme.textMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                    }

                    Spacer(minLength: 36)

                    VStack(spacing: 14) {
                        if linkSent {
                            VStack(spacing: 10) {
                                Image(systemName: "envelope.open.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(theme.primary)
                                Text("Check your email")
                                    .font(.display(20, weight: .bold))
                                Text(auth.authMessage.isEmpty
                                      ? "Open the link on this phone to finish signing in."
                                      : auth.authMessage)
                                    .font(.bodyFont(14))
                                    .foregroundColor(theme.textMuted)
                                    .multilineTextAlignment(.center)
                                Button("Use a different email") {
                                    linkSent = false
                                    email = ""
                                }
                                .font(.bodyFont(14, weight: .semibold))
                                .foregroundColor(theme.primary)
                            }
                            .padding(24)
                        } else {
                            TextField("you@school.edu", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(theme.surface)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(theme.line, lineWidth: 1)
                                )

                            CLButton(
                                label: auth.isBusy ? "Sending…" : "Email me a sign-in link",
                                kind: .primary,
                                size: .lg,
                                full: true,
                                theme: theme
                            ) {
                                Task { await sendMagic() }
                            }
                            .disabled(auth.isBusy || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .opacity(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                            dividerLabel("or")

                            CLButton(
                                label: auth.isBusy ? "Opening Google…" : "Continue with Google",
                                kind: .surface,
                                size: .lg,
                                full: true,
                                theme: theme
                            ) {
                                Task { await google() }
                            }
                            .disabled(auth.isBusy)

                            // MARK: Temporary App Review login (remove after approval)
                            appReviewSection

#if targetEnvironment(simulator)
                            Button {
                                haptic(.light)
                                auth.enterSimulatorPreview()
                            } label: {
                                Text("Preview app (Simulator)")
                                    .font(.bodyFont(14, weight: .semibold))
                                    .foregroundColor(theme.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 8)
                            }
                            .buttonStyle(.plain)
                            .disabled(auth.isBusy)
#endif
                        }

                        if !localError.isEmpty {
                            Text(localError)
                                .font(.bodyFont(13, weight: .medium))
                                .foregroundColor(theme.primary)
                                .multilineTextAlignment(.center)
                        } else if !auth.authMessage.isEmpty && !linkSent {
                            Text(auth.authMessage)
                                .font(.bodyFont(13, weight: .medium))
                                .foregroundColor(theme.primary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 36)

                    Text("Brands: post Drops at joincampuslink.com")
                        .font(.bodyFont(12))
                        .foregroundColor(theme.textMuted)
                        .padding(.bottom, 28)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var appReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            dividerLabel("App Review")

            Text("For Apple App Review only. Use the username and password from App Store Connect.")
                .font(.bodyFont(12))
                .foregroundColor(theme.textFaint)
                .fixedSize(horizontal: false, vertical: true)

            TextField("User Name", text: $reviewUsername)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textContentType(.username)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
                .accessibilityLabel("App Review user name")

            SecureField("Password", text: $reviewPassword)
                .textContentType(.password)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(theme.line, lineWidth: 1)
                )
                .accessibilityLabel("App Review password")

            CLButton(
                label: auth.isBusy ? "Signing in…" : "Sign in for App Review",
                kind: .ink,
                size: .lg,
                showsChevron: false,
                full: true,
                theme: theme
            ) {
                Task { await appReviewSignIn() }
            }
            .disabled(auth.isBusy || !canSubmitAppReview)
            .opacity(canSubmitAppReview ? 1 : 0.5)
        }
        .padding(.top, 8)
    }

    private var canSubmitAppReview: Bool {
        !reviewUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reviewPassword.isEmpty
    }

    private func dividerLabel(_ text: String) -> some View {
        HStack {
            Rectangle().fill(theme.line).frame(height: 1)
            Text(text)
                .font(.bodyFont(12, weight: .medium))
                .foregroundColor(theme.textMuted)
            Rectangle().fill(theme.line).frame(height: 1)
        }
        .padding(.vertical, 4)
    }

    private func sendMagic() async {
        localError = ""
        do {
            try await auth.requestMagicLink(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
            linkSent = true
        } catch {
            localError = error.localizedDescription
        }
    }

    private func google() async {
        localError = ""
        do {
            try await auth.signInWithGoogle()
        } catch {
            localError = error.localizedDescription
        }
    }

    private func appReviewSignIn() async {
        localError = ""
        do {
            try auth.signInWithAppReview(username: reviewUsername, password: reviewPassword)
            haptic(.medium)
        } catch {
            localError = error.localizedDescription
        }
    }
}
