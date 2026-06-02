import SwiftUI

// MARK: - Home Screen (student)
struct HomeScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    var body: some View {
        CLScrollView(theme: theme) {
            VStack(alignment: .leading, spacing: 0) {
                // Greeting row
                HStack {
                    Button { state.setTab(.me) } label: {
                        Text("hey, \(state.handle)")
                            .font(.display(14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button { state.setTab(.me) } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11, weight: .heavy))
                            Text(state.xp.formatted())
                                .font(.display(14))
                        }
                        .foregroundColor(theme.text)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // Mystery drop hero
                Button { state.setTab(.drops) } label: {
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 0) {
                            MysteryBoxIcon(size: 42, color: theme.primary)
                                .padding(14)
                                .stickerOutline(fill: .white, ink: theme.ink, cornerRadius: 18, borderWidth: theme.borderWidth)
                            Text("mystery\ndrop is loaded")
                                .font(.display(28))
                                .foregroundColor(.white)
                                .tracking(-0.8)
                                .padding(.top, 14)
                            HStack(spacing: 4) {
                                Text("unlocks in")
                                    .font(.bodyFont(14))
                                    .foregroundColor(.white.opacity(0.9))
                                Text(state.dropTimer)
                                    .font(.display(14))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 2)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(theme.text))
                            }
                            .padding(.top, 8)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 28, shadow: theme.shadowLg, borderWidth: theme.borderWidth)

                        StickerTag(label: "this week!", rotate: 8, theme: theme)
                            .offset(x: -14, y: -14)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // Brands on campus
                SectionHead(title: "brands on campus", actionLabel: "see all", arrow: true, theme: theme) { state.setTab(.brands) }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sampleBrands) { brand in
                            BrandCard(brand: brand, theme: theme) {
                                state.push(.brand, id: brand.id)
                            }
                            .frame(width: 180)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }

                // Paid this week
                SectionHead(title: "paid this week", actionLabel: "browse", arrow: true, theme: theme) { state.setTab(.opps) }
                VStack(spacing: 12) {
                    ForEach(sampleOpportunities.prefix(2)) { opp in
                        OppRow(opp: opp, theme: theme) { state.push(.opp, id: opp.id) }
                    }
                }
                .padding(.horizontal, 20)

                // Drops at events
                SectionHead(title: "drops at events", actionLabel: "all events", arrow: true, theme: theme, onAction: nil)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(sampleEvents.filter { $0.drop != nil }) { evt in
                            Button { state.push(.event, id: evt.id) } label: {
                                VStack(alignment: .leading, spacing: 0) {
                                    // Cover gradient — sticker tag lives inside, away from the border
                                    ZStack(alignment: .bottomLeading) {
                                        LinearGradient(colors: evt.coverGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                            .frame(height: 110)
                                        if let drop = evt.drop {
                                            StickerTag(label: "+ \(drop.brand)", rotate: -4, theme: theme)
                                                .padding(12)
                                        }
                                    }
                                    .overlay(alignment: .bottom) {
                                        theme.ink.frame(height: theme.borderWidth)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(evt.org)
                                            .font(.bodyFont(11, weight: .bold))
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                            .foregroundColor(theme.textMuted)
                                        Text(evt.title)
                                            .font(.display(18))
                                            .foregroundColor(theme.text)
                                            .lineLimit(1)
                                        Text(evt.when.split(separator: "·").prefix(2).joined(separator: "·"))
                                            .font(.bodyFont(12, weight: .semibold))
                                            .foregroundColor(theme.textMuted)
                                            .padding(.top, 2)
                                    }
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(width: 230)
                                // clipShape content BEFORE stickerCard so shadow isn't clipped
                                .clipShape(RoundedRectangle(cornerRadius: max(0, 22 - theme.borderWidth), style: .continuous))
                                .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)
                }

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Brand Card (horizontal scroll)
struct BrandCard: View {
    let brand: Brand
    let theme: CLTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading, spacing: 12) {
                        BrandLogoTile(
                            brand: brand,
                            size: 48,
                            fill: brand.accent,
                            ink: theme.ink,
                            textColor: brand.color,
                            cornerRadius: 14,
                            shadow: 0,
                            borderWidth: 0,
                            padding: 7
                        )
                        Text(brand.name).font(.display(18)).foregroundColor(brand.accent).tracking(-0.4).lineLimit(2)
                        Text("\(brand.cat) · \(brand.vibe)").font(.bodyFont(11, weight: .semibold)).foregroundColor(brand.accent.opacity(0.75)).textCase(.uppercase).tracking(0.5)
                    }
                    .padding(.horizontal, 16).padding(.top, 18).padding(.bottom, 14)

                    if brand.activeDrops > 0 {
                        StickerTag(label: "+drop", color: theme.yellow, rotate: 6, theme: theme)
                            .padding(.top, 12).padding(.trailing, 12)
                    }
                }

                theme.ink.opacity(0.15).frame(height: 1)
                HStack {
                    Text("\(brand.openOpps) opps").font(.display(12)).foregroundColor(brand.accent)
                    Spacer()
                    Text("connect →").font(.display(12)).foregroundColor(brand.accent)
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Color.black.opacity(0.18))
            }
            .clipShape(RoundedRectangle(cornerRadius: max(0, 22 - theme.borderWidth), style: .continuous))
            .stickerCard(fill: brand.color, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Brands Browser
struct BrandsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    @State private var filter = "all"
    @State private var searchText = ""
    private let cats = ["all", "Beverage", "Food", "App", "Finance"]

    private var list: [Brand] {
        var result = filter == "all" ? sampleBrands : sampleBrands.filter { $0.cat == filter }
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.cat.localizedCaseInsensitiveContains(searchText) ||
                $0.vibe.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Pinned header — never scrolls
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("brands")
                            .font(.display(36))
                            .foregroundColor(theme.text)
                            .tracking(-1.2)
                        Text("\(sampleBrands.count) live on CampusLink right now")
                            .font(.bodyFont(14))
                            .foregroundColor(theme.textMuted)
                    }
                    Spacer()
                }
                CLSearchBar(text: $searchText, placeholder: "search brands…", theme: theme)
            }
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            CLScrollView(theme: theme, topFade: 30) {
                VStack(alignment: .leading, spacing: 0) {
                    // Filter chips — hidden while searching
                    if searchText.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(cats, id: \.self) { c in
                                    CLChip(label: c, selected: filter == c, theme: theme) { filter = c }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 14)
                    }

                    if list.isEmpty {
                        CLEmptyState(
                            icon: "tag.fill",
                            title: "no brands found",
                            subtitle: searchText.isEmpty
                                ? "no brands in this category yet"
                                : "try a different search term",
                            actionLabel: "clear",
                            action: { searchText = ""; filter = "all" },
                            theme: theme
                        )
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(list) { brand in
                                Button { state.push(.brand, id: brand.id) } label: {
                                    BrandGridCard(brand: brand, theme: theme)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Color.clear.frame(height: 110)
                }
            }
        }
    }
}

/// Grid card used on the Brands tab — separate from BrandCard (home horizontal scroll)
/// so each can tune sizing independently while sharing the same sticker chrome.
private struct BrandGridCard: View {
    let brand: Brand
    let theme: CLTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 10) {
                    BrandLogoTile(
                        brand: brand,
                        size: 44,
                        fill: brand.accent,
                        ink: theme.ink,
                        textColor: brand.color,
                        cornerRadius: 12,
                        shadow: 0,
                        borderWidth: 0,
                        padding: 7
                    )
                    Text(brand.name)
                        .font(.display(18))
                        .foregroundColor(brand.accent)
                        .tracking(-0.4)
                        .lineLimit(2)
                    Text(brand.cat)
                        .font(.bodyFont(11, weight: .semibold))
                        .foregroundColor(brand.accent.opacity(0.75))
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                .padding(16)

                if brand.activeDrops > 0 {
                    MysteryBoxIcon(size: 14, color: theme.text)
                        .padding(6)
                        .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                        .padding(.top, 10).padding(.trailing, 10)
                }
            }

            // Footer bar — must be inside clipShape, so we handle it here
            // then clip the whole VStack to the inner radius before applying stickerCard
            theme.ink.opacity(0.15).frame(height: 1)
            HStack {
                Text("\(brand.openOpps) opps").font(.display(12)).foregroundColor(brand.accent)
                Spacer()
                Text("connect →").font(.display(12)).foregroundColor(brand.accent)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.black.opacity(0.18))
        }
        // Clip content to inner rounded rect BEFORE stickerCard so the shadow isn't clipped
        .clipShape(RoundedRectangle(cornerRadius: max(0, 22 - theme.borderWidth), style: .continuous))
        .stickerCard(fill: brand.color, ink: theme.ink, cornerRadius: 22, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
    }
}

// MARK: - Brand Detail Screen
struct BrandDetailScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    // Hot pink used for "active drops" stat and primary CTA — distinct from theme.pink (red)
    private let dropPink = Color(hex: "FB2C82")

    private var brand: Brand { state.detailBrand ?? sampleBrands[0] }
    private var brandOpps: [Opportunity] { sampleOpportunities.filter { $0.brand.lowercased() == brand.name.lowercased() } }
    private var brandEvents: [CLEvent] { sampleEvents.filter { $0.drop?.brand == brand.name } }
    private var heroText: Color { .white }
    private var heroTextMuted: Color { .white.opacity(0.72) }
    private var heroLogoFill: Color { .white }
    private var heroLogoText: Color { brand.color }

    var body: some View {
        ZStack(alignment: .bottom) {
            CLScrollView(theme: theme, bottomFade: 0) {
                VStack(spacing: 0) {
                    // Hero
                    ZStack(alignment: .topLeading) {
                        brand.color
                            .frame(height: 300)
                            .ignoresSafeArea(edges: .top)
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
                                let isFollowing = state.following.contains(brand.id)
                                Button {
                                    haptic(.medium)
                                    if isFollowing {
                                        state.following.removeAll { $0 == brand.id }
                                    } else {
                                        state.following.append(brand.id)
                                        state.showToast("following \(brand.name)!", icon: "star.fill")
                                    }
                                } label: {
                                    Text(isFollowing ? "✓ following" : "+ follow")
                                        .font(.display(13))
                                        .foregroundColor(isFollowing ? .white : theme.text)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .stickerCard(fill: isFollowing ? theme.text : theme.surface, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20).padding(.top, 88)

                            HStack(alignment: .top, spacing: 14) {
                                BrandLogoTile(
                                    brand: brand,
                                    size: 72,
                                    fill: heroLogoFill,
                                    ink: theme.ink,
                                    textColor: heroLogoText,
                                    cornerRadius: 18,
                                    shadow: theme.shadowSm,
                                    borderWidth: theme.borderThinWidth,
                                    padding: 11
                                )
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(brand.name).font(.display(26)).foregroundColor(heroText).tracking(-0.8)
                                    Text("\(brand.cat) · \(brand.vibe) · verified")
                                        .font(.bodyFont(12, weight: .semibold))
                                        .foregroundColor(heroTextMuted)
                                        .textCase(.uppercase).tracking(0.6)
                                    Text(brand.blurb)
                                        .font(.bodyFont(14))
                                        .foregroundColor(heroText.opacity(0.86))
                                        .lineSpacing(2)
                                }
                            }
                            .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 24)
                        }
                    }
                    .frame(height: 300)
                    .overlay(alignment: .bottom) {
                        theme.ink.frame(height: theme.borderWidth)
                    }

                    // Stats
                    HStack(spacing: 10) {
                        StatBox(value: "\(brand.openOpps)", label: "open opps", color: theme.yellow, theme: theme)
                        StatBox(value: "\(brand.activeDrops)", label: "active drops", color: dropPink, theme: theme)
                        StatBox(value: "A+", label: "rep score", color: theme.lime, theme: theme)
                    }
                    .padding(.horizontal, 20).padding(.top, 18)

                    if !brandOpps.isEmpty {
                        SectionHead(title: "paid opps", theme: theme)
                        VStack(spacing: 12) {
                            ForEach(brandOpps) { opp in
                                OppRow(opp: opp, theme: theme) { state.push(.opp, id: opp.id) }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    if !brandEvents.isEmpty {
                        SectionHead(title: "drops at events", theme: theme)
                        VStack(spacing: 12) {
                            ForEach(brandEvents) { evt in
                                Button { state.push(.event, id: evt.id) } label: {
                                    HStack(spacing: 12) {
                                        LinearGradient(colors: evt.coverGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                            .frame(width: 44, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(evt.title).font(.display(15)).foregroundColor(theme.text)
                                            Text("\(evt.org) · \(evt.when)").font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.textMuted)
                                        }
                                        Spacer()
                                        StickerTag(label: "+drop", theme: theme)
                                    }
                                    .padding(14)
                                    .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 18, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    SectionHead(title: "worked with", actionLabel: "24 orgs", theme: theme)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["Sig Ep", "Tri Delt", "KKG", "AΦ", "ZBT", "Startup Society"], id: \.self) { org in
                                Text(org)
                                    .font(.display(13, weight: .bold))
                                    .foregroundColor(theme.text)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 999, borderWidth: theme.borderThinWidth)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Color.clear.frame(height: 120)
                }
            }

            // CTA bar
            HStack(spacing: 10) {
                CLButton(label: "message", kind: .surface, size: .lg, icon: "message.fill", theme: theme) {
                    state.push(.dm, id: brand.id)
                }
                // Hot pink "see X opps" button — matches the drops pink, not primary red
                Button {
                    if let opp = brandOpps.first { state.push(.opp, id: opp.id) }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "briefcase.fill")
                            .font(.system(size: 15, weight: .heavy))
                        Text("see \(brand.openOpps) opps")
                            .font(.display(17))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .frame(height: 56)
                    .padding(.horizontal, 28)
                    .frame(maxWidth: .infinity)
                    .stickerCard(fill: dropPink, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowMd, borderWidth: theme.borderWidth)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .padding(.bottom, 20)
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Event Detail
struct EventDetailScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var event: CLEvent { state.detailEvent ?? sampleEvents[0] }
    private var isGoing: Bool { state.rsvps.contains(event.id) }

    var body: some View {
        ZStack(alignment: .bottom) {
            CLScrollView(theme: theme, bottomFade: 0) {
                VStack(spacing: 0) {
                    // Hero cover — gradient fills behind status bar / Dynamic Island
                    ZStack(alignment: .topLeading) {
                        LinearGradient(colors: event.coverGradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .frame(height: 280)
                            .ignoresSafeArea(edges: .top)
                        VStack(alignment: .leading) {
                            Button { state.pop() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(theme.text)
                                    .frame(width: 40, height: 40)
                                    .stickerCard(fill: theme.bg, ink: theme.ink, cornerRadius: 20, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20).padding(.top, 62)
                            Spacer()
                            VStack(alignment: .leading, spacing: 14) {
                                StickerTag(label: "\(event.orgKind) · \(event.org)", color: theme.bg, rotate: -3, theme: theme)
                                Text(event.title)
                                    .font(.display(38))
                                    .foregroundColor(.white)
                                    .tracking(-1.2)
                                    .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
                            }
                            .padding(.horizontal, 20).padding(.bottom, 24)
                        }
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .overlay(alignment: .bottom) { theme.ink.frame(height: theme.borderWidth) }
                    }
                    .frame(height: 280)

                    VStack(alignment: .leading, spacing: 10) {
                        MetaRow(icon: "calendar", label: "when",  value: event.when,    theme: theme)
                        MetaRow(icon: "mappin",   label: "where", value: event.where_,  theme: theme)
                        MetaRow(icon: "person.2", label: "going", value: "\(event.going + (isGoing ? 1 : 0)) students", theme: theme)
                    }
                    .padding(.horizontal, 20).padding(.top, 18)

                    if let drop = event.drop {
                        ZStack(alignment: .topTrailing) {
                            CLCard(theme: theme, fill: theme.yellow, padding: 16) {
                                HStack(spacing: 14) {
                                    MysteryBoxIcon(size: 30, color: theme.yellow)
                                        .padding(11)
                                        .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 14, shadow: 0, borderWidth: theme.borderThinWidth)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(drop.brand) drop")
                                            .font(.bodyFont(11, weight: .bold))
                                            .textCase(.uppercase).tracking(0.6)
                                            .foregroundColor(theme.text).opacity(0.7)
                                        Text(drop.reward)
                                            .font(.display(17))
                                            .foregroundColor(theme.text)
                                    }
                                    Spacer()
                                }
                            }
                            StickerTag(label: "go to unlock", color: theme.primary, rotate: -8, theme: CLTheme.light(primary: theme.primary))
                                .offset(x: -12, y: -12)
                        }
                        .padding(.horizontal, 20).padding(.top, 16)
                    }

                    SectionHead(title: "who's going", theme: theme)
                    HStack(spacing: -10) {
                        let avatarColors: [Color] = [Color(hex: "FF1F1F"), Color(hex: "1a0e0e"), Color(hex: "FFD60A"), Color(hex: "FF8AB3"), Color(hex: "58CC02")]
                        ForEach(Array(zip(["M","J","A","S","L"].indices, ["M","J","A","S","L"])), id: \.0) { i, c in
                            CLAvatar(name: c, size: 42, bg: avatarColors[i], fg: i == 2 ? theme.text : .white, theme: theme)
                                .overlay(Circle().strokeBorder(theme.bg, lineWidth: 3))
                        }
                        Text("+\(event.going - 5)")
                            .font(.display(12))
                            .foregroundColor(theme.text)
                            .frame(width: 42, height: 42)
                            .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                            .overlay(Circle().strokeBorder(theme.bg, lineWidth: 3))
                    }
                    .padding(.horizontal, 20)

                    SectionHead(title: "about", theme: theme)
                    Text("Annual formal at one of LA's most iconic venues.\(event.drop.map { " Sponsored by \($0.brand) — show your unlocked drop at the door." } ?? " Open to chapter + dates.") Cocktail attire.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.text)
                        .lineSpacing(3)
                        .padding(.horizontal, 20)

                    Color.clear.frame(height: 120)
                }
            }

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    // Share button
                    ShareLink(item: URL(string: "https://campuslink.app/event/\(event.id)")!) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.text)
                            .frame(width: 56, height: 56)
                            .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderWidth)
                    }
                    .buttonStyle(.plain)

                    CLButton(label: isGoing ? "you're going · +50 XP" : (event.drop != nil ? "RSVP + unlock drop" : "RSVP · +50 XP"), kind: isGoing ? .ink : .primary, size: .lg, icon: isGoing ? "checkmark" : nil, full: true, theme: theme) {
                        haptic(.medium)
                        if isGoing {
                            state.rsvps.removeAll { $0 == event.id }
                            state.showToast("RSVP cancelled", icon: "xmark")
                        } else {
                            state.rsvps.append(event.id)
                            state.xp += 50
                            state.showToast("you're going! +50 XP", icon: "checkmark")
                            if event.drop != nil {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    state.push(.drop, id: event.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 20)
            }
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Opps Screen
struct OppsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    @State private var filter = "all"
    private let filters = ["all", "ambassador", "tabling", "sponsor", "challenge"]

    var body: some View {
        CLScrollView(theme: theme, topFade: 30) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("earn")
                        .font(.display(36))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("paid campaigns from brands hunting your campus")
                        .font(.bodyFont(14))
                        .foregroundColor(theme.textMuted)
                }
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 18)

                // Earnings card — taps into full earnings tracker
                Button { state.push(.earnings) } label: {
                    ZStack(alignment: .topTrailing) {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("your earnings · spring")
                                    .font(.bodyFont(11, weight: .bold))
                                    .textCase(.uppercase)
                                    .tracking(0.8)
                                    .foregroundColor(theme.bg).opacity(0.6)
                                Text("$\(state.applied.count * 250)")
                                    .font(.display(40))
                                    .foregroundColor(theme.bg)
                                    .tracking(-1.5)
                                Text("\(max(0, state.applied.count - 1)) shipped · \(min(1, state.applied.count)) in progress")
                                    .font(.bodyFont(13, weight: .semibold))
                                    .foregroundColor(theme.bg).opacity(0.7)
                                    .padding(.top, 6)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                theme.text
                                Circle()
                                    .fill(theme.pink)
                                    .frame(width: 130, height: 130)
                                    .offset(x: 40, y: -40)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(theme.ink).offset(x: 4, y: 4)
                                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(theme.ink)
                            }
                        )

                        Text("see all →")
                            .font(.display(11))
                            .foregroundColor(theme.text)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                            .padding(.trailing, 14).padding(.top, 14)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20).padding(.bottom, 18)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { f in
                            CLChip(label: f, selected: filter == f, theme: theme) { filter = f }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 14)

                if sampleOpportunities.isEmpty {
                    CLEmptyState(
                        icon: "bolt.fill",
                        title: "no opps yet",
                        subtitle: "check back soon — brands drop new campaigns every week",
                        theme: theme
                    )
                } else {
                    VStack(spacing: 12) {
                        ForEach(sampleOpportunities) { opp in
                            OppRow(opp: opp, theme: theme) { state.push(.opp, id: opp.id) }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Color.clear.frame(height: 110)
            }
        }
    }
}

// MARK: - Opportunity Detail
struct OpportunityDetailScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private var opp: Opportunity { state.detailOpp ?? sampleOpportunities[0] }
    private var brand: Brand? { sampleBrands.first { $0.name == opp.brand } }
    private var applied: Bool { state.applied.contains(opp.id) }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Pinned top bar — stays fixed while content scrolls
                CLTopBar(title: "opportunity", onBack: { state.pop() }, theme: theme)

                CLScrollView(theme: theme, topFade: 18, bottomFade: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 14) {
                            if let brand {
                                BrandLogoTile(
                                    brand: brand,
                                    size: 64,
                                    fill: opp.accentText,
                                    ink: theme.ink,
                                    textColor: opp.accent,
                                    cornerRadius: 18,
                                    shadow: theme.shadowSm,
                                    borderWidth: theme.borderThinWidth,
                                    padding: 10
                                )
                            } else {
                                Text(opp.brand.split(separator: " ").prefix(2).map { String($0.prefix(1)) }.joined())
                                    .font(.display(24))
                                    .foregroundColor(opp.accentText)
                                    .frame(width: 64, height: 64)
                                    .stickerCard(fill: opp.accent, ink: theme.ink, cornerRadius: 18, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(opp.brand) · verified")
                                    .font(.bodyFont(12, weight: .bold))
                                    .textCase(.uppercase).tracking(0.6)
                                    .foregroundColor(theme.textMuted)
                                Text(opp.title)
                                    .font(.display(24))
                                    .foregroundColor(theme.text)
                                    .tracking(-0.6)
                                    .lineLimit(3)
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 18)

                        CLCard(theme: theme, fill: theme.yellow, padding: 18) {
                            HStack(spacing: 18) {
                                Text("$")
                                    .font(.display(28))
                                    .foregroundColor(theme.yellow)
                                    .frame(width: 56, height: 56)
                                    .stickerCard(fill: theme.text, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("payout")
                                        .font(.bodyFont(11, weight: .bold))
                                        .textCase(.uppercase).tracking(0.8)
                                        .foregroundColor(theme.text).opacity(0.7)
                                    Text(opp.payout)
                                        .font(.display(24))
                                        .foregroundColor(theme.text)
                                        .tracking(-0.5)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 16)

                        HStack(spacing: 10) {
                            StatBox(value: String(opp.seats.split(separator: " ").first ?? "?"), label: "spots", theme: theme)
                            StatBox(value: opp.deadline, label: "deadline", theme: theme)
                            StatBox(value: "Spring", label: "window", theme: theme)
                        }
                        .padding(.horizontal, 20).padding(.bottom, 18)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(opp.tags, id: \.self) { t in CLChip(label: t, theme: theme, action: nil) }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 22)

                        Text("the brief")
                            .font(.display(18)).foregroundColor(theme.text).tracking(-0.3)
                            .padding(.horizontal, 20).padding(.bottom, 10)
                        Text("\(opp.desc) You'll be paired with a brand POC, get assets + talking points, and submit deliverables in-app.")
                            .font(.bodyFont(15)).foregroundColor(theme.text).lineSpacing(3)
                            .padding(.horizontal, 20).padding(.bottom, 24)

                        Text("what you'll do")
                            .font(.display(18)).foregroundColor(theme.text).tracking(-0.3)
                            .padding(.horizontal, 20).padding(.bottom, 10)
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(["submit a 30-sec pitch video","pass brand vibe-check call (15 min)","execute the activation on your campus","submit content + receipts","get paid via in-app stripe"].enumerated()), id: \.0) { i, s in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(i+1)")
                                        .font(.display(13))
                                        .foregroundColor(.white)
                                        .frame(width: 26, height: 26)
                                        .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                                    Text(s).font(.bodyFont(14)).foregroundColor(theme.text).lineSpacing(2)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        Color.clear.frame(height: 200)
                    }
                }
            }

            // CTA bar
            HStack(spacing: 10) {
                CLButton(label: "", kind: .surface, size: .lg, icon: "message.fill", theme: theme) {
                    haptic(.light)
                    state.push(.dm, id: opp.id)
                }
                ShareLink(item: URL(string: "https://campuslink.app/opp/\(opp.id)")!) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(theme.text)
                        .frame(width: 56, height: 56)
                        .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderWidth)
                }
                .buttonStyle(.plain)
                CLButton(label: applied ? "applied ✓" : "apply · +30 XP", kind: applied ? .ink : .primary, size: .lg, icon: nil, full: true, theme: theme) {
                    if !applied {
                        haptic(.heavy)
                        state.applied.append(opp.id)
                        state.xp += 30
                        state.showToast("application sent! +30 XP", icon: "paperplane.fill")
                    }
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 12).padding(.bottom, 20)
            .background(theme.bg)
            .softChromeEdge(theme: theme, edge: .top)
        }
    }
}

// MARK: - Earnings Screen
struct EarningsScreen: View {
    @Bindable var state: AppState
    let theme: CLTheme

    private struct CampaignRow: Identifiable {
        let id: String
        let brand: String
        let title: String
        let payout: String
        let status: Status
        let accent: Color
        let accentText: Color
        enum Status { case completed, inProgress, pending }
    }

    private var rows: [CampaignRow] {
        state.applied.enumerated().compactMap { idx, id in
            guard let opp = sampleOpportunities.first(where: { $0.id == id }) else { return nil }
            let status: CampaignRow.Status = idx == state.applied.count - 1 ? .inProgress : .completed
            return CampaignRow(id: id, brand: opp.brand, title: opp.title, payout: opp.payout, status: status, accent: opp.accent, accentText: opp.accentText)
        }
    }

    private var totalEarned: Int {
        rows.filter { $0.status == .completed }.reduce(0) { sum, row in
            let nums = row.payout.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .compactMap { Int($0) }.filter { $0 >= 50 }
            return sum + (nums.first ?? 0)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            CLTopBar(title: "earnings", onBack: { state.pop() }, theme: theme)

            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    // Summary hero card
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("spring semester")
                                .font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.8)
                                .foregroundColor(theme.bg).opacity(0.6)
                            Text(totalEarned > 0 ? "$\(totalEarned)" : "$0")
                                .font(.display(52)).foregroundColor(theme.bg).tracking(-2)
                            HStack(spacing: 12) {
                                Label("\(rows.filter { $0.status == .completed }.count) completed", systemImage: "checkmark.circle.fill")
                                Label("\(rows.filter { $0.status == .inProgress }.count) in progress", systemImage: "clock.fill")
                            }
                            .font(.bodyFont(12, weight: .semibold)).foregroundColor(theme.bg).opacity(0.75)
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            ZStack(alignment: .topTrailing) {
                                theme.text
                                Circle().fill(theme.pink).frame(width: 140, height: 140).offset(x: 50, y: -50)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(theme.ink).offset(x: 4, y: 4)
                                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(theme.ink)
                            }
                        )

                        StickerTag(label: "spring '25", rotate: 5, theme: theme)
                            .padding(.trailing, 16).padding(.top, 16)
                    }
                    .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)

                    if rows.isEmpty {
                        CLEmptyState(
                            icon: "dollarsign",
                            title: "no earnings yet",
                            subtitle: "apply to your first campaign to start stacking",
                            actionLabel: "browse opps",
                            action: { state.pop(); state.setTab(.opps) },
                            theme: theme
                        )
                    } else {
                        SectionHead(title: "campaigns", theme: theme)
                        VStack(spacing: 10) {
                            ForEach(rows) { row in
                                HStack(spacing: 14) {
                                    // Brand logo tile
                                    if let brand = sampleBrands.first(where: { $0.name == row.brand }) {
                                        BrandLogoTile(brand: brand, size: 50, fill: row.accentText, ink: theme.ink, textColor: row.accent, cornerRadius: 14, shadow: 0, borderWidth: 0, padding: 7)
                                    } else {
                                        Text(row.brand.prefix(2).uppercased())
                                            .font(.display(17)).foregroundColor(row.accentText)
                                            .frame(width: 50, height: 50)
                                            .stickerCard(fill: row.accent, ink: theme.ink, cornerRadius: 14, shadow: 0, borderWidth: theme.borderThinWidth)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(row.brand).font(.bodyFont(11, weight: .bold)).textCase(.uppercase).tracking(0.4).foregroundColor(theme.textMuted)
                                        Text(row.title).font(.display(15)).foregroundColor(theme.text).lineLimit(1)
                                        Text(row.payout).font(.display(13)).foregroundColor(theme.text)
                                    }
                                    Spacer()
                                    // Status badge
                                    let (badgeColor, badgeLabel): (Color, String) = {
                                        switch row.status {
                                        case .completed: return (theme.lime, "paid ✓")
                                        case .inProgress: return (theme.yellow, "in progress")
                                        case .pending: return (theme.surface, "pending")
                                        }
                                    }()
                                    Text(badgeLabel)
                                        .font(.display(11))
                                        .foregroundColor(theme.text)
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .stickerCard(fill: badgeColor, ink: theme.ink, cornerRadius: 999, shadow: 0, borderWidth: theme.borderThinWidth)
                                }
                                .padding(14)
                                .stickerCard(fill: theme.card, ink: theme.ink, cornerRadius: 18, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // All-time stats strip
                    SectionHead(title: "all-time", theme: theme)
                    HStack(spacing: 10) {
                        StatBox(value: "\(state.applied.count)", label: "applied", theme: theme)
                        StatBox(value: "\(state.xp)", label: "XP earned", color: theme.yellow, theme: theme)
                        StatBox(value: "\(state.streak)w", label: "streak", theme: theme)
                    }
                    .padding(.horizontal, 20)

                    Color.clear.frame(height: 60)
                }
            }
        }
    }
}
