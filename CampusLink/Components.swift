import SwiftUI

// MARK: - CampusLink Logo (SVG chain-link "CL")
struct CLLogo: View {
    var size: CGFloat = 28
    var color: Color = .white
    var bg: Color? = nil
    var radius: CGFloat = 12

    var body: some View {
        let logo = Canvas { ctx, _ in
            let s = size
            func path(_ d: Path, _ c: Color) {
                ctx.fill(d, with: .color(c))
            }
            let scale = s / 100
            var p1 = Path(); p1.addPath(makeLeft(scale: scale))
            var p2 = Path(); p2.addPath(makeRight(scale: scale))
            var p3 = Path(); p3.addPath(makeCenter1(scale: scale))
            var p4 = Path(); p4.addPath(makeCenter2(scale: scale))
            path(p1, color); path(p2, color); path(p3, color); path(p4, color)
        }
        .frame(width: size, height: size)

        if let bg {
            logo
                .padding(6)
                .background(RoundedRectangle(cornerRadius: radius).fill(bg))
        } else {
            logo
        }
    }

    private func makeLeft(scale: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 40*scale, y: 17*scale))
            p.addCurve(to: CGPoint(x: 31.9*scale, y: 20.3*scale), control1: CGPoint(x: 37*scale, y: 17*scale), control2: CGPoint(x: 34.9*scale, y: 18.2*scale))
            p.addLine(to: CGPoint(x: 20.4*scale, y: 31.7*scale))
            p.addCurve(to: CGPoint(x: 20.4*scale, y: 47.9*scale), control1: CGPoint(x: 15.9*scale, y: 36.2*scale), control2: CGPoint(x: 15.9*scale, y: 43.4*scale))
            p.addLine(to: CGPoint(x: 24.4*scale, y: 51.9*scale))
            p.addLine(to: CGPoint(x: 31.4*scale, y: 44.9*scale))
            p.addLine(to: CGPoint(x: 27.4*scale, y: 40.9*scale))
            p.addCurve(to: CGPoint(x: 27.4*scale, y: 38.7*scale), control1: CGPoint(x: 26.8*scale, y: 40.3*scale), control2: CGPoint(x: 26.8*scale, y: 39.3*scale))
            p.addLine(to: CGPoint(x: 39.0*scale, y: 27.1*scale))
            p.addCurve(to: CGPoint(x: 41.3*scale, y: 26.7*scale), control1: CGPoint(x: 39.6*scale, y: 26.8*scale), control2: CGPoint(x: 40.7*scale, y: 26.7*scale))
            p.addCurve(to: CGPoint(x: 43.6*scale, y: 27.1*scale), control1: CGPoint(x: 41.9*scale, y: 26.7*scale), control2: CGPoint(x: 43.0*scale, y: 26.8*scale))
            p.addLine(to: CGPoint(x: 47.6*scale, y: 31.1*scale))
            p.addLine(to: CGPoint(x: 54.6*scale, y: 24.1*scale))
            p.addLine(to: CGPoint(x: 50.6*scale, y: 20.1*scale))
            p.addCurve(to: CGPoint(x: 40*scale, y: 17*scale), control1: CGPoint(x: 48*scale, y: 17.8*scale), control2: CGPoint(x: 43*scale, y: 17*scale))
            p.closeSubpath()
        }
    }
    private func makeRight(scale: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 75.6*scale, y: 51.7*scale))
            p.addLine(to: CGPoint(x: 71.6*scale, y: 47.7*scale))
            p.addLine(to: CGPoint(x: 64.6*scale, y: 54.7*scale))
            p.addLine(to: CGPoint(x: 68.6*scale, y: 58.7*scale))
            p.addCurve(to: CGPoint(x: 68.6*scale, y: 60.9*scale), control1: CGPoint(x: 69.2*scale, y: 59.3*scale), control2: CGPoint(x: 69.2*scale, y: 60.3*scale))
            p.addLine(to: CGPoint(x: 57*scale, y: 72.6*scale))
            p.addCurve(to: CGPoint(x: 54.8*scale, y: 72.6*scale), control1: CGPoint(x: 56.4*scale, y: 73.2*scale), control2: CGPoint(x: 55.4*scale, y: 73.2*scale))
            p.addLine(to: CGPoint(x: 50.8*scale, y: 68.6*scale))
            p.addLine(to: CGPoint(x: 43.8*scale, y: 75.6*scale))
            p.addLine(to: CGPoint(x: 47.8*scale, y: 79.6*scale))
            p.addCurve(to: CGPoint(x: 64.0*scale, y: 79.6*scale), control1: CGPoint(x: 52.3*scale, y: 84.1*scale), control2: CGPoint(x: 59.5*scale, y: 84.1*scale))
            p.addLine(to: CGPoint(x: 75.6*scale, y: 67.9*scale))
            p.addCurve(to: CGPoint(x: 75.6*scale, y: 51.7*scale), control1: CGPoint(x: 80.1*scale, y: 63.4*scale), control2: CGPoint(x: 80.1*scale, y: 56.2*scale))
            p.closeSubpath()
        }
    }
    private func makeCenter1(scale: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 58*scale, y: 35.7*scale))
            p.addLine(to: CGPoint(x: 51*scale, y: 42.7*scale))
            p.addLine(to: CGPoint(x: 57.3*scale, y: 49*scale))
            p.addLine(to: CGPoint(x: 64.3*scale, y: 42*scale))
            p.closeSubpath()
        }
    }
    private func makeCenter2(scale: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 42*scale, y: 51.3*scale))
            p.addLine(to: CGPoint(x: 35*scale, y: 58.3*scale))
            p.addLine(to: CGPoint(x: 41.3*scale, y: 64.6*scale))
            p.addLine(to: CGPoint(x: 48.3*scale, y: 57.6*scale))
            p.closeSubpath()
        }
    }
}

// MARK: - Mystery Box Icon
struct MysteryBoxIcon: View {
    var size: CGFloat = 32
    var color: Color = .white

    var body: some View {
        Canvas { ctx, sz in
            let s = size / 32
            let p = StrokeStyle(lineWidth: 2.4 * s, lineCap: .round, lineJoin: .round)

            func stroke(_ path: Path) { ctx.stroke(path, with: .color(color), style: p) }

            // Top box
            var top = Path(); top.move(to: pt(16,4,s)); top.addLine(to: pt(26,8,s)); top.addLine(to: pt(26,12,s)); top.addLine(to: pt(16,16,s)); top.addLine(to: pt(6,12,s)); top.addLine(to: pt(6,8,s)); top.closeSubpath()
            stroke(top)

            // Bottom box
            var bot = Path(); bot.move(to: pt(6,12,s)); bot.addLine(to: pt(6,24,s)); bot.addLine(to: pt(16,28,s)); bot.addLine(to: pt(26,24,s)); bot.addLine(to: pt(26,12,s))
            stroke(bot)

            // Center line
            var mid = Path(); mid.move(to: pt(16,16,s)); mid.addLine(to: pt(16,32,s))
            stroke(mid)

            // Side struts
            var sl = Path(); sl.move(to: pt(11,18,s)); sl.addLine(to: pt(6,16,s))
            var sr = Path(); sr.move(to: pt(21,18,s)); sr.addLine(to: pt(26,16,s))
            stroke(sl); stroke(sr)
        }
        .frame(width: size, height: size)
        .overlay(
            Text("?")
                .font(.display(size * 0.35, weight: .black))
                .foregroundColor(color)
                .offset(y: size * 0.25)
        )
    }

    private func pt(_ x: CGFloat, _ y: CGFloat, _ s: CGFloat) -> CGPoint {
        CGPoint(x: x * s, y: y * s)
    }
}

// MARK: - Sticker Button
struct CLButton: View {
    enum Kind { case primary, ink, yellow, pink, surface, ghost }
    enum ButtonSize { case sm, md, lg }

    let label: String
    var kind: Kind = .primary
    var size: ButtonSize = .md
    var icon: String? = nil
    var full: Bool = false
    let theme: CLTheme
    let action: () -> Void

    private var height: CGFloat { size == .sm ? 38 : size == .md ? 48 : 56 }
    private var hPad: CGFloat   { size == .sm ? 16 : size == .md ? 22 : 28 }
    private var fontSize: CGFloat { size == .sm ? 14 : size == .md ? 16 : 17 }
    private var shadowOffset: CGFloat { size == .lg ? theme.shadowMd : theme.shadowSm }

    private var fill: Color {
        switch kind {
        case .primary: theme.primary
        case .ink:     theme.text
        case .yellow:  theme.yellow
        case .pink:    theme.pink
        case .ghost:   .clear
        case .surface: theme.surface
        }
    }
    private var fgColor: Color {
        switch kind {
        case .primary, .ink: .white
        case .yellow, .pink: theme.text
        case .ghost, .surface: theme.text
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: fontSize - 2, weight: .heavy))
                }
                Text(label)
                    .font(.display(fontSize))
                    .lineLimit(1)
            }
            .foregroundColor(fgColor)
            .frame(height: height)
            .padding(.horizontal, hPad)
            .frame(maxWidth: full ? .infinity : nil)
            .stickerCard(fill: fill, ink: theme.ink, cornerRadius: 999, shadow: kind == .ghost ? 0 : shadowOffset, borderWidth: theme.borderWidth)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chip
struct CLChip: View {
    let label: String
    var selected: Bool = false
    var icon: String? = nil
    var color: Color? = nil
    var rotate: Double = 0
    let theme: CLTheme
    let action: (() -> Void)?

    var body: some View {
        let bg = selected ? (color ?? theme.primary) : theme.surface
        let fg: Color = selected ? (color == theme.yellow ? theme.text : .white) : theme.text

        let chipView = HStack(spacing: 6) {
            if let icon { Image(systemName: icon).font(.system(size: 13, weight: .bold)) }
            Text(label).font(.display(14)).lineLimit(1)
        }
        .foregroundColor(fg)
        .frame(height: 36)
        .padding(.horizontal, 14)
        .stickerCard(
            fill: bg, ink: theme.ink, cornerRadius: 999,
            shadow: selected ? theme.shadowSm : 0,
            borderWidth: theme.borderThinWidth
        )
        .rotationEffect(.degrees(rotate))

        if let action {
            Button(action: action) { chipView }.buttonStyle(.plain)
        } else {
            chipView
        }
    }
}

// MARK: - Card container
struct CLCard<Content: View>: View {
    let theme: CLTheme
    var fill: Color? = nil
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 22
    var shadow: CGFloat = 4
    var borderWidth: CGFloat = 2.5
    let content: Content

    init(theme: CLTheme, fill: Color? = nil, padding: CGFloat = 16, cornerRadius: CGFloat = 22, shadow: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.theme = theme; self.fill = fill; self.padding = padding
        self.cornerRadius = cornerRadius; self.shadow = shadow
        self.borderWidth = theme.borderWidth
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .stickerCard(fill: fill ?? theme.card, ink: theme.ink, cornerRadius: cornerRadius, shadow: shadow, borderWidth: theme.borderWidth)
    }
}

// MARK: - Sticker Tag (rotated label)
struct StickerTag: View {
    let label: String
    var color: Color? = nil
    var rotate: Double = -4
    let theme: CLTheme

    var body: some View {
        Text(label)
            .font(.display(11, weight: .black))
            .tracking(0.4)
            .textCase(.uppercase)
            .foregroundColor(theme.text)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .stickerCard(fill: color ?? theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
            .rotationEffect(.degrees(rotate))
    }
}

// MARK: - Section Header
struct SectionHead: View {
    let title: String
    var actionLabel: String? = nil
    var arrow: Bool = false
    let theme: CLTheme
    let onAction: (() -> Void)?

    init(title: String, actionLabel: String? = nil, arrow: Bool = false, theme: CLTheme, onAction: (() -> Void)? = nil) {
        self.title = title; self.actionLabel = actionLabel; self.arrow = arrow
        self.theme = theme; self.onAction = onAction
    }

    var body: some View {
        HStack(alignment: .bottom) {
            Text(title + (arrow ? " →" : ""))
                .font(.display(22))
                .foregroundColor(theme.text)
            Spacer()
            if let label = actionLabel, let action = onAction {
                Button(action: action) {
                    Text(label)
                        .font(.display(13))
                        .foregroundColor(theme.text)
                        .underline()
                }
                .buttonStyle(.plain)
            } else if let label = actionLabel {
                Text(label).font(.display(13)).foregroundColor(theme.text)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
}

// MARK: - Avatar
struct CLAvatar: View {
    let name: String
    var size: CGFloat = 36
    var bg: Color? = nil
    var fg: Color? = nil
    let theme: CLTheme

    var body: some View {
        Text(String((name.first ?? "?").uppercased()))
            .font(.display(size * 0.42, weight: .black))
            .foregroundColor(fg ?? .white)
            .frame(width: size, height: size)
            .stickerCard(fill: bg ?? Color(hex: "FF1F1F"), ink: theme.ink, cornerRadius: size / 2, shadow: 0, borderWidth: theme.borderThinWidth)
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String
    var color: Color? = nil
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.display(22)).foregroundColor(theme.text)
            Text(label).font(.bodyFont(10, weight: .bold)).textCase(.uppercase).tracking(0.5).foregroundColor(theme.text).opacity(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .stickerCard(fill: color ?? theme.surface, ink: theme.ink, cornerRadius: 16, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
    }
}

// MARK: - Top Bar (detail screens)
struct CLTopBar: View {
    var title: String = ""
    var onBack: (() -> Void)? = nil
    var trailing: AnyView? = nil
    let theme: CLTheme

    var body: some View {
        HStack {
            if let back = onBack {
                Button(action: back) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.text)
                        .frame(width: 40, height: 40)
                        .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 20, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
            Spacer()
            if !title.isEmpty {
                Text(title)
                    .font(.display(16))
                    .foregroundColor(theme.text)
            }
            Spacer()
            if let t = trailing {
                t.frame(width: 40, height: 40)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

// MARK: - Floating Tab Bar
struct CLTabBar: View {
    @Binding var tab: AppTab
    let role: AppRole
    var dropPulse: Bool = false
    let theme: CLTheme
    let onTab: (AppTab) -> Void

    private var studentTabs: [(id: AppTab, icon: String, center: Bool)] {[
        (id: .home,   icon: "house.fill",        center: false),
        (id: .brands, icon: "tag.fill",           center: false),
        (id: .drops,  icon: "shippingbox.fill",   center: true),
        (id: .opps,   icon: "bolt.fill",          center: false),
        (id: .me,     icon: "person.fill",        center: false),
    ]}
    private var orgTabs: [(id: AppTab, icon: String, center: Bool)] {[
        (id: .home,   icon: "house.fill",         center: false),
        (id: .events, icon: "calendar",           center: false),
        (id: .pitch,  icon: "sparkles",           center: true),
        (id: .opps,   icon: "bolt.fill",          center: false),
        (id: .me,     icon: "person.fill",        center: false),
    ]}

    var tabs: [(id: AppTab, icon: String, center: Bool)] {
        role == .org ? orgTabs : studentTabs
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.id) { t in
                if t.center {
                    Button {
                        onTab(t.id)
                    } label: {
                        ZStack {
                            // Three-layer tab center button
                            Circle().fill(theme.ink).frame(width: 60, height: 60).offset(x: theme.shadowSm, y: theme.shadowSm)
                            Circle().fill(theme.ink).frame(width: 60, height: 60)
                            Circle().fill(theme.pink).frame(width: 60 - theme.borderWidth * 2, height: 60 - theme.borderWidth * 2)
                            MysteryBoxIcon(size: 28, color: .white)
                        }
                        .offset(y: -22)
                    }
                    .buttonStyle(.plain)
                    .overlay(alignment: .topTrailing) {
                        if dropPulse {
                            ZStack {
                                Circle().fill(theme.ink).frame(width: 18, height: 18)
                                Circle().fill(theme.yellow).frame(width: 18 - theme.borderThinWidth * 2, height: 18 - theme.borderThinWidth * 2)
                            }
                            .offset(x: -4, y: -18)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    Button {
                        onTab(t.id)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: t.icon)
                                .font(.system(size: 22, weight: tab == t.id ? .heavy : .regular))
                                .foregroundColor(tab == t.id ? theme.yellow : theme.tabFg.opacity(0.7))
                            if tab == t.id {
                                Circle()
                                    .fill(theme.yellow)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(height: 64)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .stickerCard(fill: theme.tabBg, ink: theme.ink, cornerRadius: 32, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
        .padding(.horizontal, 16)
    }
}

// MARK: - Brand Logo Tile
struct BrandLogoTile: View {
    let brand: Brand
    let size: CGFloat
    let fill: Color
    let ink: Color
    let textColor: Color
    var cornerRadius: CGFloat = 14
    var shadow: CGFloat = 0
    var borderWidth: CGFloat = 2
    var padding: CGFloat = 7

    var body: some View {
        ZStack {
            if let logoUrl = brand.logoUrl, let url = URL(string: logoUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(padding)
                    case .failure:
                        initials
                    default:
                        initials.opacity(0.35)
                    }
                }
            } else {
                initials
            }
        }
        .frame(width: size, height: size)
        .stickerCard(fill: fill, ink: ink, cornerRadius: cornerRadius, shadow: shadow, borderWidth: borderWidth)
    }

    private var initials: some View {
        Text(brand.initials)
            .font(.display(size * 0.40))
            .foregroundColor(textColor)
    }
}

// MARK: - Opp Row (shared)
struct OppRow: View {
    let opp: Opportunity
    let theme: CLTheme
    let action: () -> Void
    private var brand: Brand? { sampleBrands.first { $0.name == opp.brand } }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    if let brand {
                        BrandLogoTile(
                            brand: brand,
                            size: 46,
                            fill: opp.accentText,
                            ink: theme.ink,
                            textColor: opp.accent,
                            cornerRadius: 14,
                            shadow: 0,
                            borderWidth: 0,
                            padding: 7
                        )
                    } else {
                        Text(opp.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                            .font(.display(18))
                            .foregroundColor(opp.accentText)
                            .frame(width: 46, height: 46)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(opp.accent))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(opp.brand)
                            .font(.bodyFont(12, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(0.4)
                            .foregroundColor(theme.textMuted)
                        Text(opp.title)
                            .font(.display(16))
                            .foregroundColor(theme.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                HStack(spacing: 8) {
                    Text(opp.payout)
                        .font(.display(13))
                        .foregroundColor(theme.text)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                        .lineLimit(1)
                    Text("· \(opp.seats)")
                        .font(.bodyFont(12, weight: .semibold))
                        .foregroundColor(theme.textMuted)
                        .lineLimit(1)
                    Spacer()
                    Text(opp.deadline)
                        .font(.display(12))
                        .foregroundColor(theme.primary)
                        .lineLimit(1)
                }
            }
            .padding(16)
            .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Meta Row (icon + label + value)
struct MetaRow: View {
    let icon: String
    let label: String
    let value: String
    let theme: CLTheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 10, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.bodyFont(11, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .foregroundColor(theme.textMuted)
                Text(value)
                    .font(.display(15, weight: .bold))
                    .foregroundColor(theme.text)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
    }
}

// MARK: - Toast Notification
struct CLToast: View {
    let message: String
    var icon: String = "checkmark"
    let theme: CLTheme

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(theme.text)
                .frame(width: 30, height: 30)
                .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
            Text(message)
                .font(.display(14))
                .foregroundColor(.white)
                .lineLimit(2)
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 20, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
    }
}

// MARK: - Empty State
struct CLEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionLabel: String? = nil
    var action: (() -> Void)? = nil
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(theme.textMuted)
                .frame(width: 72, height: 72)
                .stickerOutline(fill: theme.surfaceAlt, ink: theme.ink, cornerRadius: 22, borderWidth: theme.borderThinWidth)
            VStack(spacing: 6) {
                Text(title)
                    .font(.display(18))
                    .foregroundColor(theme.text)
                Text(subtitle)
                    .font(.bodyFont(13, weight: .semibold))
                    .foregroundColor(theme.textMuted)
                    .multilineTextAlignment(.center)
            }
            if let label = actionLabel, let act = action {
                CLButton(label: label, kind: .ink, size: .sm, theme: theme, action: act)
                    .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Search Bar
struct CLSearchBar: View {
    @Binding var text: String
    var placeholder: String = "search…"
    let theme: CLTheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(theme.textMuted)
            TextField(placeholder, text: $text)
                .font(.bodyFont(15))
                .foregroundColor(theme.text)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 14)
        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
    }
}
