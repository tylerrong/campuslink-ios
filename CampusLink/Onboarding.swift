import SwiftUI

// MARK: - Onboarding progress bar
struct ObProgress: View {
    let step: Int
    let total: Int
    let theme: CLTheme

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(theme.line)
                    .frame(height: 6)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.primary)
                        .frame(width: geo.size.width * CGFloat(step) / CGFloat(total))
                        .animation(.easeOut(duration: 0.25), value: step)
                }
                .frame(height: 6)
            }
            Text("\(step)/\(total)")
                .font(.display(13))
                .foregroundColor(theme.textMuted)
                .monospacedDigit()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

struct BackBtn: View {
    let theme: CLTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                Text("Back")
                    .font(.display(13, weight: .bold))
            }
            .foregroundColor(theme.text)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 14)
    }
}

struct ObFooter: View {
    let theme: CLTheme
    let label: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [theme.bg.opacity(0), theme.bg], startPoint: .top, endPoint: .bottom)
                .frame(height: 32)
            CLButton(
                label: label,
                kind: .primary,
                size: .lg,
                full: true,
                theme: theme,
                action: action
            )
            .opacity(disabled ? 0.45 : 1)
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
        ZStack {
            Color(hex: "0B0B0D").ignoresSafeArea()
            RadialGradient(
                colors: [theme.primary.opacity(0.45), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Image("CLMarkWhite")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color.white.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .scaleEffect(appear ? 1 : 0.94)

                Image("CLWordmarkWhite")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .frame(height: 30)
                    .padding(.top, 28)

                Text("Drops that pay. Proof that verifies.\nEscrow that protects both sides.")
                    .font(.bodyFont(16, weight: .medium))
                    .foregroundColor(.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 14)

                Spacer(minLength: 0)

                Button(action: onNext) {
                    HStack(spacing: 7) {
                        Text("Get started")
                            .font(.bodyFont(15, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "0B0B0D"))
                    .frame(height: 48)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white)
                    )
                    .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(CLPressStyle(scale: 0.98))
                .padding(.bottom, 52)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { withAnimation(.easeOut(duration: 0.45)) { appear = true } }
    }
}

// MARK: - Role
struct OnRoleView: View {
    @Binding var profileKind: ProfileKind
    let theme: CLTheme
    var totalSteps: Int = 3
    var backLabel: String = "Sign out"
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 1, total: totalSteps, theme: theme)
            CLScrollView(theme: theme) {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                            Text(backLabel)
                                .font(.display(13, weight: .bold))
                        }
                        .foregroundColor(theme.text)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 14)
                    Text("Who are you\nhere as?")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Students and campus orgs both earn from opportunities. Your feed adapts to your role.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                        .padding(.bottom, 28)

                    roleCard(
                        kind: .student,
                        title: "Student",
                        subtitle: "Claim Drops for yourself — installs, surveys, social proof.",
                        icon: "person.fill"
                    )
                    .padding(.bottom, 12)

                    roleCard(
                        kind: .org,
                        title: "Campus org",
                        subtitle: "Claim org-eligible Drops for your chapter, club, or team.",
                        icon: "person.3.fill"
                    )

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "Continue", action: onNext)
        }
        .background(theme.bg.ignoresSafeArea())
    }

    private func roleCard(kind: ProfileKind, title: String, subtitle: String, icon: String) -> some View {
        let sel = profileKind == kind
        return Button {
            haptic(.light)
            profileKind = kind
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(sel ? .white : theme.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(sel ? theme.primary : theme.primary.opacity(0.10))
                    )
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.display(18, weight: .bold))
                        .foregroundColor(theme.text)
                    Text(subtitle)
                        .font(.bodyFont(14))
                        .foregroundColor(theme.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: sel ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(sel ? theme.primary : theme.line)
            }
            .padding(16)
            .stickerCard(
                fill: theme.surface,
                ink: theme.ink,
                cornerRadius: 18,
                shadow: sel ? theme.shadowSm : 0,
                borderWidth: theme.borderThinWidth
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(sel ? theme.primary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(CLPressStyle())
    }
}

// MARK: - School Logo
struct SchoolLogo: View {
    let school: School
    var size: CGFloat = 46
    var cornerRadius: CGFloat? = nil
    var showBorder: Bool = true

    private var radius: CGFloat { cornerRadius ?? size * 0.26 }
    private var pad: CGFloat { size * 0.12 }

    var body: some View {
        Group {
            if let urlStr = school.logoUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fit).padding(pad)
                    case .failure:
                        initialsView
                    case .empty:
                        ProgressView().scaleEffect(0.7)
                    @unknown default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay(
            Group {
                if showBorder {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color(hex: "E7E7EA"), lineWidth: 1)
                }
            }
        )
        .accessibilityLabel(school.name)
    }

    private var initialsView: some View {
        Text(String(school.name.prefix(2)).uppercased())
            .font(.system(size: size * 0.34, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(school.color)
    }
}

// MARK: - School picker
struct OnSchoolView: View {
    @Binding var schoolId: String
    @Binding var year: String
    var showYear: Bool = true
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var query = ""
    private let years = ["Freshman", "Sophomore", "Junior", "Senior", "Grad"]

    private var filtered: [School] {
        let q = query.lowercased()
        if q.isEmpty { return sampleSchools }
        return sampleSchools.filter { $0.name.lowercased().contains(q) || $0.sub.lowercased().contains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 2, total: 5, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text("Which campus?")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Drops are matched to your school first.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10).padding(.bottom, 20)

                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(theme.textMuted)
                        TextField("Search schools", text: $query)
                            .font(.bodyFont(15))
                            .foregroundColor(theme.text)
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 14)
                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                    .padding(.bottom, 16)

                    ForEach(filtered) { school in
                        let sel = school.id == schoolId
                        Button { schoolId = school.id } label: {
                            HStack(spacing: 14) {
                                SchoolLogo(school: school)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(school.name).font(.display(17, weight: .bold)).foregroundColor(theme.text)
                                    Text(school.sub)
                                        .font(.bodyFont(12, weight: .medium))
                                        .foregroundColor(theme.textMuted)
                                }
                                Spacer()
                                Image(systemName: sel ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(sel ? theme.primary : theme.line)
                                    .font(.system(size: 22))
                            }
                            .padding(14)
                            .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)
                        }
                        .buttonStyle(CLPressStyle())
                        .padding(.bottom, 10)
                    }

                    if showYear {
                        Text("Year")
                            .font(.eyebrow(11))
                            .tracking(0.6)
                            .textCase(.uppercase)
                            .foregroundColor(theme.textMuted)
                            .padding(.top, 18)
                            .padding(.bottom, 10)

                        FlowLayout(spacing: 8) {
                            ForEach(years, id: \.self) { y in
                                CLChip(label: y, selected: year == y, theme: theme) { year = y }
                            }
                        }
                    }

                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "Continue", disabled: schoolId.isEmpty, action: onNext)
        }
        .background(theme.bg.ignoresSafeArea())
    }
}

// MARK: - Verify
struct OnVerifyView: View {
    @Binding var eduEmail: String
    @Binding var verificationStatus: VerificationStatus
    let schoolName: String
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void
    let onSubmit: (String) -> Void

    private var valid: Bool {
        let e = eduEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return e.contains("@") && e.contains(".")
    }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 3, total: 5, theme: theme)
            CLScrollView(theme: theme) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text("Verify your\nschool email")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Brands fund escrow for verified \(schoolName) students and orgs. You can finish this later.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                        .padding(.bottom, 28)

                    TextField("you@\(schoolName.lowercased()).edu", text: $eduEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .font(.bodyFont(16, weight: .medium))
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)

                    if verificationStatus == .pending {
                        Label("Check your inbox — verifying…", systemImage: "envelope.open")
                            .font(.bodyFont(13, weight: .medium))
                            .foregroundColor(theme.warning)
                            .padding(.top, 14)
                    } else if verificationStatus == .verified {
                        Label("Verified", systemImage: "checkmark.seal.fill")
                            .font(.bodyFont(13, weight: .semibold))
                            .foregroundColor(theme.success)
                            .padding(.top, 14)
                    }

                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, 24)
            }
            VStack(spacing: 10) {
                ObFooter(theme: theme, label: verificationStatus == .verified ? "Continue" : "Send verification", disabled: !valid && verificationStatus != .verified) {
                    if verificationStatus == .verified {
                        onNext()
                    } else {
                        onSubmit(eduEmail)
                    }
                }
                if verificationStatus != .verified {
                    Button("Skip for now") { onNext() }
                        .font(.bodyFont(14, weight: .semibold))
                        .foregroundColor(theme.textMuted)
                        .padding(.bottom, 24)
                }
            }
        }
        .background(theme.bg.ignoresSafeArea())
        .onChange(of: verificationStatus) { _, status in
            if status == .verified {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { onNext() }
            }
        }
    }
}

// MARK: - Interests
struct OnInterestsView: View {
    @Binding var interests: [String]
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 4, total: 5, theme: theme)
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    BackBtn(theme: theme, action: onBack)
                    Text("What should we\nmatch you with?")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Pick at least three. We’ll rank Drops around them.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                        .padding(.bottom, 18)
                }
                .padding(.horizontal, 24)

                CLScrollView(theme: theme, topFade: 18) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(studentInterests) { i in
                            let sel = interests.contains(i.id)
                            Button {
                                if sel { interests.removeAll { $0 == i.id } }
                                else { interests.append(i.id) }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: i.icon)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(width: 22)
                                    Text(i.label)
                                        .font(.display(14, weight: .bold))
                                        .foregroundColor(sel ? .white : theme.text)
                                        .lineLimit(2)
                                    Spacer(minLength: 0)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                                .stickerCard(
                                    fill: sel ? theme.primary : theme.surface,
                                    ink: theme.ink,
                                    cornerRadius: 16,
                                    shadow: 0,
                                    borderWidth: theme.borderThinWidth
                                )
                            }
                            .buttonStyle(CLPressStyle())
                        }
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, 24)
                }
            }
            ObFooter(
                theme: theme,
                label: interests.count < 3 ? "Choose \(3 - interests.count) more" : "Continue",
                disabled: interests.count < 3,
                action: onNext
            )
        }
        .background(theme.bg.ignoresSafeArea())
    }
}

// MARK: - Org details
struct OnOrgDetailsView: View {
    @Binding var orgName: String
    @Binding var orgType: OrgType
    @Binding var orgMemberCount: String
    let theme: CLTheme
    let onNext: () -> Void
    let onBack: () -> Void

    private var valid: Bool { orgName.trimmingCharacters(in: .whitespaces).count >= 2 }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 4, total: 5, theme: theme)
            CLScrollView(theme: theme) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text("Tell us about\nyour org")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Org-eligible Drops will show in your feed.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                        .padding(.bottom, 24)

                    Text("Org name")
                        .font(.eyebrow(11))
                        .textCase(.uppercase)
                        .foregroundColor(theme.textMuted)
                        .padding(.bottom, 8)
                    TextField("e.g. Tri Delta, Startup Society", text: $orgName)
                        .font(.bodyFont(16, weight: .medium))
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)

                    Text("Type")
                        .font(.eyebrow(11))
                        .textCase(.uppercase)
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 22)
                        .padding(.bottom, 10)
                    FlowLayout(spacing: 8) {
                        ForEach([OrgType.fraternity, .sorority, .club, .team, .other]) { t in
                            CLChip(label: t.label, selected: orgType == t, theme: theme) { orgType = t }
                        }
                    }

                    Text("Approx. members")
                        .font(.eyebrow(11))
                        .textCase(.uppercase)
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 22)
                        .padding(.bottom, 8)
                    TextField("80", text: $orgMemberCount)
                        .keyboardType(.numberPad)
                        .font(.bodyFont(16, weight: .medium))
                        .padding(.horizontal, 16)
                        .frame(height: 54)
                        .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "Continue", disabled: !valid, action: onNext)
        }
        .background(theme.bg.ignoresSafeArea())
    }
}

// MARK: - Handle / finish
struct OnHandleView: View {
    @Binding var handle: String
    var isOrg: Bool = false
    var orgName: String = ""
    let theme: CLTheme
    let onDone: () -> Void
    let onBack: () -> Void

    private var valid: Bool { isOrg ? true : handle.count >= 3 }

    var body: some View {
        VStack(spacing: 0) {
            ObProgress(step: 5, total: 5, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme, action: onBack)
                    Text(isOrg ? "You’re ready\nto claim Drops" : "Create your\nhandle")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text(isOrg
                          ? "\(orgName.isEmpty ? "Your org" : orgName) will appear on submissions and earnings."
                          : "Brands see this when they review your proof.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10).padding(.bottom, 28)

                    HStack {
                        Spacer()
                        Text(avatarLetter)
                            .font(.display(40, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 96, height: 96)
                            .background(Circle().fill(theme.primary))
                        Spacer()
                    }
                    .padding(.bottom, 28)

                    if !isOrg {
                        HStack(spacing: 4) {
                            Text("@")
                                .font(.display(22, weight: .bold))
                                .foregroundColor(theme.textMuted)
                            TextField("yourname", text: $handle)
                                .font(.display(22, weight: .bold))
                                .foregroundColor(theme.text)
                                .autocorrectionDisabled()
                                .onChange(of: handle) { _, v in
                                    handle = String(v.filter { $0.isLetter || $0.isNumber || $0 == "_" }.lowercased().prefix(20))
                                }
                        }
                        .frame(height: 56)
                        .padding(.horizontal, 16)
                        .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)

                        Text("joincampuslink.com/\(handle.isEmpty ? "yourname" : handle)")
                            .font(.bodyFont(13, weight: .medium))
                            .foregroundColor(theme.textMuted)
                            .padding(.top, 10)
                    } else {
                        escrowStrip
                    }
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "Enter CampusLink", disabled: !valid, action: onDone)
        }
        .background(theme.bg.ignoresSafeArea())
    }

    private var avatarLetter: String {
        if isOrg {
            return String((orgName.first ?? "O")).uppercased()
        }
        return handle.isEmpty ? "?" : String(handle.prefix(1).uppercased())
    }

    private var escrowStrip: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundColor(theme.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Escrow-backed Drops")
                    .font(.display(14, weight: .semibold))
                    .foregroundColor(theme.text)
                Text("Brands pre-fund. You get paid when proof is approved.")
                    .font(.bodyFont(13))
                    .foregroundColor(theme.textMuted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stickerCard(fill: theme.surfaceAlt, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)
    }
}

// MARK: - FlowLayout
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
