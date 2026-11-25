import SwiftUI

// MARK: - Drop card (mirrors web GigCard content)
struct DropCard: View {
    let drop: CampusDrop
    let theme: CLTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                OpportunityBrandMark(drop: drop)
                Text(drop.brand)
                    .font(.bodyFont(13, weight: .semibold))
                    .foregroundColor(theme.textMuted)
                    .lineLimit(1)
                Spacer(minLength: 8)
                MetadataTag(label: drop.payoutLabel, color: theme.primary, theme: theme)
            }

            Text(drop.title)
                .font(.display(19, weight: .bold))
                .foregroundColor(theme.text)
                .fixedSize(horizontal: false, vertical: true)

            Text(drop.cardBlurb)
                .font(.bodyFont(14))
                .foregroundColor(theme.textMuted)
                .lineLimit(2)

            MetadataTag(label: drop.category.rawValue, theme: theme)

            Divider().overlay(theme.line)

            HStack(spacing: 10) {
                if let deadline = drop.deadlineLabel {
                    Label(deadline, systemImage: "calendar")
                        .font(.bodyFont(12, weight: .medium))
                        .foregroundColor(theme.textMuted)
                        .lineLimit(1)
                }
                Text(drop.spotsLabel)
                    .font(.bodyFont(12, weight: .semibold))
                    .foregroundColor(drop.hasApplied ? theme.success : theme.textMuted)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(drop.hasApplied ? "View status" : "View Drop")
                    .font(.bodyFont(13, weight: .bold))
                    .foregroundColor(theme.primary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: theme.radiusLg, shadow: theme.shadowSm, borderWidth: 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(drop.brand), \(drop.title), \(drop.payoutLabel)")
    }
}

struct OpportunityBrandMark: View {
    let drop: CampusDrop

    var body: some View {
        ZStack {
            if let logo = drop.logoUrl, let url = URL(string: logo) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFit().padding(9)
                    } else {
                        monogram
                    }
                }
            } else {
                monogram
            }
        }
        .frame(width: 46, height: 46)
        .background(drop.brandColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityHidden(true)
    }

    private var monogram: some View {
        Text(drop.initials)
            .font(.display(15, weight: .bold))
            .foregroundColor(drop.brandColor)
    }
}

// MARK: - Drops feed
struct DropsFeedScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme
    @State private var selectedFilter: DropFeedFilter = .all

    private var filteredOpportunities: [CampusDrop] {
        state.rankedDrops(filter: selectedFilter)
    }

    var body: some View {
        CLScrollView(theme: theme, bottomFade: 0) {
            VStack(alignment: .leading, spacing: 0) {
                header
                summary
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                filters.padding(.bottom, 16)

                if !state.feedError.isEmpty {
                    CLEmptyState(
                        icon: "wifi.slash",
                        title: "Couldn’t refresh Drops",
                        subtitle: state.feedError,
                        actionLabel: "Try again",
                        action: { Task { await refresh() } },
                        theme: theme
                    )
                    .padding(.bottom, 16)
                }

                if filteredOpportunities.isEmpty {
                    if state.isLoadingFeed {
                        ProgressView("Loading Drops")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if state.feedError.isEmpty {
                        emptyFeed.padding(.top, 24)
                    }
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredOpportunities) { drop in
                            Button {
                                haptic(.light)
                                state.push(.dropDetail, id: drop.id)
                            } label: {
                                DropCard(drop: drop, theme: theme)
                            }
                            .buttonStyle(CLPressStyle(scale: 0.985))
                            .accessibilityIdentifier("drop-\(drop.id)")
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(theme.bg.ignoresSafeArea())
        .refreshable { await refresh() }
        .onChange(of: state.remoteUser?.id) { _, _ in selectedFilter = .all }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !state.schoolId.isEmpty {
                HStack(spacing: 8) {
                    SchoolLogo(school: state.school, size: 26, cornerRadius: 7, showBorder: false)
                        .accessibilityHidden(true)
                    Text(state.school.name)
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(theme.textMuted)
                }
            }

            Text("Drops")
                .font(.display(34, weight: .black))
                .tracking(-1)
                .foregroundColor(theme.text)
                .accessibilityAddTraits(.isHeader)
            Text("Claim a paid Drop from a brand, submit proof, and get paid.")
                .font(.bodyFont(14))
                .foregroundColor(theme.textMuted)
                .padding(.top, 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    private var summary: some View {
        let liveCount = state.rankedDrops().count
        let goal = max(5, liveCount)
        let claims = state.weeklyApplicationCount
        let progress = CGFloat(min(claims, goal)) / CGFloat(goal)
        let activeCount = state.appliedOpportunities.count

        return VStack(spacing: 12) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This week")
                        .font(.bodyFont(14, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                    Text("\(Int((progress * 100).rounded()))%")
                        .font(.display(40, weight: .black))
                        .tracking(-1.2)
                        .foregroundColor(.white)
                    Text("\(claims)/\(goal) Drops claimed")
                        .font(.bodyFont(13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    CLProgressRing(progress: progress, lineWidth: 9)
                        .frame(width: 78, height: 78)
                        .accessibilityHidden(true)
                    VStack(spacing: 0) {
                        Text("\(liveCount)")
                            .font(.display(20, weight: .black))
                        Text("live")
                            .font(.bodyFont(12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(liveCount) live Drops")
                }
            }
            .padding(20)
            .colorBlockCard(fill: theme.accentGreen, cornerRadius: theme.radiusXl)

            HStack(spacing: 12) {
                Button { state.setTab(.active) } label: {
                    CLColorStatCard(
                        title: "My Drops",
                        value: "\(activeCount)",
                        detail: activeCount == 1 ? "claimed" : "claimed",
                        icon: "flame.fill",
                        fill: theme.primary,
                        compact: true
                    )
                }
                .buttonStyle(CLPressStyle(scale: 0.985))

                Button { state.setTab(.earnings) } label: {
                    CLColorStatCard(
                        title: "Earned",
                        value: (state.payableBalanceCents + state.paidTotalCents).dollarsCompact,
                        detail: "lifetime",
                        icon: "checkmark.seal.fill",
                        fill: theme.accentBlue,
                        compact: true
                    )
                }
                .buttonStyle(CLPressStyle(scale: 0.985))
            }
        }
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DropFeedFilter.allCases) { filter in
                    CLChip(label: filter.rawValue, selected: selectedFilter == filter, theme: theme) {
                        selectedFilter = filter
                    }
                    .accessibilityAddTraits(selectedFilter == filter ? .isSelected : [])
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }

    private var emptyFeed: some View {
        CLEmptyState(
            icon: "briefcase",
            title: selectedFilter == .all ? "No Drops right now" : "No matches in this category",
            subtitle: selectedFilter == .all
                ? "Paid Drops available to your campus will show up here."
                : "Browse all Drops to see what else is open.",
            actionLabel: selectedFilter == .all ? nil : "Show all",
            action: selectedFilter == .all ? nil : { selectedFilter = .all },
            theme: theme
        )
    }

    private func refresh() async {
        await state.refreshOpportunities()
        await state.refreshApplied()
    }
}

// MARK: - Drop detail
struct DropDetailScreen: View {
    @Bindable var state: AppState
    let opportunityID: String
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "Drop", onBack: { state.pop() }, trailing: shareButton, theme: theme)

            if let drop = state.opportunity(id: opportunityID) {
                CLScrollView(theme: theme, bottomFade: 0) {
                    detail(drop)
                }
                bottomBar(drop)
            } else {
                CLEmptyState(
                    icon: "briefcase",
                    title: "Drop unavailable",
                    subtitle: "This Drop may have closed or been removed.",
                    actionLabel: "Go back",
                    action: { state.pop() },
                    theme: theme
                )
                .padding(.horizontal, 20)
                .padding(.top, 40)
                Spacer()
            }
        }
        .background(theme.bg.ignoresSafeArea())
    }

    private var shareButton: AnyView? {
        guard state.sessionToken != AuthStore.simulatorPreviewToken,
              let drop = state.opportunity(id: opportunityID),
              let url = drop.webProofURL else { return nil }
        return AnyView(
            ShareLink(item: url) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.text)
                    .frame(width: 42, height: 42)
                    .background(theme.surfaceAlt, in: Circle())
            }
            .accessibilityLabel("Share Drop")
        )
    }

    private func detail(_ drop: CampusDrop) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    OpportunityBrandMark(drop: drop)
                    Text(drop.brand)
                        .font(.bodyFont(14, weight: .semibold))
                        .foregroundColor(theme.textMuted)
                    Spacer(minLength: 0)
                    MetadataTag(label: drop.payoutLabel, color: theme.primary, theme: theme)
                }
                Text(drop.title)
                    .font(.display(30, weight: .black))
                    .foregroundColor(theme.text)
                    .accessibilityAddTraits(.isHeader)
                HStack(spacing: 8) {
                    MetadataTag(label: drop.category.rawValue, theme: theme)
                    if drop.hasApplied {
                        MetadataTag(label: "Claimed", color: theme.success, theme: theme)
                    }
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                factCell("Payout", value: drop.payoutLabel)
                factCell("Deadline", value: drop.deadlineLabel ?? "—")
                factCell("Spots", value: drop.spotsLabel)
                factCell("Type", value: drop.category.rawValue)
            }

            VStack(alignment: .leading, spacing: 8) {
                sectionTitle("About this Drop")
                Text(drop.description)
                    .font(.bodyFont(15))
                    .foregroundColor(theme.textMuted)
                    .lineSpacing(3)
            }

            if !drop.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("What you need to do")
                    ForEach(Array(drop.instructions.enumerated()), id: \.offset) { _, step in
                        Label(step, systemImage: "smallcircle.filled.circle")
                            .font(.bodyFont(14))
                            .foregroundColor(theme.textMuted)
                    }
                    if let taskURL = drop.taskLinkURL {
                        Link(destination: taskURL) {
                            Text(drop.category.taskUrlButtonLabel)
                                .font(.bodyFont(15, weight: .bold))
                                .foregroundColor(theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.radiusMd, style: .continuous)
                                        .strokeBorder(theme.primary.opacity(0.35), lineWidth: 1.5)
                                )
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.surfaceAlt, in: RoundedRectangle(cornerRadius: theme.radiusLg))
            }

            if !drop.proofRequirements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Proof required")
                    ForEach(drop.proofRequirements) { req in
                        Text(req.label)
                            .font(.bodyFont(15))
                            .foregroundColor(theme.textMuted)
                    }
                    if let deadline = drop.deadlineLabel {
                        Text("Deadline \(deadline)")
                            .font(.bodyFont(12, weight: .semibold))
                            .foregroundColor(theme.textFaint)
                            .padding(.top, 4)
                    }
                }
            }

            if drop.hasApplied {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Next step")
                    Text(drop.applyNote ?? "Submit proof on CampusLink so the brand can review and pay you.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                    if let proofURL = drop.webProofURL {
                        Link(destination: proofURL) {
                            Label("Submit proof on CampusLink", systemImage: "arrow.up.right")
                                .font(.bodyFont(14, weight: .semibold))
                                .foregroundColor(theme.primary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.display(17, weight: .bold))
            .foregroundColor(theme.text)
            .accessibilityAddTraits(.isHeader)
    }

    private func factCell(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.eyebrow(10))
                .foregroundColor(theme.textFaint)
            Text(value)
                .font(.bodyFont(14, weight: .semibold))
                .foregroundColor(theme.text)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(theme.surfaceAlt, in: RoundedRectangle(cornerRadius: theme.radiusMd))
    }

    @ViewBuilder
    private func bottomBar(_ drop: CampusDrop) -> some View {
        Group {
            if drop.hasApplied {
                VStack(spacing: 10) {
                    Label("Claimed", systemImage: "checkmark.circle.fill")
                        .font(.bodyFont(15, weight: .semibold))
                        .foregroundColor(theme.success)
                        .accessibilityIdentifier("claim-status")
                    if let proofURL = drop.webProofURL {
                        Link(destination: proofURL) {
                            Text("Submit proof")
                                .font(.display(16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 10).fill(theme.primary))
                        }
                    }
                }
            } else if !drop.isLive {
                Text("This Drop is closed")
                    .font(.bodyFont(15, weight: .semibold))
                    .foregroundColor(theme.textMuted)
            } else if state.isEligible(drop) {
                CLButton(
                    label: state.applyingOpportunityID == drop.id ? "Claiming…" : "Claim",
                    kind: .primary,
                    size: .lg,
                    full: true,
                    theme: theme
                ) {
                    haptic(.medium)
                    Task { await state.applyToOpportunity(id: drop.id) }
                }
                .disabled(state.applyingOpportunityID != nil)
            } else {
                Text("This Drop isn’t available to your profile.")
                    .font(.bodyFont(15, weight: .semibold))
                    .foregroundColor(theme.textMuted)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(theme.bg)
    }
}
