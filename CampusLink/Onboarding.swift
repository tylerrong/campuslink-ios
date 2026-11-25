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
                    Text("Students and campus orgs both earn from Drops. Your feed adapts to your role.")
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
