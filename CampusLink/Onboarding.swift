import SwiftUI

// MARK: - Onboarding progress bar
private struct ObProgress: View {
    let step: Int
    let total: Int
    let theme: CLTheme

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .leading) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous).fill(theme.ink)
                    RoundedRectangle(cornerRadius: 2, style: .continuous).fill(theme.surface).padding(theme.borderThinWidth)
                }
                .frame(height: 8)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.primary)
                        .frame(width: geo.size.width * CGFloat(step) / CGFloat(total))
                        .animation(.spring(response: 0.35), value: step)
                }
                .frame(height: 8)
            }
            Text("\(step)/\(total)")
                .font(.display(13))
                .foregroundColor(theme.text)
                .monospacedDigit()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

// MARK: - Back button
private struct BackBtn: View {
    let theme: CLTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                Text("back")
                    .font(.display(13, weight: .bold))
            }
            .foregroundColor(theme.text)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 14)
    }
}

// MARK: - Footer CTA button
private struct ObFooter: View {
    let theme: CLTheme
    let label: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [theme.bg.opacity(0), theme.bg], startPoint: .top, endPoint: .bottom)
                .frame(height: 32)
            Button(action: action) {
                Text(label)
                    .font(.display(18))
                    .foregroundColor(disabled ? theme.textFaint : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .stickerCard(
                        fill: disabled ? theme.surface : theme.primary,
                        ink: theme.ink, cornerRadius: 28,
                        shadow: disabled ? 0 : theme.shadowMd,
                        borderWidth: theme.borderWidth
                    )
            }
            .buttonStyle(.plain)
            .disabled(disabled)
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(theme.bg)
    }
}

// MARK: - Splash
struct SplashView: View {
    let theme: CLTheme
    let onNext: () -> Void

    @State private var appear = false

    var body: some View {
        Button(action: onNext) {
            ZStack {
                theme.primary.ignoresSafeArea()
                // Diagonal stripe pattern
                Canvas { ctx, sz in
                    for i in stride(from: -sz.width, to: sz.width * 2, by: 120) {
                        var p = Path()
                        p.move(to: CGPoint(x: i, y: 0))
                        p.addLine(to: CGPoint(x: i + sz.height, y: sz.height))
                        p.addLine(to: CGPoint(x: i + sz.height + 40, y: sz.height))
                        p.addLine(to: CGPoint(x: i + 40, y: 0))
                        p.closeSubpath()
                        ctx.fill(p, with: .color(.white.opacity(0.05)))
                    }
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    CLLogo(size: 120, color: .white)
                        .scaleEffect(appear ? 1 : 0.3)
                        .opacity(appear ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: appear)

                    Text("CampusLink")
                        .font(.display(56))
                        .foregroundColor(.white)
                        .tracking(-1.5)
                        .padding(.top, 28)
                        .offset(y: appear ? 0 : 20)
                        .opacity(appear ? 1 : 0)
                        .animation(.spring(response: 0.7).delay(0.2), value: appear)

                    Text("brands you love. on your campus.\ndrops you can't get anywhere else.")
                        .font(.bodyFont(17, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                        .offset(y: appear ? 0 : 20)
                        .opacity(appear ? 1 : 0)
                        .animation(.spring(response: 0.7).delay(0.35), value: appear)

                    Text("tap to start →")
                        .font(.display(14))
                        .foregroundColor(theme.primary)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .stickerCard(fill: .white, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                        .padding(.top, 40)
                        .offset(y: appear ? 0 : 20)
                        .opacity(appear ? 1 : 0)
                        .animation(.spring(response: 0.7).delay(0.6), value: appear)
                }
            }
        }
        .buttonStyle(.plain)
        .onAppear { appear = true }
    }
}

// MARK: - School Logo (AsyncImage + initials fallback)
struct SchoolLogo: View {
    let school: School

    var body: some View {
        Group {
            if let urlStr = school.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(6)
                    default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: 46, height: 46)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(hex: "1a0e0e"), lineWidth: 2)
        )
    }

    private var initialsView: some View {
        Text(String(school.name.prefix(2)).uppercased())
            .font(.system(size: 16, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(school.color)
    }
}

// MARK: - School picker
struct OnSchoolView: View {
    @Binding var schoolId: String
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var query = ""

    private var filtered: [School] {
        let q = query.lowercased()
        if q.isEmpty { return sampleSchools }
        return sampleSchools.filter { $0.name.lowercased().contains(q) || $0.sub.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 1, total: 4, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text("which school\nyou at?")
                        .font(.display(36))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("we'll surface the brands sponsoring on your campus.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10).padding(.bottom, 20)

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(theme.textMuted)
                        TextField("search 1,400+ schools", text: $query)
                            .font(.bodyFont(15))
                            .foregroundColor(theme.text)
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 14)
                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                    .padding(.bottom, 16)

                    ForEach(filtered) { school in
                        let sel = school.id == schoolId
                        Button {
                            schoolId = school.id
                        } label: {
                            HStack(spacing: 14) {
                                // Logo box — AsyncImage with initials fallback
                                SchoolLogo(school: school)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(school.name).font(.display(17)).foregroundColor(theme.text)
                                    Text("\(school.sub) · \(school.students) on app")
                                        .font(.bodyFont(12, weight: .semibold))
                                        .foregroundColor(theme.textMuted)
                                }
                                Spacer()
                                ZStack {
                                    Circle().fill(theme.ink).frame(width: 28, height: 28)
                                    Circle().fill(sel ? theme.text : theme.surface).padding(theme.borderThinWidth).frame(width: 28, height: 28)
                                    if sel { Image(systemName: "checkmark").font(.system(size: 13, weight: .black)).foregroundColor(.white) }
                                }
                            }
                            .padding(14)
                            .stickerCard(fill: sel ? theme.yellow : theme.surface, ink: theme.ink, cornerRadius: 18, shadow: sel ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 10)
                    }
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "next", disabled: schoolId.isEmpty, action: onNext)
        }
        .background(theme.bg.ignoresSafeArea())
    }
}

// MARK: - Role / Year picker
struct OnRoleView: View {
    @Binding var role: AppRole
    @Binding var year: String
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void

    private let years = ["Freshman", "Sophomore", "Junior", "Senior"]
    private let orgTypes = ["Fraternity", "Sorority", "Club", "Athletics", "Other"]

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 2, total: 4, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text("who are you\non campus?")
                        .font(.display(36))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("you can switch roles anytime.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10).padding(.bottom, 24)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        roleCard(id: .student, label: "Student", desc: "connect with brands, score drops", icon: "★", color: theme.primary)
                        roleCard(id: .org, label: "Org admin", desc: "get your events sponsored", icon: "Ω", color: theme.yellow)
                    }
                    .padding(.bottom, 28)

                    Text("year")
                        .font(.bodyFont(11, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(0.6)
                        .foregroundColor(theme.text).opacity(0.7)
                        .padding(.bottom, 12)

                    if role == .student {
                        FlowLayout(spacing: 8) {
                            ForEach(years, id: \.self) { y in
                                CLChip(label: y, selected: year == y, theme: theme) { year = y }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        FlowLayout(spacing: 8) {
                            ForEach(orgTypes, id: \.self) { t in
                                CLChip(label: t, selected: year == t, theme: theme) { year = t }
                            }
                        }
                        .padding(.bottom, 16)
                        CLCard(theme: theme, fill: theme.surfaceAlt, padding: 14) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(theme.text)
                                Text("we'll verify your org with a .edu email + current member roster. takes ~24h.")
                                    .font(.bodyFont(13))
                                    .foregroundColor(theme.text)
                                    .lineSpacing(2)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 24)
                .animation(.spring(response: 0.3), value: role)
            }
            ObFooter(theme: theme, label: "next", disabled: year.isEmpty, action: onNext)
        }
        .background(theme.bg.ignoresSafeArea())
    }

    @ViewBuilder
    private func roleCard(id: AppRole, label: String, desc: String, icon: String, color: Color) -> some View {
        let sel = role == id
        Button { role = id } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(icon)
                    .font(.display(22))
                    .foregroundColor(sel ? color : (color == theme.yellow ? theme.text : .white))
                    .frame(width: 44, height: 44)
                    .stickerCard(fill: sel ? .white : color, ink: theme.ink, cornerRadius: 14, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                Text(label).font(.display(18)).foregroundColor(sel && color == theme.primary ? .white : theme.text)
                Text(desc).font(.bodyFont(13)).foregroundColor((sel && color == theme.primary ? Color.white : theme.text).opacity(0.9)).lineSpacing(2)
                Spacer()
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .stickerCard(fill: sel ? color : theme.surface, ink: theme.ink, cornerRadius: 20, shadow: sel ? theme.shadowMd : 0, borderWidth: theme.borderThinWidth)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Interests picker
struct OnInterestsView: View {
    @Binding var interests: [String]
    let role: AppRole
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void

    private var isStudent: Bool { role == .student }
    private var items: [Interest] { isStudent ? studentInterests : orgInterests }

    private var headline: String { isStudent ? "what are you\ninto?" : "what are you\nlooking for?" }
    private var subtitle: String {
        isStudent
            ? "pick at least 3. we'll match you to the right campaigns."
            : "pick at least 3. we'll connect you with the right brands."
    }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 3, total: 4, theme: theme)
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    BackBtn(theme: theme, action: onBack)
                    Text(headline)
                        .font(.display(36))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text(subtitle)
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                    Text(interests.count == 0 ? "none selected" : "\(interests.count) selected")
                        .font(.display(13))
                        .foregroundColor(interests.count == 0 ? theme.textFaint : theme.primary)
                        .padding(.bottom, 18)
                }
                .padding(.horizontal, 24)

                CLScrollView(theme: theme, topFade: 18) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(items) { i in
                            let sel = interests.contains(i.id)
                            Button {
                                if sel { interests.removeAll { $0 == i.id } }
                                else { interests.append(i.id) }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: i.icon)
                                        .font(.system(size: 18, weight: .bold))
                                        .frame(width: 26, alignment: .center)
                                    Text(i.label)
                                        .font(.display(15))
                                        .foregroundColor(sel ? .white : theme.text)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer()
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                                .stickerCard(fill: sel ? theme.primary : theme.surface, ink: theme.ink, cornerRadius: 18, shadow: sel ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)
                            }
                            .buttonStyle(.plain)
                        }
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, 24)
                }
                .animation(.spring(response: 0.3), value: role)
            }
            ObFooter(
                theme: theme,
                label: interests.count < 3 ? "pick \(3 - interests.count) more" : "next",
                disabled: interests.count < 3,
                action: onNext
            )
        }
        .background(theme.bg.ignoresSafeArea())
    }
}

// MARK: - Handle picker
struct OnHandleView: View {
    @Binding var handle: String
    let theme: CLTheme
    let onDone: () -> Void
    let onBack: () -> Void

    private var valid: Bool { handle.count >= 3 }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 4, total: 4, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text("claim your\nhandle.")
                        .font(.display(36))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("brands + orgs will see this.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10).padding(.bottom, 28)

                    // Avatar preview
                    HStack {
                        Spacer()
                        ZStack(alignment: .bottomTrailing) {
                            Text(handle.isEmpty ? "?" : String(handle.prefix(1).uppercased()))
                                .font(.display(44))
                                .foregroundColor(.white)
                                .frame(width: 100, height: 100)
                                .stickerCard(fill: theme.primary, ink: theme.ink, cornerRadius: 50, shadow: theme.shadowMd, borderWidth: theme.borderWidth)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(theme.text)
                                .frame(width: 36, height: 36)
                                .stickerCard(fill: theme.yellow, ink: theme.ink, cornerRadius: 999, shadow: theme.shadowSm, borderWidth: theme.borderThinWidth)
                                .offset(x: 4, y: 4)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 28)

                    HStack(spacing: 4) {
                        Text("@")
                            .font(.display(22))
                            .foregroundColor(theme.textMuted)
                        TextField("yourname", text: $handle)
                            .font(.display(22))
                            .foregroundColor(theme.text)
                            .autocorrectionDisabled()
                            .onChange(of: handle) { _, v in
                                handle = String(v.filter { $0.isLetter || $0.isNumber || $0 == "_" }.lowercased().prefix(20))
                            }
                        if valid {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(theme.success)
                        }
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                    .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 16, shadow: valid ? theme.shadowSm : 0, borderWidth: theme.borderThinWidth)

                    Text("campuslink.com/\(handle.isEmpty ? "yourname" : handle)")
                        .font(.bodyFont(13, weight: .semibold))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10).padding(.leading, 4)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "enter campuslink →", disabled: !valid, action: onDone)
        }
        .background(theme.bg.ignoresSafeArea())
    }
}

// MARK: - FlowLayout helper (wrapping HStack)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if rowWidth + sz.width + (rows.last!.isEmpty ? 0 : spacing) > width {
                rows.append([sv]); rowWidth = sz.width
            } else {
                rows[rows.count - 1].append(sv)
                rowWidth += sz.width + (rows.last!.count > 1 ? spacing : 0)
            }
        }
        let height = rows.reduce(0.0) { acc, row in
            let h = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            return acc + h
        } + CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        for sv in subviews {
            let sz = sv.sizeThatFits(.unspecified)
            if rowWidth + sz.width + (rows.last!.isEmpty ? 0 : spacing) > bounds.width {
                rows.append([sv]); rowWidth = sz.width
            } else {
                rows[rows.count - 1].append(sv)
                rowWidth += sz.width + (rows.last!.count > 1 ? spacing : 0)
            }
        }
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            let rowH = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for sv in row {
                let sz = sv.sizeThatFits(.unspecified)
                sv.place(at: CGPoint(x: x, y: y + (rowH - sz.height) / 2), proposal: ProposedViewSize(sz))
                x += sz.width + spacing
            }
            y += rowH + spacing
        }
    }
}
