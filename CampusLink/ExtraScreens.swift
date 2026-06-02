import SwiftUI

// MARK: - Drops Hub
struct DropsHubScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private let walletDrops: [(brand: String, reward: String, when: String, accent: Color, accentText: Color, used: Bool)] = [
        ("Liquid Death", "free 4-pack",     "tonight · 9PM",    Color(hex: "0E0B0B"), .white,              false),
        ("Celsius",      "finisher 12-pack", "sat 8AM",          Color(hex: "FFD60A"), Color(hex: "1a0e0e"),false),
        ("Olipop",       "free can + sticker","sun 10AM",        Color(hex: "FF6B9B"), .white,              false),
        ("Duolingo",     "3mo Super",        "used · last week", Color(hex: "58CC02"), .white,              true),
    ]

    private var dropPink: Color { theme.primary }

    var body: some View {
        CLScrollView(theme: theme, topFade: 30) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("drops")
                        .font(.display(36)).foregroundColor(theme.text).tracking(-1.2)
                    Text("go to brand events. unlock free stuff. no catch.")
                        .font(.bodyFont(14)).foregroundColor(theme.textMuted)
                }
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 18)

                // Mystery drop hero — hot pink card
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Icon in white rounded square
                        MysteryBoxIcon(size: 46, color: dropPink)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                            )
                            .padding(.bottom, 16)

                        Text("the mystery drop")
                            .font(.display(28)).foregroundColor(.white).tracking(-0.8)
                            .padding(.bottom, 10)

                        // Inline +DROP chip description using FlowLayout
                        FlowLayout(spacing: 4) {
                            Text("go to any event w/ a")
                                .font(.bodyFont(14)).foregroundColor(.white.opacity(0.85))
                            Text("+DROP")
                                .font(.display(13, weight: .black))
                                .foregroundColor(theme.text)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                            Text("tag this week to unlock.")
                                .font(.bodyFont(14)).foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.bottom, 18)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("unlocks in")
                                .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.8)
                                .foregroundColor(.white.opacity(0.65))
                            Text(state.dropTimer)
                                .font(.display(40)).foregroundColor(.white).tracking(-1.5).monospacedDigit()
                        }
                    }
                    .padding(22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .stickerCard(fill: dropPink, ink: theme.ink, cornerRadius: 24, shadow: 5, borderWidth: theme.borderWidth)

                    // "THIS WEEK!" sticker — positioned above-right of card
                    StickerTag(label: "this week!", rotate: 8, theme: theme)
                        .offset(x: -10, y: -16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 6)

                // Wallet section
                HStack {
                    Text("your wallet")
                        .font(.display(22)).foregroundColor(theme.text)
                    Spacer()
                    Text("\(walletDrops.filter { !$0.used }.count) unused")
                        .font(.display(13)).foregroundColor(theme.text).underline()
                }
                .padding(.horizontal, 20).padding(.top, 26).padding(.bottom, 14)

                VStack(spacing: 10) {
                    ForEach(Array(walletDrops.enumerated()), id: \.0) { _, drop in
                        HStack(spacing: 14) {
                            // Logo — no ink border, just colored fill
                            Text(drop.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                                .font(.display(17))
                                .foregroundColor(drop.accentText)
                                .frame(width: 50, height: 50)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(drop.accent))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(drop.brand.uppercased())
                                    .font(.bodyFont(11, weight: .bold))
                                    .tracking(0.4)
                                    .foregroundColor(theme.textMuted)
                                Text(drop.reward)
                                    .font(.display(16))
                                    .foregroundColor(drop.used ? theme.textFaint : theme.text)
                                    .strikethrough(drop.used, color: theme.textMuted)
                                Text(drop.when)
                                    .font(.bodyFont(12, weight: .semibold))
                                    .foregroundColor(theme.textMuted)
                            }
                            Spacer()
                            if !drop.used {
                                // "show QR" dark pill — no shadow offset, just a round pill
                                Text("show \(Text("QR").underline())")
                                    .font(.display(13))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(Capsule().fill(theme.ink))
                            }
                        }
                        .padding(14)
                        // Wallet cards: thin border, no offset shadow
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(theme.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(theme.ink, lineWidth: theme.borderThinWidth)
                        )
                        .opacity(drop.used ? 0.45 : 1)
                    }
                }
                .padding(.horizontal, 20)

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Drop Reveal Screen
struct DropRevealScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var event: CLEvent? { sampleEvents.first { $0.id == state.detailId } }
    private var reward: EventDrop { event?.drop ?? EventDrop(brand: "Liquid Death", reward: "free 4-pack at the door") }

    enum Phase { case ready, opening, revealed }
    @State private var phase: Phase = .ready
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        ZStack {
            (phase == .revealed ? theme.yellow : theme.primary).ignoresSafeArea()

            // Diagonal stripe bg
            Canvas { ctx, sz in
                for i in stride(from: -sz.width, to: sz.width * 2, by: 80) {
                    var p = Path()
                    p.move(to: CGPoint(x: i, y: 0)); p.addLine(to: CGPoint(x: i + sz.height, y: sz.height))
                    p.addLine(to: CGPoint(x: i + sz.height + 40, y: sz.height)); p.addLine(to: CGPoint(x: i + 40, y: 0))
                    p.closeSubpath()
                    ctx.fill(p, with: .color(.white.opacity(0.06)))
                }
            }
            .ignoresSafeArea()

            // Confetti
            ForEach(confettiPieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 8, height: 14)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(piece.position)
                    .opacity(piece.opacity)
            }

            VStack {
                HStack {
                    Button { state.pop() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(theme.text)
                            .frame(width: 40, height: 40)
                            .stickerCard(fill: .white, ink: theme.ink, cornerRadius: 20, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 8)

                Spacer()

                if phase != .revealed {
                    VStack(spacing: 28) {
                        StickerTag(label: "you unlocked a drop", color: theme.yellow, rotate: -6, theme: theme)

                        ZStack {
                            MysteryBoxIcon(size: 120, color: theme.primary)
                                .padding(40)
                                .stickerCard(fill: .white, ink: theme.ink, cornerRadius: 36, shadow: theme.shadowLg, borderWidth: theme.borderWidth)
                        }
                        .modifier(BobbingModifier(active: phase == .ready))
                        .scaleEffect(phase == .opening ? 1.05 : 1)
                        .animation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true), value: phase == .opening)

                        VStack(spacing: 8) {
                            Text(phase == .opening ? "opening…" : "tap to open")
                                .font(.display(32)).foregroundColor(.white).tracking(-1)
                            Text(phase == .opening ? "no peeking" : "from \(reward.brand) · only at \(event?.title ?? "Rose Formal")")
                                .font(.bodyFont(14, weight: .semibold)).foregroundColor(.white.opacity(0.9))
                        }

                        if phase == .ready {
                            Button { openBox() } label: {
                                Text("open it →")
                                    .font(.display(18))
                                    .foregroundColor(theme.primary)
                                    .padding(.horizontal, 40).padding(.vertical, 18)
                                    .stickerCard(fill: .white, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        MysteryBoxIcon(size: 56, color: theme.yellow)
                            .padding(22)
                            .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 28, shadow: theme.shadowLg, borderWidth: theme.borderWidth)
                            .padding(.bottom, 24)

                        StickerTag(label: "you got", color: .white, rotate: -3, theme: CLTheme.light())
                            .padding(.bottom, 14)
                        Text(reward.brand)
                            .font(.display(38)).foregroundColor(theme.text).tracking(-1.2)
                        Text(reward.reward)
                            .font(.display(22, weight: .bold)).foregroundColor(theme.text.opacity(0.85)).tracking(-0.5)
                            .padding(.top, 8)
                        HStack(spacing: 8) {
                            Text("+100 XP")
                            Text("·").opacity(0.4)
                            Text("show at the door")
                        }
                        .font(.display(14))
                        .foregroundColor(theme.yellow)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                        .padding(.top, 24)
                    }
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
                }

                Spacer()

                if phase == .revealed {
                    Button { state.pop() } label: {
                        Text("save to wallet")
                            .font(.display(17))
                            .foregroundColor(theme.yellow)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 28, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20).padding(.bottom, 34)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }

    private func openBox() {
        phase = .opening
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                phase = .revealed
                state.xp += 100
            }
            spawnConfetti()
        }
    }

    private func spawnConfetti() {
        let colors: [Color] = [theme.primary, .white, theme.text, theme.primary]
        confettiPieces = (0..<14).map { i in
            ConfettiPiece(
                id: i,
                color: colors[i % colors.count],
                position: CGPoint(x: CGFloat(i) * 28 + 40, y: 300),
                rotation: Double.random(in: 0...360),
                opacity: 1
            )
        }
        withAnimation(.easeOut(duration: 1.2)) {
            for i in confettiPieces.indices {
                confettiPieces[i].position.y += 120
                confettiPieces[i].rotation += 360
                confettiPieces[i].opacity = 0
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: Int
    var color: Color
    var position: CGPoint
    var rotation: Double
    var opacity: Double
}

struct BobbingModifier: ViewModifier {
    let active: Bool
    @State private var bobbing = false

    func body(content: Content) -> some View {
        content
            .offset(y: bobbing && active ? -8 : 0)
            .rotationEffect(.degrees(bobbing && active ? 4 : -4))
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    bobbing = true
                }
            }
    }
}

// MARK: - DM Thread Screen
struct DMThreadScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var dm: DM { state.detailDM ?? sampleDMs[0] }

    struct Message: Identifiable {
        let id = UUID()
        let who: String  // "me" or "them"
        let text: String
        let time: String
    }

    @State private var messages: [Message] = []
    @State private var draft = ""
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                CLTopBar(onBack: { state.pop() }, theme: theme)

                HStack(spacing: 12) {
                    Text(dm.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                        .font(.display(16)).foregroundColor(dm.accentText)
                        .frame(width: 46, height: 46)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(dm.accent))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dm.brand).font(.display(16)).foregroundColor(theme.text)
                        HStack(spacing: 4) {
                            Circle().fill(theme.success).frame(width: 6, height: 6)
                            Text("verified · usually replies in 2h")
                                .font(.bodyFont(12, weight: .bold)).foregroundColor(theme.success)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.bottom, 14)
                .softChromeEdge(theme: theme, edge: .bottom)

                ScrollViewReader { proxy in
                    CLScrollView(theme: theme, topFade: 18) {
                        LazyVStack(spacing: 8) {
                            ForEach(messages) { msg in
                                HStack {
                                    if msg.who == "me" { Spacer(minLength: 60) }
                                    Text(msg.text)
                                        .font(.bodyFont(15))
                                        .foregroundColor(msg.who == "me" ? .white : theme.text)
                                        .padding(.horizontal, 14).padding(.vertical, 10)
                                        .stickerCard(fill: msg.who == "me" ? theme.primary : theme.surface, ink: theme.ink, cornerRadius: 18, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                                    if msg.who == "them" { Spacer(minLength: 60) }
                                }
                                .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 20)
                        .padding(.bottom, 80)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        setupMessages()
                    }
                }
            }

            // Input bar
            HStack(spacing: 8) {
                Button {} label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .heavy)).foregroundColor(theme.text)
                        .frame(width: 40, height: 40)
                        .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 20, shadow: 0, borderWidth: theme.borderThinWidth)
                }
                .buttonStyle(.plain)

                HStack {
                    TextField("message…", text: $draft)
                        .font(.bodyFont(15)).foregroundColor(theme.text)
                        .onSubmit { sendMessage() }
                }
                .frame(height: 40)
                .padding(.horizontal, 14)
                .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 20, shadow: 0, borderWidth: theme.borderThinWidth)

                Button { sendMessage() } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .heavy)).foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .stickerCard(fill: draft.isEmpty ? theme.surfaceAlt : theme.primary, ink: theme.ink, cornerRadius: 20, shadow: draft.isEmpty ? 0 : theme.shadowSm, borderWidth: theme.borderThinWidth)
                }
                .buttonStyle(.plain)
                .disabled(draft.isEmpty)
            }
            .padding(.horizontal, 16).padding(.vertical, 10).padding(.bottom, 34)
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
        .background(theme.bg.ignoresSafeArea())
    }

    private func setupMessages() {
        messages = [
            Message(who: "them", text: "hey @\(state.handle) 👋 saw you crushed our last activation", time: "11:02"),
            Message(who: "them", text: "we have a new drop campaign opening next week — want first dibs?", time: "11:02"),
            Message(who: "me",   text: "absolutely. send the brief?", time: "11:04"),
            Message(who: "them", text: "just sent. 4 weeks, $400 + free product all spring", time: "11:05"),
            Message(who: "them", text: dm.last, time: dm.when),
        ]
    }

    private func sendMessage() {
        guard !draft.isEmpty else { return }
        let text = draft
        draft = ""
        messages.append(Message(who: "me", text: text, time: "now"))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            messages.append(Message(who: "them", text: "on it 🤝", time: "now"))
        }
    }
}

// MARK: - DM Inbox Screen
struct DMInboxScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "messages", onBack: { state.pop() }, theme: theme)

            if sampleDMs.isEmpty {
                CLEmptyState(
                    icon: "message.fill",
                    title: "no messages yet",
                    subtitle: "connect with a brand to start a conversation",
                    theme: theme
                )
            } else {
                CLScrollView(theme: theme, topFade: 18) {
                    VStack(spacing: 10) {
                        ForEach(sampleDMs) { dm in
                            Button { state.push(.dm, id: dm.id) } label: {
                                HStack(spacing: 14) {
                                    ZStack(alignment: .topTrailing) {
                                        Text(dm.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                                            .font(.display(17)).foregroundColor(dm.accentText)
                                            .frame(width: 50, height: 50)
                                            .stickerCard(fill: dm.accent, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)
                                        if dm.unread > 0 {
                                            Text("\(dm.unread)")
                                                .font(.display(10, weight: .black))
                                                .foregroundColor(.white)
                                                .frame(width: 18, height: 18)
                                                .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: 1.5)
                                                .offset(x: 4, y: -4)
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(dm.brand).font(.display(16)).foregroundColor(theme.text)
                                            Spacer()
                                            Text(dm.when).font(.bodyFont(11, weight: .semibold)).foregroundColor(theme.textMuted)
                                        }
                                        Text(dm.last)
                                            .font(dm.unread > 0 ? .bodyFont(13, weight: .bold) : .bodyFont(13))
                                            .foregroundColor(dm.unread > 0 ? theme.text : theme.textMuted)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .stickerCard(fill: dm.unread > 0 ? theme.card : theme.surface, ink: theme.ink, cornerRadius: 18, shadow: dm.unread > 0 ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    Color.clear.frame(height: 40)
                }
            }
        }
    }
}

// MARK: - Profile Screen
struct ProfileScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var school: School { sampleSchools.first { $0.id == state.schoolId } ?? sampleSchools[0] }
    private var level: Int { state.xp / 500 + 1 }
    private var xpToNext: Int { 500 - (state.xp % 500) }
    private var levelPct: Double { Double(state.xp % 500) / 500.0 }

    private var badges: [(id: String, label: String, icon: String, earned: Bool)] {[
        ("first",  "First Event",       "star.fill",                    state.rsvps.count > 0),
        ("drop",   "Drop Hunter",       "shippingbox.fill",             state.xp >= 100),
        ("streak", "5-week Streak",     "flame.fill",                   state.streak >= 5),
        ("paid",   "Got Paid",          "dollarsign",                   state.applied.count > 0),
        ("social", "Social Butterfly",  "person.2.wave.2.fill",         false),
        ("org",    "Org Rep",           "building.2.fill",              state.appRole == .org),
    ]}

    var body: some View {
        CLScrollView(theme: theme, topFade: 30) {
            VStack(alignment: .leading, spacing: 0) {
                // Profile header
                HStack(alignment: .center, spacing: 14) {
                    Text(String(state.handle.prefix(1).uppercased()))
                        .font(.display(28)).foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 32, shadow: theme.shadowSm, borderWidth: theme.borderWidth)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(state.handle)").font(.display(22)).foregroundColor(theme.text).tracking(-0.6)
                        Text("\(school.name) · \(state.year)").font(.bodyFont(13, weight: .semibold)).foregroundColor(theme.textMuted)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 8)

                // Role switcher
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach([("student", "Student", "graduationcap.fill"), ("org", "Org admin", "building.2.fill")], id: \.0) { id, label, icon in
                            let active = (id == "student") == (state.appRole == .student)
                            Button {
                                state.setRole(id == "student" ? .student : .org)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: icon).font(.system(size: 12, weight: .bold))
                                    Text(label).font(.display(14))
                                }
                                .foregroundColor(active ? theme.bg : theme.text)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(RoundedRectangle(cornerRadius: 999).fill(active ? theme.text : .clear))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(4)
                    .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)

                    Text(state.appRole == .org ? "you're viewing as Tri Delt · pitch flows + sponsorship in nav" : "student feed · drops + earnings in nav")
                        .font(.bodyFont(11, weight: .semibold)).foregroundColor(theme.textMuted)
                        .padding(.leading, 4)
                }
                .padding(.horizontal, 20).padding(.top, 18)

                // Level + XP card
                ZStack {
                    CLCard(theme: theme, fill: Color(hex: "1a0e0e"), padding: 18) {
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(theme.yellow)
                                .frame(width: 160, height: 160)
                                .overlay(Circle().strokeBorder(Color(hex: "1a0e0e"), lineWidth: 2.5))
                                .offset(x: 50, y: -50)
                                .clipped()
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("level").font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.8).foregroundColor(theme.bg).opacity(0.6)
                                        Text("\(level)").font(.display(56)).foregroundColor(theme.bg).tracking(-2)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        HStack(spacing: 4) {
                                        Image(systemName: "star.fill").font(.system(size: 16, weight: .heavy))
                                        Text(state.xp.formatted())
                                    }
                                    .font(.display(24)).foregroundColor(theme.yellow).tracking(-0.5)
                                        Text("\(xpToNext) XP to lv\(level+1)").font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.bg).opacity(0.7)
                                    }
                                }
                                // XP bar
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(theme.bg, lineWidth: 2))
                                        .frame(height: 10)
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(theme.yellow)
                                            .frame(width: geo.size.width * levelPct)
                                    }
                                    .frame(height: 10)
                                    .padding(2)
                                }
                                .padding(.top, 14)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 20)

                // Stats row
                HStack(spacing: 10) {
                    StatBox(value: "\(state.rsvps.count)", label: "events", theme: theme)
                    StatBox(value: "\(state.streak)", label: "streak", color: theme.yellow, theme: theme)
                    StatBox(value: "\(state.applied.count)", label: "campaigns", theme: theme)
                }
                .padding(.horizontal, 20).padding(.top, 14)

                // Badges
                SectionHead(title: "badges", actionLabel: "\(badges.filter { $0.earned }.count)/\(badges.count)", theme: theme)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(badges, id: \.id) { badge in
                        VStack(spacing: 8) {
                            Image(systemName: badge.icon)
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(badge.earned ? .white : theme.textFaint)
                                .frame(width: 50, height: 50)
                                .stickerCard(fill: badge.earned ? theme.primary : theme.text, ink: theme.ink, cornerRadius: 999, shadow: badge.earned ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                            Text(badge.label)
                                .font(.display(11)).foregroundColor(theme.text).multilineTextAlignment(.center).lineLimit(2)
                        }
                        .padding(.vertical, 16).padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                        .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 18, shadow: badge.earned ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                        .opacity(badge.earned ? 1 : 0.45)
                    }
                }
                .padding(.horizontal, 20)

                // Messages shortcut
                Button { state.push(.inbox) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 10, shadow: 0, borderWidth: theme.borderThinWidth)
                        Text("messages").font(.display(14, weight: .bold)).foregroundColor(theme.text)
                        Spacer()
                        if sampleDMs.contains(where: { $0.unread > 0 }) {
                            Text("\(sampleDMs.filter { $0.unread > 0 }.count) new")
                                .font(.display(11))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                        }
                        Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(theme.textMuted)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 14, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20).padding(.top, 24)

                // Settings rows
                VStack(spacing: 8) {
                    settingsRow(icon: "bell.fill", label: "notifications", action: nil)
                    settingsRow(icon: "camera.fill", label: "edit profile", action: { state.push(.editProfile) })
                    settingsRow(icon: "lock.fill", label: "verification + .edu", action: nil)
                }
                .padding(.horizontal, 20).padding(.top, 10)

                Color.clear.frame(height: 110)
            }
        }
    }

    @ViewBuilder
    private func settingsRow(icon: String, label: String, action: (() -> Void)?) -> some View {
        let row = HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold)).foregroundColor(theme.textMuted)
            Text(label).font(.display(14, weight: .bold)).foregroundColor(theme.text)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(theme.textMuted)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)

        if let action {
            Button(action: action) { row }.buttonStyle(.plain)
        } else {
            row.opacity(0.55)
        }
    }
}

// MARK: - Edit Profile Screen
struct EditProfileScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    @State private var handle: String = ""
    @State private var year: String = ""
    @State private var searchText: String = ""
    @FocusState private var handleFocused: Bool

    private let years = ["Freshman", "Sophomore", "Junior", "Senior"]

    private var filteredSchools: [School] {
        searchText.isEmpty ? sampleSchools : sampleSchools.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.sub.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "edit profile", onBack: { state.pop() }, theme: theme)

            CLScrollView(theme: theme, topFade: 18, bottomFade: 0) {
                VStack(alignment: .leading, spacing: 0) {

                    // Avatar preview
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
                            Text(String((handle.isEmpty ? state.handle : handle).prefix(1).uppercased()))
                                .font(.display(36)).foregroundColor(.white)
                                .frame(width: 84, height: 84)
                                .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 42, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                                .offset(x: 4, y: 4)
                        }
                        Spacer()
                    }
                    .padding(.top, 12).padding(.bottom, 24)

                    // Handle
                    sectionLabel("username")
                    HStack(spacing: 0) {
                        Text("@").font(.display(16)).foregroundColor(theme.textMuted).padding(.leading, 14)
                        TextField("yourhandle", text: $handle)
                            .font(.display(16)).foregroundColor(theme.text)
                            .focused($handleFocused)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal, 8)
                    }
                    .frame(height: 48)
                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: handleFocused ? theme.borderWidth : theme.borderThinWidth)
                    .padding(.horizontal, 20).padding(.bottom, 18)

                    // Year
                    sectionLabel("year")
                    FlowLayout(spacing: 8) {
                        ForEach(years, id: \.self) { y in
                            CLChip(label: y, selected: (year.isEmpty ? state.year : year) == y, theme: theme) { year = y }
                        }
                    }
                    .padding(.horizontal, 20).padding(.bottom, 18)

                    // School
                    sectionLabel("school")
                    CLSearchBar(text: $searchText, placeholder: "search schools…", theme: theme)
                        .padding(.horizontal, 20).padding(.bottom, 10)

                    VStack(spacing: 6) {
                        ForEach(filteredSchools.prefix(8)) { school in
                            Button { state.schoolId = school.id; haptic(.light) } label: {
                                HStack(spacing: 12) {
                                    SchoolLogo(school: school)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(school.name).font(.display(15)).foregroundColor(theme.text)
                                        Text(school.sub).font(.bodyFont(11, weight: .semibold)).foregroundColor(theme.textMuted).lineLimit(1)
                                    }
                                    Spacer()
                                    if state.schoolId == school.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(theme.primary)
                                    }
                                }
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .stickerCard(fill: state.schoolId == school.id ? theme.card : theme.surface, ink: theme.ink, cornerRadius: 14, shadow: state.schoolId == school.id ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20).padding(.bottom, 18)

                    Color.clear.frame(height: 24)
                }
            }

            // Save CTA
            CLButton(label: "save changes", kind: .primary, size: .lg, full: true, theme: theme) {
                haptic(.heavy)
                if !handle.isEmpty { state.handle = handle }
                if !year.isEmpty { state.year = year }
                state.showToast("profile updated!", icon: "person.fill.checkmark")
                state.pop()
            }
            .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 20)
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
        .onAppear {
            handle = state.handle
            year = state.year
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.6)
            .foregroundColor(theme.text).opacity(0.7)
            .padding(.horizontal, 20).padding(.bottom, 8)
    }
}
