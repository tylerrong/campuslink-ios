import SwiftUI
import UIKit
import Hugeicons

// MARK: - Drop card
struct DropCard: View {
    let drop: CampusDrop
    let theme: CLTheme
    var compact: Bool = false

    private var urgencyHot: Bool {
        let hours = drop.endAt.timeIntervalSinceNow / 3600
        return hours < 6 || drop.remainingSlots < 15
    }

    private var spotsTaken: CGFloat {
        guard drop.maxCompletions > 0 else { return 0 }
        return CGFloat(drop.maxCompletions - drop.remainingSlots) / CGFloat(drop.maxCompletions)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                brandMark

                VStack(alignment: .leading, spacing: 5) {
                    Text(drop.brand)
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(drop.brandColor)

                    Text(drop.title)
                        .font(.display(compact ? 17 : 19, weight: .heavy))
                        .foregroundColor(theme.text)
                        .tracking(-0.35)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(drop.payoutLabel)
                    .font(.display(16, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(theme.accentGreen))
            }

            HStack(spacing: 8) {
                metaChip(drop.timeLeftLabel, color: urgencyHot ? theme.primary : theme.accentBlue)
                metaChip("~\(drop.estimatedMinutes)m", color: theme.textMuted)
                metaChip(drop.category.rawValue, color: theme.textMuted)
                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(drop.schoolLabel)
                        .font(.bodyFont(12, weight: .semibold))
                        .foregroundColor(theme.textMuted)
                        .lineLimit(1)
                    Spacer()
                    Text("\(drop.remainingSlots) spots left")
                        .font(.bodyFont(12, weight: .bold))
                        .foregroundColor(urgencyHot ? theme.primary : theme.text)
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(theme.surfaceAlt)
                        Capsule()
                            .fill(urgencyHot ? theme.primary : theme.accentGreen)
                            .frame(width: max(6, geo.size.width * (1 - spotsTaken)))
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: theme.radiusLg, style: .continuous)
                .fill(theme.card)
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 8)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(drop.title) from \(drop.brand), \(drop.payoutLabel), \(drop.timeLeftLabel)")
    }

    private var brandMark: some View {
        ZStack {
            if let urlStr = drop.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit().padding(11)
                    default:
                        monogram
                    }
                }
            } else {
                monogram
            }
        }
        .frame(width: 54, height: 54)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(drop.brandColor.opacity(0.12))
        )
    }

    private var monogram: some View {
        Text(drop.initials)
            .font(.display(17, weight: .black))
            .foregroundColor(drop.brandColor)
    }

    private func metaChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.bodyFont(12, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}

// MARK: - Feed
struct DropsFeedScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var drops: [CampusDrop] { state.rankedDrops() }
    private var liveCount: Int { drops.count }
    private var activeCount: Int { state.activeClaims.count }
    private var approvedCount: Int {
        state.submissions.filter { $0.reviewStatus == .approved }.count
    }
    private var weeklyGoal: Int { max(liveCount, 5) }
    private var weeklyProgress: CGFloat {
        let done = min(approvedCount + activeCount, weeklyGoal)
        return CGFloat(done) / CGFloat(weeklyGoal)
    }

    private struct FeedFilter: Identifiable {
        let id: String
        let label: String
        let icon: HugeiconsAsset
    }

    private var filters: [FeedFilter] {
        var list: [FeedFilter] = [
            .init(id: "all", label: "All", icon: Hugeicons.gridView),
            .init(id: "appInstall", label: "App install", icon: Hugeicons.smartPhone01),
            .init(id: "survey", label: "Survey", icon: Hugeicons.quiz01),
            .init(id: "socialPost", label: "Social", icon: Hugeicons.share05),
        ]
        if state.profileKind == .org {
            list.insert(.init(id: "orgs", label: "For orgs", icon: Hugeicons.userGroup), at: 1)
        }
        return list
    }

    var body: some View {
        CLScrollView(theme: theme, bottomFade: 40) {
            VStack(alignment: .leading, spacing: 0) {
                header
                statsBlock
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters) { f in
                            CLChip(
                                label: f.label,
                                selected: state.feedFilter == f.id,
                                hugeIcon: f.icon,
                                iconOnly: false,
                                theme: theme
                            ) {
                                state.feedFilter = f.id
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                .padding(.bottom, 14)

                HStack {
                    Text("Open Drops")
                        .font(.display(20, weight: .heavy))
                        .foregroundColor(theme.text)
                    Spacer()
                    Text("\(liveCount) live")
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(theme.accentGreen)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                if drops.isEmpty {
                    CLEmptyState(
                        icon: "bolt.slash",
                        title: "No Drops right now",
                        subtitle: "Check back soon — new school-matched Drops land throughout the day.",
                        theme: theme
                    )
                    .padding(.top, 24)
                } else {
                    VStack(spacing: 14) {
                        ForEach(drops) { drop in
                            Button {
                                haptic(.light)
                                state.push(.dropDetail, id: drop.id)
                            } label: {
                                DropCard(drop: drop, theme: theme)
                            }
                            .buttonStyle(CLPressStyle(scale: 0.985))
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Color.clear.frame(height: 110)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.bg.ignoresSafeArea())
        .onAppear { _ = state.expireStaleClaimsIfNeeded() }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    SchoolLogo(school: state.school, size: 28, cornerRadius: 8, showBorder: false)
                    Text(state.school.name)
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(theme.textMuted)
                }
                Text("Drops")
                    .font(.display(34, weight: .black))
                    .tracking(-1.0)
                    .foregroundColor(theme.text)
                Text(encouragement)
                    .font(.bodyFont(15, weight: .medium))
                    .foregroundColor(theme.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                state.push(.notifications)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(theme.surfaceAlt))
                    if state.unreadNotificationCount > 0 {
                        Text("\(min(state.unreadNotificationCount, 9))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(theme.primary))
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .buttonStyle(CLPressStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var encouragement: String {
        if activeCount > 0 { return "Keep going — finish your open claims." }
        if liveCount > 0 { return "New Drops are live. Grab one before spots run out." }
        return "You're all caught up. Check back soon."
    }

    private var statsBlock: some View {
        VStack(spacing: 12) {
            // Hero progress card (middle-reference green card)
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This week")
                        .font(.bodyFont(14, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                    Text("\(Int((weeklyProgress * 100).rounded()))%")
                        .font(.display(40, weight: .black))
                        .foregroundColor(.white)
                        .tracking(-1.2)
                    Text("\(min(approvedCount + activeCount, weeklyGoal))/\(weeklyGoal) drops moving")
                        .font(.bodyFont(13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    CLProgressRing(progress: weeklyProgress, lineWidth: 9)
                        .frame(width: 78, height: 78)
                    VStack(spacing: 0) {
                        Text("\(liveCount)")
                            .font(.display(20, weight: .black))
                            .foregroundColor(.white)
                        Text("live")
                            .font(.eyebrow(9))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(20)
            .colorBlockCard(fill: theme.accentGreen, cornerRadius: theme.radiusXl)

            HStack(spacing: 12) {
                CLColorStatCard(
                    title: "Active",
                    value: "\(activeCount)",
                    detail: activeCount == 1 ? "claim open" : "claims open",
                    icon: "flame.fill",
                    fill: theme.primary,
                    compact: true
                )
                CLColorStatCard(
                    title: "Earned",
                    value: state.lifetimeEarnedCents.dollarsCompact,
                    detail: "lifetime",
                    icon: "checkmark.seal.fill",
                    fill: theme.accentBlue,
                    compact: true
                )
            }

            // Escrow note as soft white card
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.accentGreen)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(theme.accentGreen.opacity(0.14)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Escrow protected")
                        .font(.display(14, weight: .heavy))
                        .foregroundColor(theme.text)
                    Text("Brand budgets unlock when your proof is approved.")
                        .font(.bodyFont(12, weight: .medium))
                        .foregroundColor(theme.textMuted)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowSm, borderWidth: 0)
        }
    }
}

// MARK: - Detail
struct DropDetailScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var drop: CampusDrop { state.detailDrop ?? state.drops[0] }
    private var existingClaim: DropClaim? { state.claim(forDropId: drop.id) }

    /// Window safe-area top — reliable inside NavigationStack where ScrollView insets fight ignoresSafeArea.
    private var topInset: CGFloat {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
        let inset = scene?.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top
            ?? scene?.windows.first?.safeAreaInsets.top
            ?? 59
        return max(inset, 47)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    hero
                        // Pull the brand wash into the status-bar strip (NavStack won't
                        // give that space to SwiftUI content; chrome paints the same color).
                        .padding(.top, -topInset)

                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(drop.brand)
                                .font(.bodyFont(13, weight: .semibold))
                                .foregroundColor(theme.primary)
                            Text(drop.title)
                                .font(.display(28, weight: .bold))
                                .foregroundColor(theme.text)
                                .tracking(-0.6)
                            Text(drop.description)
                                .font(.bodyFont(15))
                                .foregroundColor(theme.textMuted)
                                .lineSpacing(3)
                        }

                        factsGrid

                        section("What you’ll do") {
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

                        section("Proof required") {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(drop.proofRequirements) { req in
                                    Label(req.label, systemImage: icon(for: req.kind))
                                        .font(.bodyFont(14, weight: .medium))
                                        .foregroundColor(theme.text)
                                }
                            }
                        }

                        HStack(spacing: 8) {
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
                    .offset(y: -18)
                }
            }
            .contentMargins(.top, 0, for: .scrollContent)
            .contentMargins(.top, 0, for: .scrollIndicators)

            bottomBar
        }
        // NavigationStack keeps destination content below the status bar; paint brand
        // into that system strip so it never reads as a white cut-off.
        .background(drop.brandColor)
        .background(DropDetailTopChrome(color: drop.brandColor))
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var hero: some View {
        let height = 236 + topInset
        return ZStack(alignment: .top) {
            // Flat brand wash — no soft blur halo
            Rectangle()
                .fill(drop.brandColor)

            Rectangle()
                .fill(
                    LinearGradient(
                        // Keep the status-bar band pure brand color so it doesn't seam
                        // against the chrome strip NavigationStack leaves above content.
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .clear, location: 0.42),
                            .init(color: Color.black.opacity(0.45), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            heroBrandMark
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

                    Spacer()

                    ShareLink(item: AppState.shareURL(path: "drops/\(drop.id)")) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.black.opacity(0.28)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, topInset + 10)

                Spacer(minLength: 0)

                HStack(alignment: .bottom) {
                    Text(drop.payoutLabel)
                        .font(.display(36, weight: .bold))
                        .tracking(-0.8)
                        .foregroundColor(.white)

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

    private var heroBrandMark: some View {
        Group {
            if let urlStr = drop.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(16)
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

    private var factsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            fact("Time", value: "~\(drop.estimatedMinutes) min")
            fact("Window", value: claimWindowLabel)
            fact("Campus", value: drop.schoolLabel)
            fact("Category", value: drop.category.rawValue)
        }
    }

    private var claimWindowLabel: String {
        let h = Int(drop.completionWindowSeconds / 3600)
        if h >= 24 { return "\(h / 24)d after accept" }
        if h >= 1 { return "\(h)h after accept" }
        return "\(Int(drop.completionWindowSeconds / 60))m after accept"
    }

    private func fact(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.eyebrow(10))
                .tracking(0.6)
                .foregroundColor(theme.textMuted)
            Text(value)
                .font(.display(14, weight: .semibold))
                .foregroundColor(theme.text)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
    }

    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.display(17, weight: .bold))
                .foregroundColor(theme.text)
            content()
        }
    }

    private func icon(for kind: ProofRequirement.Kind) -> String {
        switch kind {
        case .screenshot: return "camera"
        case .link: return "link"
        case .text: return "text.alignleft"
        case .receipt: return "doc.text"
        }
    }

    private var bottomBar: some View {
        Group {
            if let claim = existingClaim {
                if claim.status == .claimed {
                    CLButton(label: "Continue — submit proof", kind: .primary, size: .lg, full: true, theme: theme) {
                        state.push(.proofSubmit, id: claim.id)
                    }
                } else {
                    CLButton(label: "View in Active", kind: .primary, size: .lg, full: true, theme: theme) {
                        state.setTab(.active)
                    }
                }
            } else if state.isEligible(drop) {
                CLButton(label: "Accept Drop", kind: .primary, size: .lg, full: true, theme: theme) {
                    haptic(.medium)
                    state.acceptDrop(id: drop.id)
                }
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

/// Paints the navigation host / window strip behind the status bar so Drop detail
/// heroes don't leave a white cut-off above the brand wash.
private struct DropDetailTopChrome: UIViewControllerRepresentable {
    var color: Color

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        vc.view.isUserInteractionEnabled = false
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let uiColor = UIColor(color)
        DispatchQueue.main.async {
            var node: UIViewController? = uiViewController
            while let current = node {
                current.view.backgroundColor = current === uiViewController ? .clear : uiColor
                if let nav = current as? UINavigationController ?? current.navigationController {
                    nav.view.backgroundColor = uiColor
                    nav.navigationBar.isHidden = true
                    nav.navigationBar.backgroundColor = .clear
                    nav.viewControllers.forEach {
                        $0.view.backgroundColor = uiColor
                        $0.edgesForExtendedLayout = .all
                        $0.additionalSafeAreaInsets.top = 0
                    }
                }
                node = current.parent
            }
            uiViewController.view.window?.backgroundColor = uiColor
        }
    }
}
