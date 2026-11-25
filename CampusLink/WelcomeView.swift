import SwiftUI

/// Pre-auth welcome - solid brand red, high-contrast type, then hand off to SignInView.
struct WelcomeView: View {
    let theme: CLTheme
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            theme.primary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                hero
                    .padding(.horizontal, 28)

                Spacer(minLength: 48)

                footer
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
            }
        }
        .onAppear { runEntrance() }
        .accessibilityElement(children: .contain)
    }

    private var hero: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 112, height: 112)
                    .scaleEffect(appeared ? (pulse ? 1.05 : 1.0) : 0.72)

                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 88, height: 88)

                CLLogo(size: 42, tone: .white, style: .mark)
                    .scaleEffect(appeared ? 1 : 0.55)
                    .opacity(appeared ? 1 : 0)
            }
            .accessibilityHidden(true)

            VStack(spacing: 14) {
                CLLogo(size: 26, tone: .white, style: .wordmark)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .accessibilityLabel("CampusLink")

                Text("CampusLink Drops")
                    .font(.display(34, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .tracking(-0.6)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 14)

                Text("Claim brand Drops, submit proof, and cash out. Built for students and campus orgs.")
                    .font(.bodyFont(16))
                    .foregroundColor(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 14) {
            Button {
                haptic(.medium)
                onContinue()
            } label: {
                HStack(spacing: 8) {
                    Text("Get started")
                        .font(.bodyFont(16, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(theme.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(CLPressStyle())
            .accessibilityLabel("Get started")
            .accessibilityHint("Continue to sign in")

            Text("Students and campus orgs. Brands post on the web.")
                .font(.bodyFont(12))
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(.center)
        }
    }

    private func runEntrance() {
        guard !appeared else { return }

        if reduceMotion {
            appeared = true
            pulse = false
            return
        }

        withAnimation(.spring(response: 0.62, dampingFraction: 0.78)) {
            appeared = true
        }

        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}

#Preview {
    WelcomeView(theme: .light(), onContinue: {})
}
