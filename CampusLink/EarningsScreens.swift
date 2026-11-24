import SwiftUI

// MARK: - Earnings
struct EarningsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        CLScrollView(theme: theme, bottomFade: 40) {
            VStack(alignment: .leading, spacing: 0) {
                CLScreenHeader(
                    title: "Earnings",
                    subtitle: "Escrow in, cash out when you're ready.",
                    theme: theme
                )

                balanceCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)

                HStack(spacing: 12) {
                    CLColorStatCard(
                        title: "Pending",
                        value: state.pendingBalanceCents.dollarsCompact,
                        detail: "in escrow",
                        icon: "hourglass",
                        fill: theme.accentOrange,
                        compact: true
                    )
                    CLColorStatCard(
                        title: "Cashed out",
                        value: state.paidTotalCents.dollarsCompact,
                        detail: "all time",
                        icon: "checkmark.circle.fill",
                        fill: theme.accentBlue,
                        compact: true
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 22)

                SectionHead(title: "Ledger", theme: theme)

                if state.ledger.isEmpty {
                    CLEmptyState(
                        icon: "banknote",
                        title: "No earnings yet",
                        subtitle: "Approved Drop payouts land here. Pending funds stay in escrow until verified.",
                        actionLabel: "Browse Drops",
                        action: { state.setTab(.drops) },
                        theme: theme
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(state.ledger) { entry in
                            ledgerRow(entry)
                            if entry.id != state.ledger.last?.id {
                                theme.line.frame(height: 1).padding(.leading, 20)
                            }
                        }
                    }
                    .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 18, shadow: 0, borderWidth: theme.borderThinWidth)
                    .padding(.horizontal, 20)
                }

                Color.clear.frame(height: 100)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.bg.ignoresSafeArea())
    }

    private var balanceCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Available")
                    .font(.bodyFont(14, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                Text(state.payableBalanceCents.dollarsFormatted)
                    .font(.display(40, weight: .black))
                    .foregroundColor(.white)
                    .tracking(-1.2)
                Text("Min \(AppState.cashOutMinimumCents.dollarsCompact) · \(state.payoutMethodLabel)")
                    .font(.bodyFont(12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.78))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                state.push(.cashOut)
            } label: {
                HStack(spacing: 6) {
                    Text("Cash out")
                        .font(.bodyFont(14, weight: .bold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(theme.text)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Capsule().fill(Color.white))
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
            }
            .buttonStyle(CLPressStyle())
            .disabled(state.payableBalanceCents < AppState.cashOutMinimumCents)
            .opacity(state.payableBalanceCents < AppState.cashOutMinimumCents ? 0.55 : 1)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .colorBlockCard(fill: theme.accentGreen, cornerRadius: theme.radiusXl)
    }

    private func ledgerRow(_ entry: LedgerEntry) -> some View {
        let dropTitle = state.drop(id: entry.dropId)?.title ?? "Drop"
        return HStack(spacing: 14) {
            Circle()
                .fill(color(for: entry.type).opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon(for: entry.type))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color(for: entry.type))
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(dropTitle)
                    .font(.display(14, weight: .semibold))
                    .foregroundColor(theme.text)
                    .lineLimit(1)
                Text(entry.note)
                    .font(.bodyFont(12))
                    .foregroundColor(theme.textMuted)
                    .lineLimit(1)
            }
            Spacer()
            Text(entry.amountCents.dollarsCompact)
                .font(.display(15, weight: .bold))
                .foregroundColor(theme.text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func color(for type: LedgerEntryType) -> Color {
        switch type {
        case .pending: return theme.warning
        case .payable: return theme.success
        case .paid: return theme.ink
        case .reversed: return theme.primary
        }
    }

    private func icon(for type: LedgerEntryType) -> String {
        switch type {
        case .pending: return "hourglass"
        case .payable: return "checkmark.circle"
        case .paid: return "arrow.up.right"
        case .reversed: return "xmark.circle"
        }
    }
}

struct CashOutScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "Cash out", onBack: { state.pop() }, theme: theme)
            VStack(alignment: .leading, spacing: 20) {
                Text(state.payableBalanceCents.dollarsFormatted)
                    .font(.display(44, weight: .bold))
                    .foregroundColor(theme.text)
                Text("Sending to \(state.payoutMethodLabel). Simulated transfer — no real money moves in this build.")
                    .font(.bodyFont(15))
                    .foregroundColor(theme.textMuted)

                Spacer()

                CLButton(label: "Confirm cash out", kind: .primary, size: .lg, full: true, theme: theme) {
                    haptic(.medium)
                    state.cashOut()
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .background(theme.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - You / Profile
struct YouProfileScreen: View {
    @Bindable var state: AppState
    @Bindable var auth: AuthStore
    let theme: CLTheme

    var body: some View {
        CLScrollView(theme: theme, bottomFade: 40) {
            VStack(alignment: .leading, spacing: 0) {
                CLScreenHeader(
                    title: "You",
                    subtitle: "Profile, payouts, and alerts.",
                    theme: theme
                )

                Button {
                    state.push(.editProfile)
                } label: {
                    profileHeader
                }
                .buttonStyle(CLPressStyle(scale: 0.985))
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                HStack(spacing: 12) {
                    CLColorStatCard(
                        title: "School",
                        value: state.school.name,
                        detail: verificationLabel,
                        icon: "checkmark.seal.fill",
                        fill: theme.accentBlue,
                        compact: true
                    )
                    CLColorStatCard(
                        title: "Lifetime",
                        value: state.lifetimeEarnedCents.dollarsCompact,
                        detail: "lifetime",
                        icon: "star.fill",
                        fill: theme.primary,
                        compact: true
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)

                VStack(spacing: 0) {
                    settingsRow(icon: "checkmark.seal", title: "School verification", value: verificationLabel) {
                        state.push(.verification)
                    }
                    divider
                    settingsRow(icon: "creditcard", title: "Payout method", value: state.payoutMethodLabel) {
                        state.push(.payoutSettings)
                    }
                    divider
                    settingsRow(icon: "bell", title: "Notifications", value: state.notificationsEnabled ? "On" : "Off") {
                        state.push(.notifications)
                    }
                }
                .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: theme.radiusLg, shadow: theme.shadowSm, borderWidth: 0)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Alert preferences")
                        .font(.display(15, weight: .heavy))
                        .foregroundColor(theme.text)
                    Toggle("Drop alerts", isOn: $state.dropAlertsEnabled)
                    Toggle("Payout alerts", isOn: $state.payoutAlertsEnabled)
                    Toggle("All notifications", isOn: $state.notificationsEnabled)
                }
                .toggleStyle(SwitchToggleStyle(tint: theme.primary))
                .font(.bodyFont(15))
                .padding(16)
                .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: theme.radiusLg, shadow: theme.shadowSm, borderWidth: 0)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                CLButton(
                    label: "Log out",
                    kind: .surface,
                    size: .lg,
                    icon: "rectangle.portrait.and.arrow.right",
                    showsChevron: false,
                    full: true,
                    theme: theme
                ) {
                    haptic(.medium)
                    auth.signOut()
                    state.logOut()
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)

                Text("CampusLink Drops · joincampuslink.com")
                    .font(.bodyFont(12, weight: .medium))
                    .foregroundColor(theme.textFaint)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)

                Color.clear.frame(height: 100)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.bg.ignoresSafeArea())
    }

    private var verificationLabel: String {
        switch state.verificationStatus {
        case .verified: return "Verified"
        case .pending: return "Pending"
        case .unverified: return "Not verified"
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Text(avatarLetter)
                .font(.display(28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(Circle().fill(theme.primary))

            VStack(alignment: .leading, spacing: 4) {
                Text(state.displayName)
                    .font(.display(22, weight: .bold))
                    .foregroundColor(theme.text)
                Text(roleLine)
                    .font(.bodyFont(13, weight: .medium))
                    .foregroundColor(theme.textMuted)
                HStack(spacing: 6) {
                    SchoolLogo(school: state.school, size: 18, cornerRadius: 5, showBorder: false)
                    Text(state.school.name)
                        .font(.bodyFont(13))
                        .foregroundColor(theme.textMuted)
                }
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(theme.textFaint)
        }
        .padding(18)
        .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: theme.radiusLg, shadow: theme.shadowSm, borderWidth: 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Edit profile, \(state.displayName)")
        .accessibilityAddTraits(.isButton)
    }

    private var avatarLetter: String {
        if state.profileKind == .org {
            return String((state.orgName.first ?? "O")).uppercased()
        }
        return String((state.handle.first ?? "?")).uppercased()
    }

    private var roleLine: String {
        if state.profileKind == .org {
            return "\(state.orgType.rawValue) · Campus org"
        }
        return "\(state.year) · Student"
    }

    private var divider: some View {
        theme.line.frame(height: 1).padding(.leading, 54)
    }

    private func settingsRow(icon: String, title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(theme.primary)
                    .frame(width: 28)
                Text(title)
                    .font(.bodyFont(15, weight: .medium))
                    .foregroundColor(theme.text)
                Spacer()
                Text(value)
                    .font(.bodyFont(13))
                    .foregroundColor(theme.textMuted)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.textFaint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(CLPressStyle(scale: 0.99))
    }
}

struct EditProfileScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "Edit profile", onBack: { state.pop() }, theme: theme)
            CLScrollView(theme: theme) {
                VStack(alignment: .leading, spacing: 18) {
                    if state.profileKind == .student {
                        labeledField("Handle") {
                            TextField("handle", text: $state.handle)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        labeledField("Year") {
                            TextField("Year", text: $state.year)
                        }
                    } else {
                        labeledField("Org name") {
                            TextField("Org name", text: $state.orgName)
                        }
                        labeledField("Members") {
                            TextField("Count", text: $state.orgMemberCount)
                                .keyboardType(.numberPad)
                        }
                    }
                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(theme.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.eyebrow(11))
                .textCase(.uppercase)
                .foregroundColor(theme.textMuted)
            content()
                .font(.bodyFont(16))
                .padding(.horizontal, 14)
                .frame(height: 50)
                .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 12, borderWidth: theme.borderThinWidth)
        }
    }
}

struct VerificationScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme
    @State private var email: String = ""

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "Verification", onBack: { state.pop() }, theme: theme)
            VStack(alignment: .leading, spacing: 16) {
                Text("Verify your school email so brands know you’re an active \(state.profileKind == .org ? "org" : "student") on this campus.")
                    .font(.bodyFont(15))
                    .foregroundColor(theme.textMuted)

                TextField("you@school.edu", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 12, borderWidth: theme.borderThinWidth)

                statusBadge

                Spacer()

                CLButton(
                    label: state.verificationStatus == .pending ? "Resubmit" : "Submit for review",
                    kind: .primary,
                    size: .lg,
                    full: true,
                    theme: theme
                ) {
                    let value = email.isEmpty ? state.eduEmail : email
                    state.submitVerification(email: value)
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(theme.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear { email = state.eduEmail }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch state.verificationStatus {
        case .verified:
            Label("Verified", systemImage: "checkmark.seal.fill")
                .foregroundColor(theme.success)
        case .pending:
            Label("Pending review", systemImage: "envelope")
                .foregroundColor(theme.warning)
        case .unverified:
            Label("Not verified", systemImage: "seal")
                .foregroundColor(theme.textMuted)
        }
    }
}

struct PayoutSettingsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private let methods = ["Debit card ·••• 4242", "PayPal", "Bank account"]

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "Payout method", onBack: { state.pop() }, theme: theme)
            VStack(spacing: 10) {
                ForEach(methods, id: \.self) { method in
                    Button {
                        state.payoutMethodLabel = method
                        state.showToast("Payout method updated", icon: "creditcard")
                        state.pop()
                    } label: {
                        HStack {
                            Text(method)
                                .font(.bodyFont(15, weight: .medium))
                                .foregroundColor(theme.text)
                            Spacer()
                            if state.payoutMethodLabel == method {
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.primary)
                            }
                        }
                        .padding(16)
                        .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 14, shadow: 0, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(CLPressStyle())
                }
                Spacer()
            }
            .padding(20)
        }
        .background(theme.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Notifications
struct NotificationsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "Notifications", onBack: { state.pop() }, theme: theme)

            if state.notifications.isEmpty {
                Spacer()
                CLEmptyState(
                    icon: "bell",
                    title: "You’re all caught up",
                    subtitle: "New Drops, claim timers, and payout updates will show here.",
                    theme: theme
                )
                Spacer()
            } else {
                CLScrollView(theme: theme) {
                    VStack(spacing: 0) {
                        ForEach(state.notifications) { note in
                            notificationRow(note)
                            theme.line.frame(height: 1).padding(.leading, 20)
                        }
                    }
                }
            }
        }
        .background(theme.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear { state.markNotificationsRead() }
    }

    private func notificationRow(_ note: AppNotification) -> some View {
        Button {
            if let id = note.relatedDropId {
                state.pop()
                state.push(.dropDetail, id: id)
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Circle()
                    .fill(theme.primary.opacity(note.read ? 0.08 : 0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon(for: note.kind))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.primary)
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.display(14, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text(note.body)
                        .font(.bodyFont(13))
                        .foregroundColor(theme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                if !note.read {
                    Circle().fill(theme.primary).frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(CLPressStyle(scale: 0.99))
    }

    private func icon(for kind: AppNotificationKind) -> String {
        switch kind {
        case .newDrop: return "bolt.fill"
        case .spotsLow: return "flame"
        case .claimExpiring: return "clock"
        case .approved: return "checkmark.seal.fill"
        case .rejected: return "xmark"
        case .needsInfo: return "exclamationmark.bubble"
        case .payout: return "banknote"
        }
    }
}
