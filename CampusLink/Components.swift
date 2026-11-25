import SwiftUI
import UIKit
import Hugeicons

// MARK: - CampusLink Logo (real brand assets)
enum CLLogoTone { case white, black, red }
enum CLLogoStyle { case mark, wordmark }

struct CLLogo: View {
    var size: CGFloat = 28
    /// Legacy tint hint - maps to the closest brand asset tone.
    var color: Color = .white
    var tone: CLLogoTone? = nil
    var style: CLLogoStyle = .mark
    var bg: Color? = nil
    var radius: CGFloat = 12
    /// Extra inset when sitting inside a rounded well.
    var wellPadding: CGFloat = 0

    private var resolvedTone: CLLogoTone {
        if let tone { return tone }
        // Prefer explicit `tone:`. Legacy `color:` only distinguishes white vs brand red vs black.
        if color == .white { return .white }
        return .black
    }

    private var imageName: String {
        switch (style, resolvedTone) {
        case (.mark, .white): return "CLMarkWhite"
        case (.mark, .black): return "CLMarkBlack"
        case (.mark, .red): return "CLMarkRed"
        case (.wordmark, .white): return "CLWordmarkWhite"
        case (.wordmark, .black): return "CLWordmarkBlack"
        case (.wordmark, .red): return "CLWordmarkRed"
        }
    }

    var body: some View {
        let logo = Image(imageName)
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(
                width: style == .mark ? size : size * 4.8,
                height: style == .mark ? size : size * 0.55
            )
            .padding(wellPadding)

        if let bg {
            logo
                .padding(style == .mark ? size * 0.22 : 10)
                .background(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(bg)
                )
        } else {
            logo
        }
    }
}

// MARK: - Brand social icons (full-color)
enum CLBrandSocialIcon {
    case instagram
    case tiktok
    case linkedin
}

struct CLBrandSocialMark: View {
    let brand: CLBrandSocialIcon
    var size: CGFloat = 18

    var body: some View {
        Group {
            switch brand {
            case .instagram:
                // Official Instagram glyph filled with brand gradient.
                LinearGradient(
                    colors: [
                        Color(hex: "833AB4"),
                        Color(hex: "C13584"),
                        Color(hex: "E1306C"),
                        Color(hex: "FD1D1D"),
                        Color(hex: "F77737"),
                        Color(hex: "FCAF45")
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .mask(
                    Hugeicons.instagram.image()
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                )
            case .tiktok:
                // Official TikTok note with cyan / magenta chromatic offsets.
                ZStack {
                    Hugeicons.tiktok.image()
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color(hex: "25F4EE"))
                        .offset(x: -1.1, y: 0.8)
                    Hugeicons.tiktok.image()
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color(hex: "FE2C55"))
                        .offset(x: 1.1, y: -0.8)
                    Hugeicons.tiktok.image()
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color(hex: "010101"))
                }
            case .linkedin:
                // Official LinkedIn blue (#0A66C2).
                Hugeicons.linkedin01.image()
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color(hex: "0A66C2"))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Button
/// Primary CTAs: red vertical gradient, rounded-rect (not capsule), label + trailing chevron.
struct CLButton: View {
    enum Kind { case primary, ink, yellow, pink, surface, ghost }
    enum ButtonSize { case sm, md, lg }

    let label: String
    var kind: Kind = .primary
    var size: ButtonSize = .md
    /// Trailing SF Symbol. Primary defaults to `chevron.right` when nil.
    var icon: String? = nil
    /// Set false to hide the automatic primary chevron.
    var showsChevron: Bool = true
    var full: Bool = false
    let theme: CLTheme
    let action: () -> Void

    private var height: CGFloat { size == .sm ? 44 : size == .md ? 50 : 54 }
    private var hPad: CGFloat   { size == .sm ? 16 : size == .md ? 20 : 22 }
    private var fontSize: CGFloat { size == .sm ? 14 : size == .md ? 15 : 16 }
    /// Soft rounded rect matching joincampuslink CTAs - not a capsule.
    private var corner: CGFloat { 10 }

    private var fgColor: Color {
        switch kind {
        case .primary, .ink: .white
        case .yellow, .pink: theme.text
        case .ghost, .surface: theme.text
        }
    }

    private var trailingIcon: String? {
        if let icon { return icon }
        if showsChevron, kind == .primary { return "chevron.right" }
        return nil
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if !label.isEmpty {
                    Text(label)
                        .font(.bodyFont(fontSize, weight: .bold))
                        .lineLimit(1)
                }
                if let trailingIcon {
                    Image(systemName: trailingIcon)
                        .font(.system(size: fontSize - 2, weight: .bold))
                        .offset(y: trailingIcon == "paperplane.fill" ? -0.5 : 0)
                }
            }
            .foregroundColor(fgColor)
            .frame(height: height)
            .padding(.horizontal, hPad)
            .frame(maxWidth: full ? .infinity : nil)
            .background(background)
            .clipShape(shape)
            .overlay(border)
            .shadow(
                color: kind == .primary || kind == .ink ? Color.black.opacity(0.12) : .clear,
                radius: kind == .primary || kind == .ink ? 6 : 0,
                x: 0,
                y: kind == .primary || kind == .ink ? 3 : 0
            )
        }
        .buttonStyle(CLPressStyle())
    }

    @ViewBuilder
    private var background: some View {
        switch kind {
        case .primary:
            shape.fill(
                LinearGradient(
                    colors: [Color(hex: "E93B40"), theme.primary, theme.primaryDeep],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .ink:
            shape.fill(
                LinearGradient(
                    colors: [Color(hex: "2A2A2E"), theme.text],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .yellow:
            shape.fill(theme.yellow)
        case .pink:
            shape.fill(theme.pink)
        case .surface:
            shape.fill(theme.surface)
        case .ghost:
            shape.fill(Color.clear)
        }
    }

    @ViewBuilder
    private var border: some View {
        switch kind {
        case .ghost:
            shape.strokeBorder(theme.ink.opacity(0.14), lineWidth: theme.borderThinWidth)
        case .surface:
            shape.strokeBorder(theme.line, lineWidth: 1)
        default:
            EmptyView()
        }
    }
}

// MARK: - Chip
struct CLChip: View {
    let label: String
    var selected: Bool = false
    var icon: String? = nil
    /// Hugeicons asset - preferred over SF Symbol `icon` when set.
    var hugeIcon: HugeiconsAsset? = nil
    /// When true with an icon, hide the text label (icon-only filter chips).
    var iconOnly: Bool = false
    var color: Color? = nil
    var rotate: Double = 0
    let theme: CLTheme
    let action: (() -> Void)?

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
    }

    var body: some View {
        let bg = selected ? (color ?? theme.primary) : theme.surfaceAlt
        let fg: Color = selected ? (color == theme.yellow ? theme.text : .white) : theme.text

        let chipView = HStack(spacing: 7) {
            if let hugeIcon {
                hugeIcon.image()
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconOnly ? 18 : 15, height: iconOnly ? 18 : 15)
            } else if let icon {
                Image(systemName: icon).font(.system(size: 12, weight: .bold))
            }
            if !iconOnly || (hugeIcon == nil && icon == nil) {
                Text(label).font(.bodyFont(13, weight: .bold)).lineLimit(1)
            }
        }
        .foregroundColor(fg)
        .frame(width: iconOnly ? 44 : nil, height: 40)
        .padding(.horizontal, iconOnly ? 0 : 14)
        .background(shape.fill(bg))
        .overlay(
            shape.strokeBorder(selected ? Color.clear : theme.line, lineWidth: 1)
        )
        .accessibilityLabel(label)

        if let action {
            Button(action: action) { chipView }.buttonStyle(CLPressStyle(scale: 0.96))
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
    var cornerRadius: CGFloat = 20
    var shadow: CGFloat = 3
    var borderWidth: CGFloat = 1.5
    let content: Content

    init(theme: CLTheme, fill: Color? = nil, padding: CGFloat = 16, cornerRadius: CGFloat = 20, shadow: CGFloat = 3, @ViewBuilder content: () -> Content) {
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

// MARK: - Metadata tag
struct MetadataTag: View {
    let label: String
    var color: Color? = nil
    var hugeIcon: HugeiconsAsset? = nil
    var systemIcon: String? = nil
    let theme: CLTheme

    var body: some View {
        let fg: Color = color == theme.primary ? .white : theme.textMuted
        HStack(spacing: 5) {
            if let hugeIcon {
                hugeIcon.image()
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 11, height: 11)
            } else if let systemIcon {
                Image(systemName: systemIcon)
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(label)
                .font(.bodyFont(11, weight: .semibold))
        }
        .foregroundColor(fg)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule(style: .continuous).fill(color ?? theme.surfaceAlt))
        .overlay(Capsule(style: .continuous).strokeBorder(theme.ink.opacity(0.08), lineWidth: theme.borderThinWidth))
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
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.display(20, weight: .bold))
                .tracking(-0.3)
                .foregroundColor(theme.text)
            Spacer()
            if let label = actionLabel, let action = onAction {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text(label)
                            .font(.display(13, weight: .semibold))
                        if arrow {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .foregroundColor(theme.textMuted)
                }
                .buttonStyle(CLPressStyle(scale: 0.97))
            } else if let label = actionLabel {
                Text(label)
                    .font(.display(13, weight: .semibold))
                    .foregroundColor(theme.textMuted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
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

// MARK: - Screen header (gamified)
struct CLScreenHeader: View {
    let title: String
    var subtitle: String? = nil
    var theme: CLTheme
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.display(34, weight: .black))
                    .tracking(-1.0)
                    .foregroundColor(theme.text)
                if let subtitle {
                    Text(subtitle)
                        .font(.bodyFont(15, weight: .medium))
                        .foregroundColor(theme.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let trailing { trailing }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 18)
    }
}

// MARK: - Progress ring
struct CLProgressRing: View {
    var progress: CGFloat
    var lineWidth: CGFloat = 8
    var track: Color = Color.white.opacity(0.28)
    var fill: Color = .white

    var body: some View {
        ZStack {
            Circle()
                .stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(fill, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Color stat card
struct CLColorStatCard: View {
    let title: String
    let value: String
    var detail: String? = nil
    var icon: String? = nil
    var fill: Color
    var fg: Color = .white
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 10 : 14) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.bodyFont(compact ? 13 : 14, weight: .bold))
                    .foregroundColor(fg.opacity(0.88))
                Spacer(minLength: 0)
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: compact ? 16 : 18, weight: .bold))
                        .foregroundColor(fg.opacity(0.95))
                }
            }
            Text(value)
                .font(.display(compact ? 22 : 28, weight: .black))
                .foregroundColor(fg)
                .tracking(-0.6)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            if let detail {
                Text(detail)
                    .font(.bodyFont(12, weight: .semibold))
                    .foregroundColor(fg.opacity(0.78))
            }
        }
        .padding(compact ? 16 : 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .colorBlockCard(fill: fill, cornerRadius: compact ? 24 : 28)
    }
}

// MARK: - Stat Box
struct StatBox: View {
    let value: String
    let label: String
    var color: Color? = nil
    let theme: CLTheme

    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.display(20, weight: .bold))
                .tracking(-0.4)
                .foregroundColor(theme.text)
                .monospacedDigit()
            Text(label)
                .font(.eyebrow(10))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundColor(theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
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
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.text)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(theme.surfaceAlt))
                }
                .buttonStyle(CLPressStyle())
                .accessibilityLabel("Back")
            } else {
                Color.clear.frame(width: 42, height: 42)
            }
            Spacer()
            if !title.isEmpty {
                Text(title)
                    .font(.display(17, weight: .heavy))
                    .tracking(-0.3)
                    .foregroundColor(theme.text)
            }
            Spacer()
            if let t = trailing {
                t.frame(width: 42, height: 42)
            } else {
                Color.clear.frame(width: 42, height: 42)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

// MARK: - Primary Tab Bar
/// Drops sits beside My Drops, Earnings, and You shortcuts.
struct CLTabBar: View {
    @Binding var tab: AppTab
    let theme: CLTheme
    let onTab: (AppTab) -> Void

    private struct SideTab: Identifiable {
        let id: AppTab
        let icon: String
        let label: String
    }

    private let sideTabs: [SideTab] = [
        .init(id: .active, icon: "tray.fill", label: "My Drops"),
        .init(id: .earnings, icon: "banknote.fill", label: "Earnings"),
        .init(id: .you, icon: "person.fill", label: "You"),
    ]

    private var dropsSelected: Bool { tab == .drops }

    var body: some View {
        HStack(spacing: 12) {
            dropsIsland

            HStack(spacing: 0) {
                ForEach(sideTabs) { item in
                    sideButton(item)
                }
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: 184)
            .frame(height: 56)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(hex: "F3F3F5"))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(theme.bg.ignoresSafeArea(edges: .bottom))
    }

    private var dropsIsland: some View {
        Button {
            guard tab != .drops else { return }
            haptic(.light)
            onTab(.drops)
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(dropsSelected ? 0.22 : 0.14))
                        .frame(width: 32, height: 32)
                    CLLogo(size: 17, tone: .white, style: .mark)
                }

                Text("Drops")
                    .font(.bodyFont(15, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.leading, 10)
            .padding(.trailing, 18)
            .frame(height: 56)
            .background(
                Capsule(style: .continuous)
                    .fill(dropsSelected ? theme.primary : theme.primary.opacity(0.72))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Drops")
        .accessibilityAddTraits(dropsSelected ? .isSelected : [])
    }

    private func sideButton(_ item: SideTab) -> some View {
        let selected = tab == item.id
        return Button {
            guard tab != item.id else { return }
            haptic(.light)
            onTab(item.id)
        } label: {
            Image(systemName: item.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(selected ? theme.primary : theme.text.opacity(0.42))
                .frame(minWidth: 44, maxWidth: 56)
                .frame(height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// MARK: - Lock root width / disable sideways rubber-banding helpers
struct CLHorizontalLock: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
    }
}

extension View {
    func clLockHorizontal() -> some View {
        modifier(CLHorizontalLock())
    }
}

/// Keeps UIKit's edge-swipe-back alive when SwiftUI hides the nav back button.
/// Allows the gesture only when there is something to pop (no root rubber-banding).
struct CLInteractivePopGesture: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.attachIfNeeded()
    }

    final class Controller: UIViewController, UIGestureRecognizerDelegate {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.isUserInteractionEnabled = false
            view.backgroundColor = .clear
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            attachIfNeeded()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            attachIfNeeded()
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            attachIfNeeded()
        }

        func attachIfNeeded() {
            guard let nav = findNavigationController() else { return }
            let pop = nav.interactivePopGestureRecognizer
            pop?.isEnabled = true
            pop?.delegate = self
        }

        private func findNavigationController() -> UINavigationController? {
            if let nav = navigationController { return nav }
            var responder: UIResponder? = self
            while let current = responder {
                if let nav = current as? UINavigationController { return nav }
                if let vc = current as? UIViewController, let nav = vc.navigationController { return nav }
                responder = current.next
            }
            return parent?.navigationController
                ?? sequence(first: parent, next: { $0?.parent }).compactMap { $0 as? UINavigationController }.first
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (findNavigationController()?.viewControllers.count ?? 0) > 1
        }

        /// Prefer edge-swipe-back over competing scroll/drag recognizers near the leading edge.
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            gestureRecognizer == findNavigationController()?.interactivePopGestureRecognizer
        }
    }
}

extension View {
    /// Attach inside NavigationStack roots and destinations so swipe-back works
    /// even with `navigationBarBackButtonHidden(true)`.
    func clInteractivePopGesture() -> some View {
        background(CLInteractivePopGesture().frame(width: 0, height: 0))
    }
}

// MARK: - Toast Notification
struct CLToast: View {
    let message: String
    var icon: String = "checkmark"
    let theme: CLTheme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(theme.primary))
            Text(message)
                .font(.display(14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            Capsule(style: .continuous)
                .fill(theme.text.opacity(0.94))
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
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
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(theme.textMuted)
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(theme.surfaceAlt)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(theme.ink.opacity(0.08), lineWidth: 1)
                )
            VStack(spacing: 6) {
                Text(title)
                    .font(.display(17, weight: .bold))
                    .tracking(-0.2)
                    .foregroundColor(theme.text)
                Text(subtitle)
                    .font(.bodyFont(14, weight: .medium))
                    .foregroundColor(theme.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            if let label = actionLabel, let act = action {
                CLButton(label: label, kind: .ink, size: .sm, theme: theme, action: act)
                    .padding(.top, 4)
            }
        }
        .padding(32)
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
