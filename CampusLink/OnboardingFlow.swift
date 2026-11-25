import SwiftUI

/// Native campus onboarding — replaces IncompleteProfileView web bounce.
struct OnboardingFlowView: View {
    @Bindable var auth: AuthStore
    let theme: CLTheme

    enum Step: Int {
        case role = 1
        case about = 2
        case presence = 3
    }

    @State private var step: Step = .role
    @State private var profileKind: ProfileKind = .student

    // Shared
    @State private var selectedSchool: RemoteSchool?
    @State private var schoolQuery = ""
    @State private var schools: [RemoteSchool] = []
    @State private var schoolsLoading = false
    @State private var primaryPhone = ""

    // Student
    @State private var fullName = ""
    @State private var graduationYear: Int = Calendar.current.component(.year, from: Date()) + 2
    @State private var major = ""
    @State private var studentType: StudentAccountType = .ambassador
    @State private var sport = ""

    // Org
    @State private var orgName = ""
    @State private var orgType: OrgType = .club
    @State private var memberCount = ""

    // Presence
    @State private var instagram = ""
    @State private var tiktok = ""
    @State private var linkedin = ""
    @State private var website = ""
    @State private var bio = ""
    @State private var termsAccepted = false

    @State private var localError = ""
    @State private var showWebFallback = false

    private let yearOptions: [Int] = {
        let y = Calendar.current.component(.year, from: Date())
        return Array(y...(y + 6))
    }()

    var body: some View {
        ZStack {
            theme.bg.ignoresSafeArea()
            switch step {
            case .role:
                OnRoleView(
                    profileKind: $profileKind,
                    theme: theme,
                    totalSteps: 3,
                    onNext: { step = .about },
                    onBack: { auth.signOut() }
                )
            case .about:
                aboutStep
            case .presence:
                presenceStep
            }
        }
        .task(id: step) {
            if step == .about, schools.isEmpty {
                await loadSchools(query: "")
            }
        }
        .onChange(of: schoolQuery) { _, q in
            Task { await loadSchools(query: q) }
        }
    }

    // MARK: - About

    private var aboutStep: some View {
        VStack(spacing: 0) {
            ObProgress(step: 2, total: 3, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme) { step = .role }

                    Text(profileKind == .org ? "About your org" : "About you")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Matched to your campus first — same profile as joincampuslink.com.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                        .padding(.bottom, 22)

                    if profileKind == .student {
                        fieldLabel("Full name")
                        textField("Your name", text: $fullName)
                            .padding(.bottom, 16)
                        fieldLabel("Major")
                        textField("e.g. Computer Science", text: $major)
                            .padding(.bottom, 16)
                        fieldLabel("Graduation year")
                        FlowLayout(spacing: 8) {
                            ForEach(yearOptions, id: \.self) { y in
                                CLChip(label: String(y), selected: graduationYear == y, theme: theme) {
                                    graduationYear = y
                                }
                            }
                        }
                        .padding(.bottom, 16)
                        fieldLabel("How do you work with brands?")
                        FlowLayout(spacing: 8) {
                            ForEach(StudentAccountType.allCases) { type in
                                CLChip(
                                    label: type.label,
                                    selected: studentType == type,
                                    theme: theme
                                ) {
                                    studentType = type
                                    if type != .athlete { sport = "" }
                                }
                            }
                        }
                        .padding(.bottom, 8)
                        Text(studentType.detail)
                            .font(.bodyFont(12))
                            .foregroundColor(theme.textMuted)
                            .padding(.bottom, studentType == .athlete ? 12 : 16)
                        if studentType == .athlete {
                            fieldLabel("Sport")
                            textField("e.g. Soccer, Track", text: $sport)
                                .padding(.bottom, 16)
                        }
                    } else {
                        fieldLabel("Org name")
                        textField("e.g. Tri Delta, Startup Society", text: $orgName)
                            .padding(.bottom, 16)
                        fieldLabel("Type")
                        FlowLayout(spacing: 8) {
                            ForEach([OrgType.fraternity, .sorority, .club, .team, .officialUniversity, .independent, .other]) { t in
                                CLChip(label: t.label, selected: orgType == t, theme: theme) { orgType = t }
                            }
                        }
                        .padding(.bottom, 16)
                        fieldLabel("Approx. members")
                        textField("80", text: $memberCount)
                            .keyboardType(.numberPad)
                            .padding(.bottom, 16)
                    }

                    fieldLabel("Phone")
                    textField("(555) 123-4567", text: $primaryPhone)
                        .keyboardType(.phonePad)
                        .padding(.bottom, 16)

                    fieldLabel("School")
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(theme.textMuted)
                        TextField("Search schools", text: $schoolQuery)
                            .font(.bodyFont(15))
                            .foregroundColor(theme.text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 14)
                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                    .padding(.bottom, 12)

                    if schoolsLoading && schools.isEmpty {
                        ProgressView().padding(.vertical, 12)
                    }

                    ForEach(schools) { school in
                        schoolRow(school)
                            .padding(.bottom, 8)
                    }

                    if let selected = selectedSchool, !schools.contains(where: { $0.id == selected.id }) {
                        schoolRow(selected)
                            .padding(.bottom, 8)
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(theme: theme, label: "Continue", disabled: !aboutValid) {
                step = .presence
            }
        }
        .background(theme.bg.ignoresSafeArea())
    }

    // MARK: - Presence

    private var presenceStep: some View {
        VStack(spacing: 0) {
            ObProgress(step: 3, total: 3, theme: theme)
            CLScrollView(theme: theme, topFade: 18) {
                VStack(alignment: .leading, spacing: 0) {
                    BackBtn(theme: theme) { step = .about }

                    Text("Social & presence")
                        .font(.display(34, weight: .bold))
                        .foregroundColor(theme.text)
                        .tracking(-1.2)
                    Text("Helps brands find the right campus partners.")
                        .font(.bodyFont(15))
                        .foregroundColor(theme.textMuted)
                        .padding(.top, 10)
                        .padding(.bottom, 22)

                    fieldLabel("Instagram (required)")
                    HStack(spacing: 4) {
                        Text("@")
                            .font(.display(18, weight: .bold))
                            .foregroundColor(theme.textMuted)
                        TextField("handle", text: $instagram)
                            .font(.bodyFont(16, weight: .medium))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: instagram) { _, v in
                                instagram = String(v.filter { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "." }.prefix(30))
                            }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                    .padding(.bottom, 16)

                    fieldLabel("TikTok (optional)")
                    textField("@handle", text: $tiktok)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.bottom, 16)

                    if profileKind == .student {
                        fieldLabel("LinkedIn (optional)")
                        textField("https://linkedin.com/in/…", text: $linkedin)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.bottom, 16)
                        fieldLabel("Bio (optional)")
                        TextField("A short intro", text: $bio, axis: .vertical)
                            .font(.bodyFont(16, weight: .medium))
                            .lineLimit(3...5)
                            .padding(16)
                            .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
                            .padding(.bottom, 16)
                    } else {
                        fieldLabel("Website (optional)")
                        textField("https://…", text: $website)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.bottom, 16)
                    }

                    Toggle(isOn: $termsAccepted) {
                        Text("I agree to the Terms of Service and Privacy Policy.")
                            .font(.bodyFont(14))
                            .foregroundColor(theme.text)
                    }
                    .tint(theme.primary)
                    .padding(.top, 8)

                    HStack(spacing: 16) {
                        Link("Terms", destination: URL(string: "\(AppState.webBaseURL)/legal/terms")!)
                        Link("Privacy", destination: URL(string: "\(AppState.webBaseURL)/legal/privacy")!)
                    }
                    .font(.bodyFont(13, weight: .semibold))
                    .foregroundColor(theme.primary)
                    .padding(.top, 8)

                    if !localError.isEmpty {
                        Text(localError)
                            .font(.bodyFont(13, weight: .medium))
                            .foregroundColor(theme.primary)
                            .padding(.top, 14)
                    }

                    Button {
                        showWebFallback.toggle()
                    } label: {
                        Text("Having trouble? Finish on the website")
                            .font(.bodyFont(13, weight: .medium))
                            .foregroundColor(theme.textMuted)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 18)

                    if showWebFallback, let url = URL(string: "\(AppState.webBaseURL)/onboarding") {
                        Link("Open joincampuslink.com/onboarding", destination: url)
                            .font(.bodyFont(13, weight: .semibold))
                            .foregroundColor(theme.primary)
                            .padding(.top, 6)
                    }

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 24)
            }
            ObFooter(
                theme: theme,
                label: auth.isBusy ? "Saving…" : "Enter CampusLink",
                disabled: !presenceValid || auth.isBusy
            ) {
                Task { await submit() }
            }
        }
        .background(theme.bg.ignoresSafeArea())
    }

    // MARK: - Helpers

    private var aboutValid: Bool {
        guard selectedSchool != nil else { return false }
        let phone = primaryPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard phone.count >= 7 else { return false }
        if profileKind == .student {
            let basics = fullName.trimmingCharacters(in: .whitespaces).count >= 2
                && major.trimmingCharacters(in: .whitespaces).count >= 2
            if studentType == .athlete {
                return basics && sport.trimmingCharacters(in: .whitespaces).count >= 2
            }
            return basics
        }
        let members = Int(memberCount.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        return orgName.trimmingCharacters(in: .whitespaces).count >= 2 && members > 0
    }

    private var presenceValid: Bool {
        instagram.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 && termsAccepted
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.eyebrow(11))
            .textCase(.uppercase)
            .foregroundColor(theme.textMuted)
            .padding(.bottom, 8)
    }

    private func textField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.bodyFont(16, weight: .medium))
            .padding(.horizontal, 16)
            .frame(height: 54)
            .stickerOutline(fill: theme.surface, ink: theme.ink, cornerRadius: 14, borderWidth: theme.borderThinWidth)
    }

    private func schoolRow(_ school: RemoteSchool) -> some View {
        let sel = selectedSchool?.id == school.id
        let display = School.fromRemote(school)
        return Button {
            selectedSchool = school
            haptic(.light)
        } label: {
            HStack(spacing: 14) {
                SchoolLogo(school: display)
                VStack(alignment: .leading, spacing: 2) {
                    Text(school.short_name)
                        .font(.display(17, weight: .bold))
                        .foregroundColor(theme.text)
                    Text(school.name)
                        .font(.bodyFont(12, weight: .medium))
                        .foregroundColor(theme.textMuted)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: sel ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(sel ? theme.primary : theme.line)
                    .font(.system(size: 22))
            }
            .padding(14)
            .stickerCard(fill: theme.surface, ink: theme.ink, cornerRadius: 16, shadow: 0, borderWidth: theme.borderThinWidth)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(sel ? theme.primary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(CLPressStyle())
    }

    private func loadSchools(query: String) async {
        guard let token = auth.sessionToken, !auth.isSimulatorPreview else {
            schools = []
            localError = "Sign in to load schools."
            return
        }
        schoolsLoading = true
        defer { schoolsLoading = false }
        do {
            schools = try await APIClient.shared.fetchSchools(token: token, query: query, limit: 40)
            if !schools.isEmpty { localError = "" }
        } catch {
            if schools.isEmpty {
                localError = error.localizedDescription
            }
        }
    }

    private func submit() async {
        localError = ""
        guard let school = selectedSchool else {
            localError = "Pick your school."
            return
        }
        let ig = instagram.trimmingCharacters(in: .whitespacesAndNewlines)
        var body = OnboardingRequest(
            profile_type: profileKind == .org ? "campus_org" : "student",
            school: school.id,
            primary_phone: primaryPhone.trimmingCharacters(in: .whitespacesAndNewlines),
            instagram_handle: ig,
            terms_accepted: termsAccepted
        )
        if profileKind == .student {
            body.full_name = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
            body.graduation_year = graduationYear
            body.major = major.trimmingCharacters(in: .whitespacesAndNewlines)
            body.student_type = studentType.rawValue
            if studentType == .athlete {
                let sp = sport.trimmingCharacters(in: .whitespacesAndNewlines)
                body.sport = sp.isEmpty ? nil : sp
            }
            let tk = tiktok.trimmingCharacters(in: .whitespacesAndNewlines)
            body.tiktok_handle = tk.isEmpty ? nil : tk.replacingOccurrences(of: "@", with: "")
            let li = linkedin.trimmingCharacters(in: .whitespacesAndNewlines)
            body.linkedin_url = li.isEmpty ? nil : li
            let b = bio.trimmingCharacters(in: .whitespacesAndNewlines)
            body.bio = b.isEmpty ? nil : b
        } else {
            body.org_name = orgName.trimmingCharacters(in: .whitespacesAndNewlines)
            body.org_type = orgType.webValue
            body.member_count = Int(memberCount.trimmingCharacters(in: .whitespacesAndNewlines))
            let tk = tiktok.trimmingCharacters(in: .whitespacesAndNewlines)
            body.tiktok_handle = tk.isEmpty ? nil : tk.replacingOccurrences(of: "@", with: "")
            let web = website.trimmingCharacters(in: .whitespacesAndNewlines)
            body.website = web.isEmpty ? nil : web
        }
        do {
            try await auth.completeOnboarding(body)
            haptic(.medium)
        } catch {
            localError = error.localizedDescription
            haptic(.heavy)
        }
    }
}

private extension OrgType {
    /// Values accepted by web `org_type` / validateOrgProfile.
    var webValue: String {
        switch self {
        case .fraternity: return "fraternity"
        case .sorority: return "sorority"
        case .club: return "club"
        case .team: return "team"
        case .officialUniversity: return "official_university"
        case .independent: return "independent"
        case .other, .greek, .creator: return "other"
        }
    }
}
