import SwiftUI
import UIKit

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

            MetadataTag(
                label: drop.category.rawValue,
                hugeIcon: drop.category.hugeIcon,
                systemIcon: drop.category.hugeIcon == nil ? drop.category.icon : nil,
                theme: theme
            )

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
                    CLChip(
                        label: filter.rawValue,
                        selected: selectedFilter == filter,
                        hugeIcon: filter.hugeIcon,
                        theme: theme
                    ) {
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

// MARK: - Drop detail (brand-wash hero + sheet - Claim CTA)
struct DropDetailScreen: View {
    @Bindable var state: AppState
    let opportunityID: String
    let theme: CLTheme

    private var drop: CampusDrop? { state.opportunity(id: opportunityID) }

    /// Window safe-area top - NavStack won't give that strip to SwiftUI content.
    private var topInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let inset = scene?.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top
            ?? scene?.windows.first?.safeAreaInsets.top
            ?? 59
        return max(inset, 47)
    }

    var body: some View {
        Group {
            if let drop {
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            hero(drop)
                                .padding(.top, -topInset)

                            sheet(drop)
                                .offset(y: -18)
                        }
                    }
                    .contentMargins(.top, 0, for: .scrollContent)
                    .contentMargins(.top, 0, for: .scrollIndicators)

                    bottomBar(drop)
                }
                .background {
                    VStack(spacing: 0) {
                        drop.brandColor
                            .frame(height: topInset)
                            .frame(maxWidth: .infinity)
                        theme.bg
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .ignoresSafeArea()
                }
            } else {
                VStack(spacing: 0) {
                    CLTopBar(title: "Drop", onBack: { state.pop() }, theme: theme)
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
                .background(theme.bg.ignoresSafeArea())
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private func hero(_ drop: CampusDrop) -> some View {
        let height = 236 + topInset
        let heroTitle = drop.hasApplied ? "Claimed" : "Claim"
        return ZStack(alignment: .top) {
            Rectangle().fill(drop.brandColor)

            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.42),
                            .init(color: Color.black.opacity(0.45), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            heroBrandMark(drop)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 22)
                .padding(.bottom, 78)

            VStack(spacing: 0) {
                HStack {
                    Button { state.pop() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.black.opacity(0.28)))
                    }
                    .buttonStyle(CLPressStyle())
                    .accessibilityLabel("Back")

                    Spacer()

                    ShareLink(item: drop.webProofURL ?? AppState.shareURL(path: "offers/gigs/\(drop.id)")) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.black.opacity(0.28)))
                    }
                    .accessibilityLabel("Share Drop")
                }
                .padding(.horizontal, 20)
                .padding(.top, topInset + 10)

                Spacer(minLength: 0)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(heroTitle)
                            .font(.display(36, weight: .bold))
                            .tracking(-0.8)
                            .foregroundColor(.white)
                        Text(drop.payoutLabel)
                            .font(.display(18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.92))
                    }

                    Spacer(minLength: 12)

                    VStack(alignment: .trailing, spacing: 4) {
                        Label(drop.timeLeftLabel, systemImage: "clock")
                            .font(.display(13, weight: .semibold))
                            .foregroundColor(.white)
                        Text(drop.spotsLabel)
                            .font(.bodyFont(12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }

    private func heroBrandMark(_ drop: CampusDrop) -> some View {
        Group {
            if let urlStr = drop.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit().padding(16)
                    default:
                        Text(drop.initials)
                            .font(.display(22, weight: .bold))
                            .foregroundColor(drop.brandColor)
                    }
                }
            } else {
                Text(drop.initials)
                    .font(.display(22, weight: .bold))
                    .foregroundColor(drop.brandColor)
            }
        }
        .frame(width: 72, height: 72)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .accessibilityHidden(true)
    }

    private func sheet(_ drop: CampusDrop) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(drop.brand)
                    .font(.bodyFont(13, weight: .semibold))
                    .foregroundColor(theme.primary)
                Text(drop.title)
                    .font(.display(28, weight: .bold))
                    .foregroundColor(theme.text)
                    .tracking(-0.6)
                    .accessibilityAddTraits(.isHeader)
                Text(drop.description)
                    .font(.bodyFont(15))
                    .foregroundColor(theme.textMuted)
                    .lineSpacing(3)

                if let taskURL = drop.taskLinkURL {
                    Link(destination: taskURL) {
                        Text("\(drop.category.taskUrlButtonLabel): \(taskURL.absoluteString)")
                            .font(.bodyFont(14, weight: .medium))
                            .foregroundColor(theme.textMuted)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 4)
                }
            }

            if !drop.instructions.isEmpty {
                section("How it works") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(drop.instructions.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(i + 1)")
                                    .font(.bodyFont(12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Circle().fill(theme.primary))
                                Text(step)
                                    .font(.bodyFont(14))
                                    .foregroundColor(theme.text)
                            }
                        }
                    }
                }
            }

            if !drop.proofRequirements.isEmpty {
                section("Proof required") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(drop.proofRequirements) { req in
                            Label(req.label, systemImage: proofIcon(for: req.kind))
                                .font(.bodyFont(14, weight: .medium))
                                .foregroundColor(theme.text)
                        }
                        if let deadline = drop.deadlineLabel {
                            Text("Deadline \(deadline)")
                                .font(.bodyFont(12, weight: .semibold))
                                .foregroundColor(theme.textFaint)
                        }
                    }
                }
            }

            if drop.hasApplied {
                section("Next step") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(drop.applyNote ?? "Submit proof on CampusLink so the brand can review and pay you.")
                            .font(.bodyFont(14))
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

            HStack(spacing: 8) {
                MetadataTag(
                    label: drop.category.rawValue,
                    hugeIcon: drop.category.hugeIcon,
                    systemIcon: drop.category.hugeIcon == nil ? drop.category.icon : nil,
                    theme: theme
                )
                ForEach(drop.eligibilityTags, id: \.self) { tag in
                    MetadataTag(label: tag, theme: theme)
                }
            }

            Color.clear.frame(height: 120)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.bg)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24,
                style: .continuous
            )
        )
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.display(17, weight: .bold))
                .foregroundColor(theme.text)
                .accessibilityAddTraits(.isHeader)
            content()
        }
    }

    private func proofIcon(for kind: ProofRequirement.Kind) -> String {
        switch kind {
        case .screenshot: return "camera"
        case .link: return "link"
        case .text: return "text.alignleft"
        case .receipt: return "doc.text"
        }
    }

    @ViewBuilder
    private func bottomBar(_ drop: CampusDrop) -> some View {
        Group {
            if drop.hasApplied {
                VStack(spacing: 10) {
                    CLButton(
                        label: "Claimed",
                        kind: .surface,
                        size: .lg,
                        full: true,
                        theme: theme
                    ) {
                        state.setTab(.active)
                    }
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
                CLButton(label: "This Drop is closed", kind: .surface, size: .lg, full: true, theme: theme) {}
                    .disabled(true)
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
                CLButton(label: "Not eligible", kind: .surface, size: .lg, full: true, theme: theme) {}
                    .disabled(true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
        .background(theme.bg.ignoresSafeArea(edges: .bottom))
    }
}
