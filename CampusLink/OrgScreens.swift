import SwiftUI

// MARK: - Org Home Screen
struct OrgHomeScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private let org = (name: "Tri Delta", members: 84)
    private var sponsoredTotal: Int {
        sampleOrgEvents.filter { $0.status == .sponsored }
            .compactMap { $0.value.flatMap { Int($0.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")) } }
            .reduce(0, +)
    }
    private var pitchCount: Int { sampleOrgEvents.filter { $0.status == .pitching }.count }

    var body: some View {
        CLScrollView(theme: theme, topFade: 30) {
            VStack(alignment: .leading, spacing: 0) {
                // Greeting
                HStack {
                    Button { state.setTab(.me) } label: {
                        HStack(spacing: 8) {
                            Text("Δ")
                                .font(.display(11))
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                                .background(Circle().fill(theme.primary))
                            Text(org.name).font(.display(14)).foregroundColor(.white)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button { state.setTab(.me) } label: {
                        Text("\(org.members) members")
                            .font(.display(14)).foregroundColor(theme.text)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16).padding(.top, 8)

                // Get sponsored hero
                Button { state.setTab(.pitch) } label: {
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 0) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 42, weight: .heavy))
                                .foregroundColor(theme.primary)
                                .rotationEffect(.degrees(-3))
                                .padding(14)
                                .stickerOutline(fill: .white, ink: theme.ink, cornerRadius: 18, borderWidth: theme.borderWidth)
                            Text("get your next\nevent sponsored")
                                .font(.display(28)).foregroundColor(.white).tracking(-0.8).padding(.top, 14)
                            Text("tell us what you're throwing. we'll match brands ready to pay.")
                                .font(.bodyFont(14)).foregroundColor(.white.opacity(0.9)).padding(.top, 8)
                            HStack(spacing: 8) {
                                Text("start a pitch →").font(.display(13)).foregroundColor(.white)
                            }
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                            .padding(.top, 16)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 28, shadow: theme.shadowLg, borderWidth: theme.borderWidth)

                        StickerTag(label: "new!", color: theme.yellow, rotate: 6, theme: theme)
                            .offset(x: -14, y: -14)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20).padding(.top, 14)

                // This semester stats
                SectionHead(title: "this semester", theme: theme)
                HStack(spacing: 10) {
                    CLCard(theme: theme, fill: theme.lime, padding: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("raised in sponsorships")
                                .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6)
                                .foregroundColor(theme.text).opacity(0.7)
                            Text("$\(sponsoredTotal.formatted())")
                                .font(.display(38)).foregroundColor(theme.text).tracking(-1.2)
                            Text("\(sampleOrgEvents.filter { $0.status == .sponsored }.count) events sponsored")
                                .font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.text).opacity(0.75)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    CLCard(theme: theme, fill: theme.pink, padding: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("pitches out")
                                .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6)
                                .foregroundColor(theme.text).opacity(0.7)
                            Text("\(pitchCount)")
                                .font(.display(38)).foregroundColor(theme.text).tracking(-1.2)
                            Text("waiting on brand replies")
                                .font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.text).opacity(0.75)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)

                // Pending brand offers — shown when offers exist
                let pendingOffers = sampleOffers.filter { !state.acceptedDeals.contains($0.id) }
                if !pendingOffers.isEmpty {
                    SectionHead(title: "brand offers", actionLabel: "\(pendingOffers.count) pending", theme: theme)
                    VStack(spacing: 10) {
                        ForEach(pendingOffers) { offer in
                            Button { state.push(.dealDetail, id: offer.id) } label: {
                                HStack(spacing: 14) {
                                    // Brand initials tile
                                    Text(offer.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                                        .font(.display(17)).foregroundColor(offer.accentText)
                                        .frame(width: 50, height: 50)
                                        .stickerCard(fill: offer.accent, ink: theme.ink, cornerRadius: 14, shadow: 0, borderWidth: theme.borderThinWidth)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(offer.brand) sent an offer")
                                            .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.4)
                                            .foregroundColor(theme.textMuted)
                                        Text(offer.eventTitle).font(.display(16)).foregroundColor(theme.text)
                                        Text(offer.offerValue).font(.display(14)).foregroundColor(theme.primary)
                                    }
                                    Spacer()
                                    VStack(spacing: 6) {
                                        StickerTag(label: "review", color: theme.lime, rotate: -3, theme: theme)
                                        Text(offer.expires).font(.bodyFont(10, weight: .bold)).foregroundColor(theme.textMuted)
                                    }
                                }
                                .padding(14)
                                .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 18, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Your events
                SectionHead(title: "your events", actionLabel: "+ new", theme: theme) { state.setTab(.pitch) }
                VStack(spacing: 10) {
                    ForEach(sampleOrgEvents) { evt in
                        OrgEventRow(event: evt, theme: theme) {
                            switch evt.status {
                            case .sponsored:
                                if let offerId = evt.offerId { state.push(.dealDetail, id: offerId) }
                            case .pitching, .draft:
                                state.setTab(.pitch)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Brand inbox preview
                SectionHead(title: "brand inbox", actionLabel: "all", arrow: true, theme: theme) { state.push(.inbox) }
                VStack(spacing: 10) {
                    ForEach(sampleDMs.prefix(2)) { dm in
                        Button { state.push(.dm, id: dm.id) } label: {
                            HStack(spacing: 14) {
                                Text(dm.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                                    .font(.display(16)).foregroundColor(dm.accentText)
                                    .frame(width: 46, height: 46)
                                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(dm.accent))
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(dm.brand).font(.display(15)).foregroundColor(theme.text)
                                        Spacer()
                                        Text(dm.when).font(.bodyFont(11, weight: .semibold)).foregroundColor(theme.textMuted)
                                    }
                                    Text(dm.last).font(.bodyFont(13)).foregroundColor(theme.textMuted).lineLimit(1)
                                }
                                Spacer()
                                if dm.unread > 0 {
                                    StickerTag(label: "\(dm.unread) new", color: theme.primary, rotate: -3, theme: CLTheme.light(primary: theme.primary))
                                }
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 18, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Org Event Row
struct OrgEventRow: View {
    let event: OrgEvent
    let theme: CLTheme
    let action: () -> Void

    private var statusInfo: (color: Color, label: String) {
        switch event.status {
        case .sponsored: return (theme.lime, "sponsored · \(event.value ?? "")")
        case .pitching:  return (theme.pink, "pitching · 3 brands")
        case .draft:     return (theme.surfaceAlt, "draft")
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    let parts = event.date.split(separator: " ")
                    VStack(spacing: 2) {
                        Text(parts.first.map(String.init) ?? "")
                            .font(.bodyFont(9, weight: .bold)).textCase(.uppercase).tracking(0.6)
                            .foregroundColor(theme.text).opacity(0.6)
                        Text(parts.last.map(String.init) ?? "")
                            .font(.display(20)).foregroundColor(theme.text).tracking(-0.5)
                    }
                    .frame(width: 48, height: 48)
                    .stickerOutline(fill: theme.surfaceAlt, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.title).font(.display(17)).foregroundColor(theme.text).tracking(-0.3)
                        Text("\(event.kind) · ~\(event.est) students").font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                }
                Text(statusInfo.label)
                    .font(.display(12))
                    .foregroundColor(theme.text)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .stickerCard(fill: statusInfo.color, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
            }
            .padding(16)
            .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Org Events List
struct OrgEventsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    @State private var filter = "all"
    private let filters: [(id: String, label: String)] = [("all","all"),("open-pitch","pitching"),("sponsored","sponsored"),("draft","drafts")]

    private var list: [OrgEvent] {
        if filter == "all" { return sampleOrgEvents }
        return sampleOrgEvents.filter { $0.status.rawValue == filter }
    }

    var body: some View {
        CLScrollView(theme: theme, topFade: 30) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .bottom) {
                    Text("your events").font(.display(36)).foregroundColor(theme.text).tracking(-1.2)
                    Spacer()
                    CLButton(label: "new", kind: .primary, size: .sm, icon: "plus", theme: theme) { state.setTab(.pitch) }
                }
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.id) { f in
                            CLChip(label: f.label, selected: filter == f.id, theme: theme) { filter = f.id }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 14)

                if list.isEmpty {
                    CLEmptyState(
                        icon: "calendar.badge.plus",
                        title: "no events here",
                        subtitle: filter == "all" ? "create your first pitch to get started" : "no events with this status yet",
                        actionLabel: filter != "all" ? "show all" : nil,
                        action: filter != "all" ? { filter = "all" } : nil,
                        theme: theme
                    )
                } else {
                    VStack(spacing: 10) {
                        ForEach(list) { evt in
                            OrgEventRow(event: evt, theme: theme) {
                                switch evt.status {
                                case .sponsored:
                                    if let offerId = evt.offerId { state.push(.dealDetail, id: offerId) }
                                case .pitching, .draft:
                                    state.setTab(.pitch)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Pitch Flow
struct PitchFlowScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    @State private var step = 0
    @State private var draft = PitchDraft()

    var body: some View {
        switch step {
        case 0: pitchIntro
        case 5: pitchSent
        default:
            VStack(spacing: 0) {
                CLTopBar(title: "step \(step) / 4", onBack: { step -= 1 }, theme: theme)
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(1...4, id: \.self) { i in
                        ZStack {
                            RoundedRectangle(cornerRadius: 3, style: .continuous).fill(theme.ink)
                            RoundedRectangle(cornerRadius: 1, style: .continuous).fill(i <= step ? theme.primary : theme.surface).padding(theme.borderThinWidth)
                        }
                        .frame(height: 6)
                    }
                }
                .padding(.horizontal, 24).padding(.bottom, 16)

                switch step {
                case 1: PitchStepBasics(draft: $draft, theme: theme) { step = 2 }
                case 2: PitchStepAudience(draft: $draft, theme: theme) { step = 3 }
                case 3: PitchStepAsk(draft: $draft, theme: theme) { step = 4 }
                case 4: PitchStepMatches(draft: $draft, theme: theme) { step = 5; haptic(.heavy); state.showToast("pitch sent to brands!", icon: "paperplane.fill") }
                default: EmptyView()
                }
            }
            .background(theme.bg.ignoresSafeArea())
        }
    }

    @ViewBuilder
    private var pitchIntro: some View {
        VStack(spacing: 0) {
            CLScrollView(theme: theme, bottomFade: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    CLTopBar(onBack: { state.setTab(.home) }, theme: theme)
                    Text("new pitch")
                        .font(.display(12)).tracking(0.4).textCase(.uppercase).foregroundColor(theme.text)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                        .rotationEffect(.degrees(-3))
                        .padding(.leading, 24)

                    Text("tell us what\nyou're throwing.")
                        .font(.display(44)).foregroundColor(theme.text).tracking(-1.6)
                        .padding(.horizontal, 24).padding(.top, 20)
                    Text("takes 2 minutes. we'll match you with brands actively looking to sponsor on your campus.")
                        .font(.bodyFont(16)).foregroundColor(theme.textMuted).lineSpacing(3)
                        .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 28)

                    VStack(spacing: 10) {
                        ForEach([(1,"event basics","name, date, vibe"),(2,"your crowd","who shows up + how many"),(3,"what you need","cash, product, pop-up, drop"),(4,"brand matches","pick who you pitch to")], id: \.0) { n, t, s in
                            HStack(spacing: 14) {
                                Text("\(n)").font(.display(16)).foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 10, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(t).font(.display(15)).foregroundColor(theme.text)
                                    Text(s).font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.textMuted)
                                }
                                Spacer()
                            }
                            .padding(14)
                            .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 16, borderWidth: theme.borderThinWidth)
                        }
                    }
                    .padding(.horizontal, 24)
                    Color.clear.frame(height: 24)
                }
                .padding(.top, 54)
            }
            pitchFooter(label: "start pitch →") { step = 1 }
        }
        .background(theme.bg.ignoresSafeArea())
    }

    @ViewBuilder
    private var pitchSent: some View {
        ZStack {
            theme.lime.ignoresSafeArea()
            Canvas { ctx, sz in
                for i in stride(from: -sz.width, to: sz.width * 2, by: 80) {
                    var p = Path(); p.move(to: CGPoint(x: i, y: 0)); p.addLine(to: CGPoint(x: i+sz.height, y: sz.height)); p.addLine(to: CGPoint(x: i+sz.height+40, y: sz.height)); p.addLine(to: CGPoint(x: i+40, y: 0)); p.closeSubpath()
                    ctx.fill(p, with: .color(Color.black.opacity(0.04)))
                }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button { state.setTab(.home) } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .heavy)).foregroundColor(theme.text)
                            .frame(width: 40, height: 40)
                            .stickerCard(fill: .white, ink: theme.ink, cornerRadius: 20, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 62)
                Spacer()
                VStack(spacing: 0) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 50, weight: .heavy)).foregroundColor(theme.lime)
                        .frame(width: 110, height: 110)
                        .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 30, shadow: theme.shadowLg, borderWidth: theme.borderWidth)
                        .padding(.bottom, 24)
                    StickerTag(label: "pitch sent", color: .white, rotate: -3, theme: CLTheme.light())
                        .padding(.bottom, 14)
                    Text("\(sampleBrands.prefix(4).count) brands\ngot it.")
                        .font(.display(38)).foregroundColor(theme.text).tracking(-1.2).multilineTextAlignment(.center)
                    Text("we usually hear back in 1-3 days. you'll get a notif the second a brand bites.")
                        .font(.bodyFont(15)).foregroundColor(theme.text).opacity(0.75).multilineTextAlignment(.center)
                        .lineSpacing(3).padding(.top, 14).padding(.horizontal, 32)
                }
                Spacer()
                CLButton(label: "back to home", kind: .ink, size: .lg, full: true, theme: theme) { state.setTab(.home) }
                    .padding(.horizontal, 20).padding(.bottom, 34)
            }
        }
    }

    private func pitchFooter(label: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            CLButton(label: label, kind: .primary, size: .lg, full: true, theme: theme, action: action)
                .opacity(disabled ? 0.4 : 1)
                .disabled(disabled)
                .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 20)
        }
        .background(theme.bg)
        .softChromeEdge(theme: theme, edge: .top)
    }
}

// MARK: - Pitch Steps

struct PitchDraft {
    var title = "Date Party · Disco"
    var kind = "Social"
    var date = "May 3"
    var est = 150
    var audience: [String] = ["greek", "social", "fashion"]
    var ask = "product"
    var cash = 800
    var deliverables: [String] = ["IG reels", "on-site signage", "sample 200+ students"]
}

struct PitchStepBasics: View {
    @Binding var draft: PitchDraft
    let theme: CLTheme
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CLScrollView(theme: theme, topFade: 18, bottomFade: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("the basics.").font(.display(32)).foregroundColor(theme.text).tracking(-1).padding(.horizontal, 24).padding(.bottom, 8)
                    Text("what is it, when is it, what kind of event?").font(.bodyFont(14)).foregroundColor(theme.textMuted).padding(.horizontal, 24).padding(.bottom, 24)

                    fieldLabel("event name")
                    fieldInput($draft.title)

                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 8) {
                            compactFieldLabel("date")
                            compactFieldInput($draft.date)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            compactFieldLabel("est. attendance")
                            TextField("150", value: $draft.est, format: .number)
                                .font(.display(16, weight: .bold)).foregroundColor(theme.text)
                                .frame(height: 48).padding(.horizontal, 14)
                                .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)

                    fieldLabel("event type")
                    FlowLayout(spacing: 8) {
                        ForEach(["Formal","Social","Philanthropy","Recruitment","Game day","Pop-up"], id: \.self) { k in
                            CLChip(label: k, selected: draft.kind == k, theme: theme) { draft.kind = k }
                        }
                    }
                    .padding(.horizontal, 24)
                    Color.clear.frame(height: 24)
                }
            }
            pitchFooter(disabled: draft.title.isEmpty || draft.date.isEmpty)
        }
    }

    private func fieldLabel(_ t: String) -> some View {
        Text(t).font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6).foregroundColor(theme.text).opacity(0.7)
            .padding(.horizontal, 24).padding(.bottom, 8).padding(.top, 14)
    }
    private func fieldInput(_ binding: Binding<String>) -> some View {
        TextField("", text: binding)
            .font(.display(16, weight: .bold)).foregroundColor(theme.text)
            .frame(height: 48).padding(.horizontal, 14)
            .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
            .padding(.horizontal, 24)
    }
    private func compactFieldLabel(_ t: String) -> some View {
        Text(t)
            .font(.bodyFont(11, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.6)
            .foregroundColor(theme.text)
            .opacity(0.7)
            .padding(.top, 2)
    }
    private func compactFieldInput(_ binding: Binding<String>) -> some View {
        TextField("", text: binding)
            .font(.display(16, weight: .bold))
            .foregroundColor(theme.text)
            .frame(height: 48)
            .padding(.horizontal, 14)
            .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
    }
    private func pitchFooter(disabled: Bool = false) -> some View {
        VStack(spacing: 0) {
            CLButton(label: "next", kind: .primary, size: .lg, full: true, theme: theme, action: onNext)
                .opacity(disabled ? 0.4 : 1).disabled(disabled)
                .padding(.horizontal, 24).padding(.vertical, 12).padding(.bottom, 20)
        }
        .background(theme.bg)
        .softChromeEdge(theme: theme, edge: .top)
    }
}

struct PitchStepAudience: View {
    @Binding var draft: PitchDraft
    let theme: CLTheme
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CLScrollView(theme: theme, topFade: 18, bottomFade: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("your crowd.").font(.display(32)).foregroundColor(theme.text).tracking(-1).padding(.horizontal, 24).padding(.bottom, 8)
                    Text("who actually shows up to this? brands match harder when this is real.").font(.bodyFont(14)).foregroundColor(theme.textMuted).padding(.horizontal, 24).padding(.bottom, 24)

                    Text("describes them (pick all)").font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6).foregroundColor(theme.text).opacity(0.7).padding(.horizontal, 24).padding(.bottom, 8)
                    FlowLayout(spacing: 8) {
                        ForEach(audienceInterests) { i in
                            CLChip(label: i.label, selected: draft.audience.contains(i.id), icon: i.icon, theme: theme) {
                                if draft.audience.contains(i.id) { draft.audience.removeAll { $0 == i.id } }
                                else { draft.audience.append(i.id) }
                            }
                        }
                    }
                    .padding(.horizontal, 24).padding(.bottom, 18)

                    Text("typical drink situation").font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6).foregroundColor(theme.text).opacity(0.7).padding(.horizontal, 24).padding(.bottom, 8)
                    FlowLayout(spacing: 8) {
                        ForEach(["Open bar","BYO","Non-alc","Coffee + snacks"], id: \.self) { k in
                            CLChip(label: k, theme: theme, action: nil)
                        }
                    }
                    .padding(.horizontal, 24)
                    Color.clear.frame(height: 24)
                }
            }
            VStack(spacing: 0) {
                CLButton(label: "next", kind: .primary, size: .lg, full: true, theme: theme, action: onNext)
                    .opacity(draft.audience.isEmpty ? 0.4 : 1).disabled(draft.audience.isEmpty)
                    .padding(.horizontal, 24).padding(.vertical, 12).padding(.bottom, 20)
            }
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
    }
}

struct PitchStepAsk: View {
    @Binding var draft: PitchDraft
    let theme: CLTheme
    let onNext: () -> Void

    private let asks: [(id: String, label: String, sub: String, icon: String, color: Color)] = [
        ("cash",    "cash sponsor",  "brand pays your chapter",       "dollarsign.circle.fill", Color(hex: "C8FF3D")),
        ("product", "free product",  "samples + giveaways",           "gift.fill",              Color(hex: "FFD60A")),
        ("popup",   "on-site pop-up","brand activates at the event",  "storefront.fill",        Color(hex: "FF8AB3")),
        ("drop",    "mystery drop",  "reward for RSVPs",              "shippingbox.fill",       Color(hex: "FF1F1F")),
    ]

    var body: some View {
        VStack(spacing: 0) {
            CLScrollView(theme: theme, topFade: 18, bottomFade: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("the ask.").font(.display(32)).foregroundColor(theme.text).tracking(-1).padding(.horizontal, 24).padding(.bottom, 8)
                    Text("what do you want from a brand?").font(.bodyFont(14)).foregroundColor(theme.textMuted).padding(.horizontal, 24).padding(.bottom, 24)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(asks, id: \.id) { a in
                            let sel = draft.ask == a.id
                            Button { draft.ask = a.id } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: a.icon)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(sel ? a.color : (a.id == "drop" ? .white : theme.text))
                                        .frame(width: 38, height: 38)
                                        .stickerCard(fill: sel ? theme.text : a.color, ink: theme.ink, cornerRadius: 11, shadow: sel ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                                    Text(a.label).font(.display(15)).foregroundColor(a.id == "drop" && sel ? .white : theme.text)
                                    Text(a.sub).font(.bodyFont(12)).foregroundColor((a.id == "drop" && sel ? Color.white : theme.text).opacity(0.75))
                                    Spacer()
                                }
                                .padding(14).frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
                                .stickerCard(fill: sel ? a.color : theme.surface, ink: theme.ink, cornerRadius: 18, shadow: sel ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24).padding(.bottom, 18)

                    if draft.ask == "cash" {
                        Text("target sponsorship amount").font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6).foregroundColor(theme.text).opacity(0.7).padding(.horizontal, 24).padding(.bottom, 8)
                        HStack {
                            TextField("$800", value: $draft.cash, format: .currency(code: "USD"))
                                .font(.display(16, weight: .bold)).foregroundColor(theme.text)
                                .frame(height: 48).padding(.horizontal, 14)
                                .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                        }
                        .padding(.horizontal, 24).padding(.bottom, 18)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Text("what you'll give back (pick all)").font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6).foregroundColor(theme.text).opacity(0.7).padding(.horizontal, 24).padding(.bottom, 8)
                    FlowLayout(spacing: 8) {
                        ForEach(["IG reels","TikToks","on-site signage","sample 200+ students","co-branded merch","email blast"], id: \.self) { d in
                            let sel = draft.deliverables.contains(d)
                            CLChip(label: d, selected: sel, theme: theme) {
                                if sel { draft.deliverables.removeAll { $0 == d } } else { draft.deliverables.append(d) }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    Color.clear.frame(height: 24)
                }
                .animation(.spring(response: 0.3), value: draft.ask)
            }
            VStack(spacing: 0) {
                CLButton(label: "next", kind: .primary, size: .lg, full: true, theme: theme, action: onNext)
                    .padding(.horizontal, 24).padding(.vertical, 12).padding(.bottom, 20)
            }
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
    }
}

struct PitchStepMatches: View {
    @Binding var draft: PitchDraft
    let theme: CLTheme
    let onSubmit: () -> Void

    @State private var picked: Set<String> = Set(sampleBrands.prefix(4).map { $0.id })
    private let brands = Array(sampleBrands.prefix(4))

    var body: some View {
        VStack(spacing: 0) {
            CLScrollView(theme: theme, topFade: 18, bottomFade: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("brand matches.").font(.display(32)).foregroundColor(theme.text).tracking(-1).padding(.horizontal, 24).padding(.bottom, 8)
                    Text("\(brands.count) brands look like a fit. pitch goes to whoever you pick.").font(.bodyFont(14)).foregroundColor(theme.textMuted).padding(.horizontal, 24).padding(.bottom, 22)

                    VStack(spacing: 10) {
                        ForEach(brands) { b in
                            let sel = picked.contains(b.id)
                            Button { if sel { picked.remove(b.id) } else { picked.insert(b.id) } } label: {
                                HStack(spacing: 14) {
                                    BrandLogoTile(
                                        brand: b,
                                        size: 50,
                                        fill: sel ? b.accent : b.color,
                                        ink: theme.ink,
                                        textColor: sel ? b.color : b.accent,
                                        cornerRadius: 14,
                                        shadow: sel ? theme.shadowSm : 0,
                                        borderWidth: theme.borderThinWidth,
                                        padding: 8
                                    )
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(b.name).font(.display(17)).foregroundColor(sel ? b.accent : theme.text)
                                        Text("\(b.cat) · \(b.vibe) · \(b.openOpps) live opps").font(.bodyFont(12)).foregroundColor((sel ? b.accent : theme.text).opacity(0.85))
                                    }
                                    Spacer()
                                    if sel {
                                        Image(systemName: "checkmark").font(.system(size: 14, weight: .black)).foregroundColor(b.accent)
                                            .frame(width: 28, height: 28)
                                            .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                                    } else {
                                        ZStack {
                                            Circle().fill(theme.ink).frame(width: 28, height: 28)
                                            Circle().fill(theme.surface).padding(theme.borderThinWidth).frame(width: 28, height: 28)
                                        }
                                    }
                                }
                                .padding(14)
                                .stickerCard(fill: sel ? b.color : theme.surface, ink: theme.ink, cornerRadius: 20, shadow: sel ? theme.shadowMd : theme.shadowSm, borderWidth: theme.borderWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Summary card
                    CLCard(theme: theme, fill: theme.surfaceAlt, padding: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("your pitch").font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6).foregroundColor(theme.text).opacity(0.6)
                            Text(draft.title).font(.display(18)).foregroundColor(theme.text)
                            Text("\(draft.date) · ~\(draft.est) students · \(draft.kind) · asking for \(draft.ask == "cash" ? "$\(draft.cash)" : draft.ask)").font(.bodyFont(13, weight: .semibold)).foregroundColor(theme.text).opacity(0.75)
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 22)

                    Color.clear.frame(height: 24)
                }
            }
            VStack(spacing: 0) {
                CLButton(label: "send pitch to \(picked.count) brand\(picked.count == 1 ? "" : "s")", kind: .primary, size: .lg, icon: "paperplane.fill", full: true, theme: theme, action: onSubmit)
                    .opacity(picked.isEmpty ? 0.4 : 1).disabled(picked.isEmpty)
                    .padding(.horizontal, 24).padding(.vertical, 12).padding(.bottom, 20)
            }
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
    }
}

// MARK: - Deal Detail Screen
struct DealDetailScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var offer: DealOffer { state.detailOffer ?? sampleOffers[0] }
    private var brand: Brand? { sampleBrands.first { $0.name == offer.brand } }
    private var accepted: Bool { state.acceptedDeals.contains(offer.id) }

    private let offerTypeIcon: [String: String] = [
        "cash": "dollarsign.circle.fill",
        "product": "gift.fill",
        "popup": "storefront.fill",
        "drop": "shippingbox.fill",
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            CLScrollView(theme: theme, bottomFade: 0) {
                VStack(spacing: 0) {
                    // Hero — brand color header
                    ZStack(alignment: .topLeading) {
                        offer.accent.frame(height: 260).ignoresSafeArea(edges: .top)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Button { state.pop() } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(theme.text)
                                        .frame(width: 40, height: 40)
                                        .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 20, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                                }
                                .buttonStyle(.plain)
                                Spacer()
                                StickerTag(label: offer.expires, color: theme.yellow, rotate: 3, theme: theme)
                            }
                            .padding(.horizontal, 20).padding(.top, 62)

                            HStack(alignment: .top, spacing: 14) {
                                if let brand {
                                    BrandLogoTile(brand: brand, size: 64, fill: offer.accentText, ink: theme.ink, textColor: offer.accent, cornerRadius: 18, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth, padding: 10)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(offer.brand)
                                        .font(.display(24)).foregroundColor(offer.accentText).tracking(-0.6)
                                    Text("offer for \(offer.eventTitle)")
                                        .font(.bodyFont(13, weight: .semibold)).foregroundColor(offer.accentText.opacity(0.75))
                                }
                            }
                            .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 20)
                        }
                    }
                    .frame(height: 260)
                    .overlay(alignment: .bottom) { theme.ink.frame(height: theme.borderWidth) }

                    // Offer value card
                    CLCard(theme: theme, fill: theme.lime, padding: 18) {
                        HStack(spacing: 16) {
                            Image(systemName: offerTypeIcon[offer.offerType] ?? "gift.fill")
                                .font(.system(size: 24, weight: .bold)).foregroundColor(theme.lime)
                                .frame(width: 56, height: 56)
                                .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("they're offering")
                                    .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.8)
                                    .foregroundColor(theme.text).opacity(0.65)
                                Text(offer.offerValue)
                                    .font(.display(28)).foregroundColor(theme.text).tracking(-0.6)
                                Text(offer.offerType.capitalized + " sponsorship")
                                    .font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.text).opacity(0.7)
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 18)

                    // What you give back
                    SectionHead(title: "what you give back", theme: theme)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(offer.deliverables.enumerated()), id: \.0) { i, d in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(i + 1)")
                                    .font(.display(13)).foregroundColor(.white)
                                    .frame(width: 26, height: 26)
                                    .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                                Text(d).font(.bodyFont(14)).foregroundColor(theme.text).lineSpacing(2)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Stats row
                    SectionHead(title: "deal terms", theme: theme)
                    HStack(spacing: 10) {
                        StatBox(value: offer.offerValue, label: "offer", color: theme.lime, theme: theme)
                        StatBox(value: "\(offer.deliverables.count)", label: "deliverables", theme: theme)
                        StatBox(value: offer.expires, label: "expires", color: theme.yellow, theme: theme)
                    }
                    .padding(.horizontal, 20)

                    Color.clear.frame(height: 160)
                }
            }

            // CTA bar
            if accepted {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(theme.lime)
                    Text("deal accepted — check your inbox")
                        .font(.display(15)).foregroundColor(theme.text)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.vertical, 16).padding(.bottom, 20)
                .background(theme.bg)
                .softChromeEdge(theme: theme, edge: .top)
            } else {
                HStack(spacing: 10) {
                    Button {
                        haptic(.light)
                        state.pop()
                        state.showToast("offer declined", icon: "xmark")
                    } label: {
                        Text("decline")
                            .font(.display(16)).foregroundColor(theme.text)
                            .frame(height: 56).padding(.horizontal, 24)
                            .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderWidth)
                    }
                    .buttonStyle(.plain)

                    CLButton(label: "accept deal", kind: .primary, size: .lg, icon: "checkmark", full: true, theme: theme) {
                        haptic(.heavy)
                        state.acceptedDeals.append(offer.id)
                        state.showToast("deal accepted! 🎉", icon: "checkmark.circle.fill")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { state.pop() }
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 20)
                .background(theme.bg)
                .softChromeEdge(theme: theme, edge: .top)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
