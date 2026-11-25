import SwiftUI

// MARK: - My Drops (claimed)
struct ActiveDropsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var claimed: [CampusDrop] { state.appliedOpportunities }

    var body: some View {
        CLScrollView(theme: theme, bottomFade: 0) {
            VStack(alignment: .leading, spacing: 16) {
                CLScreenHeader(title: "My Drops", theme: theme)

                if !state.applicationsError.isEmpty {
                    CLEmptyState(
                        icon: "wifi.slash",
                        title: "Couldn’t refresh My Drops",
                        subtitle: state.applicationsError,
                        actionLabel: "Try again",
                        action: { Task { await state.refreshApplied() } },
                        theme: theme
                    )
                    .padding(.horizontal, 20)
                }

                if claimed.isEmpty {
                    if state.isLoadingApplications {
                        ProgressView("Loading claimed Drops")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if state.applicationsError.isEmpty {
                        CLEmptyState(
                            icon: "tray",
                            title: "No claimed Drops yet",
                            subtitle: "Claim a Drop to see it here.",
                            actionLabel: "Browse Drops",
                            action: { state.setTab(.drops) },
                            theme: theme
                        )
                        .padding(.top, 32)
                    }
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(claimed) { drop in
                            AppliedOpportunityCard(
                                drop: drop,
                                theme: theme,
                                onOpen: { state.push(.dropDetail, id: drop.id) }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.bg.ignoresSafeArea())
        .refreshable { await state.refreshApplied() }
        .task(id: state.currentTab) {
            if state.currentTab == .active { await state.refreshApplied() }
        }
    }
}

struct AppliedOpportunityCard: View {
    let drop: CampusDrop
    let theme: CLTheme
    let onOpen: () -> Void

    private var statusColor: Color {
        switch drop.submissionStatus?.lowercased() {
        case "approved", "paid": return theme.accentGreen
        case "pending": return theme.accentOrange
        case "rejected": return theme.primary
        default: return theme.accentGreen
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onOpen) {
                HStack(spacing: 12) {
                    OpportunityBrandMark(drop: drop)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(drop.brand)
                            .font(.bodyFont(12, weight: .semibold))
                            .foregroundColor(theme.primary)
                        Text(drop.title)
                            .font(.display(16, weight: .bold))
                            .foregroundColor(theme.text)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 6) {
                        Text(drop.payoutLabel)
                            .font(.bodyFont(12, weight: .bold))
                            .foregroundColor(theme.primary)
                        Text(drop.submissionStatusLabel)
                            .font(.bodyFont(12, weight: .bold))
                            .foregroundColor(statusColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(statusColor.opacity(0.12)))
                    }
                }
            }
            .buttonStyle(CLPressStyle(scale: 0.985))
            .accessibilityIdentifier("claimed-drop-\(drop.id)")

            Text(drop.applyNote ?? "Submit proof on CampusLink so the brand can review and pay you.")
                .font(.bodyFont(13))
                .foregroundColor(theme.textMuted)

            if let proofURL = drop.webProofURL {
                Link(destination: proofURL) {
                    Text("Submit proof")
                        .font(.bodyFont(14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(theme.primary))
                }
            }
        }
        .padding(16)
        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 16, borderWidth: theme.borderThinWidth)
    }
}
