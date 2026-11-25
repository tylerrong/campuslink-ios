import SwiftUI
import PhotosUI
import Combine
import UIKit

// MARK: - My Drops (claimed)
struct ActiveDropsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme
    @State private var tick = Date()

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
                        Text("Claimed")
                            .font(.bodyFont(12, weight: .bold))
                            .foregroundColor(theme.accentGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(theme.accentGreen.opacity(0.12)))
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

struct ActiveClaimCard: View {
    let claim: DropClaim
    let drop: CampusDrop
    let submission: DropSubmission?
    let timeLabel: String
    let theme: CLTheme
    let onOpenDrop: () -> Void
    let onSubmit: () -> Void

    private var statusLabel: String {
        if let submission {
            return submission.reviewStatus.rawValue
        }
        return claim.status == .claimed ? "In progress" : "Submitted"
    }

    private var statusColor: Color {
        switch submission?.reviewStatus {
        case .approved: return theme.success
        case .rejected: return theme.primary
        case .needsInfo: return theme.warning
        case .pending: return theme.accentBlue
        case .none: return theme.accentOrange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                brandMark
                VStack(alignment: .leading, spacing: 4) {
                    Text(drop.brand)
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(drop.brandColor)
                    Text(drop.title)
                        .font(.display(17, weight: .heavy))
                        .foregroundColor(theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text(drop.payoutLabel)
                    .font(.display(15, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(theme.accentGreen))
            }

            HStack(spacing: 8) {
                Text(statusLabel)
                    .font(.bodyFont(12, weight: .bold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(statusColor.opacity(0.12)))

                Spacer()

                if claim.status == .claimed {
                    HStack(spacing: 6) {
                        ClaimRing(progress: progress, theme: theme)
                            .frame(width: 22, height: 22)
                        Text(timeLabel)
                            .font(.bodyFont(13, weight: .bold))
                            .foregroundColor(theme.text)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(theme.surfaceAlt))
                }
            }

            if let reason = submission?.rejectionReason,
               submission?.reviewStatus == .needsInfo || submission?.reviewStatus == .rejected {
                Text(reason)
                    .font(.bodyFont(13, weight: .medium))
                    .foregroundColor(theme.text)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(theme.warning.opacity(0.12))
                    )
            }

            HStack(spacing: 10) {
                CLButton(
                    label: "Brief",
                    kind: .surface,
                    size: .md,
                    showsChevron: false,
                    full: true,
                    theme: theme,
                    action: onOpenDrop
                )

                if claim.status == .claimed {
                    CLButton(
                        label: submission?.reviewStatus == .needsInfo ? "Resubmit" : "Submit proof",
                        kind: .primary,
                        size: .md,
                        full: true,
                        theme: theme,
                        action: onSubmit
                    )
                }
            }
        }
        .padding(18)
        .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: theme.radiusLg, shadow: theme.shadowSm, borderWidth: 0)
    }

    private var brandMark: some View {
        Group {
            if let urlStr = drop.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit().padding(8)
                    default:
                        Text(drop.initials)
                            .font(.display(14, weight: .black))
                            .foregroundColor(drop.brandColor)
                    }
                }
            } else {
                Text(drop.initials)
                    .font(.display(14, weight: .black))
                    .foregroundColor(drop.brandColor)
            }
        }
        .frame(width: 44, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(drop.brandColor.opacity(0.12))
        )
    }

    private var progress: CGFloat {
        let total = max(1, claim.expiresAt.timeIntervalSince(claim.acceptedAt))
        let left = max(0, claim.expiresAt.timeIntervalSinceNow)
        return CGFloat(left / total)
    }
}

struct ClaimRing: View {
    let progress: CGFloat
    let theme: CLTheme

    var body: some View {
        ZStack {
            Circle().stroke(theme.line, lineWidth: 3)
            Circle()
                .trim(from: 0, to: max(0.02, progress))
                .stroke(progress < 0.2 ? theme.primary : theme.ink, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Proof submit
struct ProofSubmitScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var link = ""
    @State private var answer = ""
    @State private var tick = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var claim: DropClaim? { state.claim(id: state.detailId) }
    private var drop: CampusDrop? {
        guard let claim else { return nil }
        return state.drop(id: claim.dropId)
    }

    private var needsScreenshot: Bool {
        drop?.proofRequirements.contains { $0.kind == .screenshot || $0.kind == .receipt } ?? false
    }
    private var needsLink: Bool {
        drop?.proofRequirements.contains { $0.kind == .link } ?? false
    }
    private var needsText: Bool {
        drop?.proofRequirements.contains { $0.kind == .text } ?? false
    }

    private var canSubmit: Bool {
        if needsScreenshot && imageData == nil { return false }
        if needsLink && link.trimmingCharacters(in: .whitespacesAndNewlines).count < 8 { return false }
        if needsText && answer.trimmingCharacters(in: .whitespacesAndNewlines).count < 8 { return false }
        return claim != nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                CLTopBar(title: "Submit proof", onBack: { state.pop() }, theme: theme)

                if let drop {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            headerCard(drop)

                            escrowCard(drop)

                            checklistCard(drop)

                            if needsScreenshot { photoSection }
                            if needsLink {
                                fieldSection(title: "Live link", icon: "link") {
                                    TextField("Paste public link", text: $link)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.URL)
                                        .autocorrectionDisabled()
                                        .font(.bodyFont(15, weight: .medium))
                                }
                            }
                            if needsText {
                                fieldSection(title: "Your answers", icon: "text.alignleft") {
                                    TextField("Write your responses here", text: $answer, axis: .vertical)
                                        .lineLimit(5...12)
                                        .font(.bodyFont(15, weight: .medium))
                                }
                            }

                            Color.clear.frame(height: 120)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Spacer()
                    Text("Claim not found")
                        .font(.bodyFont(15, weight: .medium))
                        .foregroundColor(theme.textMuted)
                    Spacer()
                }
            }

            if drop != nil {
                bottomBar
            }
        }
        .background(theme.bg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onReceive(timer) { tick = $0 }
        .onChange(of: pickerItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }

    private func headerCard(_ drop: CampusDrop) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                brandMark(drop)
                VStack(alignment: .leading, spacing: 4) {
                    Text(drop.brand)
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(drop.brandColor)
                    Text(drop.title)
                        .font(.display(22, weight: .heavy))
                        .foregroundColor(theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                if let claim {
                    Label(state.claimTimeLabel(for: claim), systemImage: "clock.fill")
                        .font(.bodyFont(13, weight: .bold))
                        .foregroundColor(theme.accentOrange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(theme.accentOrange.opacity(0.12)))
                        .monospacedDigit()
                }

                Text(drop.payoutLabel)
                    .font(.bodyFont(13, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(theme.accentGreen))

                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: theme.radiusLg, shadow: theme.shadowSm, borderWidth: 0)
    }

    private func escrowCard(_ drop: CampusDrop) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.accentGreen)
                .frame(width: 40, height: 40)
                .background(Circle().fill(theme.accentGreen.opacity(0.14)))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(drop.payoutLabel) → pending escrow")
                    .font(.display(14, weight: .heavy))
                    .foregroundColor(theme.text)
                Text("Held until the brand verifies your proof.")
                    .font(.bodyFont(12, weight: .medium))
                    .foregroundColor(theme.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowSm, borderWidth: 0)
    }

    private func checklistCard(_ drop: CampusDrop) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Proof checklist")
                .font(.display(15, weight: .heavy))
                .foregroundColor(theme.text)
            ForEach(drop.proofRequirements) { req in
                let done = requirementMet(req)
                HStack(spacing: 12) {
                    Image(systemName: done ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(done ? theme.accentGreen : theme.textFaint)
                    Text(req.label)
                        .font(.bodyFont(14, weight: .medium))
                        .foregroundColor(theme.text)
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerCard(fill: theme.surfaceAlt, ink: theme.ink, cornerRadius: 22, shadow: 0, borderWidth: 0)
    }

    private func requirementMet(_ req: ProofRequirement) -> Bool {
        switch req.kind {
        case .screenshot, .receipt: return imageData != nil
        case .link: return link.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
        case .text: return answer.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8
        }
    }

    private func brandMark(_ drop: CampusDrop) -> some View {
        Group {
            if let urlStr = drop.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit().padding(10)
                    default:
                        Text(drop.initials)
                            .font(.display(16, weight: .black))
                            .foregroundColor(drop.brandColor)
                    }
                }
            } else {
                Text(drop.initials)
                    .font(.display(16, weight: .black))
                    .foregroundColor(drop.brandColor)
            }
        }
        .frame(width: 52, height: 52)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(drop.brandColor.opacity(0.12))
        )
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Screenshot", systemImage: "camera.fill")
                .font(.display(15, weight: .heavy))
                .foregroundColor(theme.text)

            PhotosPicker(selection: $pickerItem, matching: .images) {
                ZStack {
                    if let imageData, let ui = UIImage(data: imageData) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 210)
                            .clipped()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(theme.primary)
                            Text("Tap to add photo")
                                .font(.bodyFont(15, weight: .bold))
                                .foregroundColor(theme.text)
                            Text("Clear shot of the required screen")
                                .font(.bodyFont(12, weight: .medium))
                                .foregroundColor(theme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 168)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(theme.surfaceAlt)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            imageData == nil ? theme.primary.opacity(0.22) : theme.line,
                            style: StrokeStyle(lineWidth: 1.5, dash: imageData == nil ? [7, 6] : [])
                        )
                )
            }
            .buttonStyle(CLPressStyle(scale: 0.99))
        }
    }

    private func fieldSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.display(15, weight: .heavy))
                .foregroundColor(theme.text)
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(theme.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(theme.line, lineWidth: 1)
                )
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [theme.bg.opacity(0), theme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)
            .allowsHitTesting(false)

            CLButton(
                label: canSubmit ? "Submit for review" : "Complete proof first",
                kind: .primary,
                size: .lg,
                full: true,
                theme: theme
            ) {
                guard let claim, canSubmit else { return }
                haptic(.medium)
                state.submitProof(claimId: claim.id, imageData: imageData, link: link, answer: answer)
            }
            .opacity(canSubmit ? 1 : 0.5)
            .disabled(!canSubmit)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
            .background(theme.bg)
        }
    }
}
