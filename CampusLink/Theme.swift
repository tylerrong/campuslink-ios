import SwiftUI

// MARK: - Hex Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Theme
struct CLTheme {
    let primary: Color
    let ink: Color
    let onPrimary: Color
    let bg: Color
    let surface: Color
    let surfaceAlt: Color
    let card: Color
    let text: Color
    let textMuted: Color
    let textFaint: Color
    let yellow: Color
    let lime: Color
    let pink: Color
    let success: Color
    let tabBg: Color
    let tabFg: Color
    let isDark: Bool

    // Sticker dimensions
    let borderWidth: CGFloat = 2.5
    let borderThinWidth: CGFloat = 2.0
    let shadowMd: CGFloat = 4
    let shadowSm: CGFloat = 2
    let shadowLg: CGFloat = 6

    static func light(primary: Color = Color(hex: "FF1F1F")) -> CLTheme {
        CLTheme(
            primary: primary,
            ink: Color(hex: "1a0e0e"),
            onPrimary: .white,
            bg: Color(hex: "FFE9D2"),
            surface: .white,
            surfaceAlt: Color(hex: "FFD9B0"),
            card: .white,
            text: Color(hex: "1a0e0e"),
            textMuted: Color(hex: "1a0e0e").opacity(0.62),
            textFaint: Color(hex: "1a0e0e").opacity(0.38),
            yellow: Color(hex: "FFD60A"),
            lime: Color(hex: "C8FF3D"),
            pink: Color(hex: "FF1F1F"),
            success: Color(hex: "0EA85B"),
            tabBg: Color(hex: "1a0e0e"),
            tabFg: Color(hex: "FFE9D2"),
            isDark: false
        )
    }

    static func dark(primary: Color = Color(hex: "FF1F1F")) -> CLTheme {
        CLTheme(
            primary: primary,
            ink: Color(hex: "FFE9D2"),
            onPrimary: .white,
            bg: Color(hex: "1a0e0e"),
            surface: Color(hex: "2A1A1A"),
            surfaceAlt: Color(hex: "3A2828"),
            card: Color(hex: "2A1A1A"),
            text: Color(hex: "FFE9D2"),
            textMuted: Color(hex: "FFE9D2").opacity(0.65),
            textFaint: Color(hex: "FFE9D2").opacity(0.40),
            yellow: Color(hex: "FFD60A"),
            lime: Color(hex: "C8FF3D"),
            pink: Color(hex: "FF1F1F"),
            success: Color(hex: "3FE07A"),
            tabBg: Color(hex: "FFE9D2"),
            tabFg: Color(hex: "1a0e0e"),
            isDark: true
        )
    }
}

// MARK: - Font Helpers
extension Font {
    // SF Pro Rounded → approximates Bricolage Grotesque
    static func display(_ size: CGFloat, weight: Font.Weight = .black) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
    static func bodyFont(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Sticker View Modifiers
extension View {
    func softScrollEdges(theme: CLTheme, top: CGFloat = 18, bottom: CGFloat = 30) -> some View {
        self
            .overlay(alignment: .top) {
                if top > 0 {
                    LinearGradient(
                        colors: [theme.bg, theme.bg.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: top)
                    .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .bottom) {
                if bottom > 0 {
                    LinearGradient(
                        colors: [theme.bg.opacity(0), theme.bg],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: bottom)
                    .allowsHitTesting(false)
                }
            }
    }

    func softChromeEdge(theme: CLTheme, edge: VerticalEdge, height: CGFloat = 24) -> some View {
        self
            .overlay(alignment: .top) {
                if edge == .top {
                    theme.ink.opacity(0.12).frame(height: 1)
                        .allowsHitTesting(false)
                }
            }
            .overlay(alignment: edge == .top ? .top : .bottom) {
                LinearGradient(
                    colors: edge == .top
                        ? [theme.bg, theme.bg.opacity(0)]
                        : [theme.bg.opacity(0), theme.bg],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: height)
                .offset(y: edge == .top ? -height : height)
                .allowsHitTesting(false)
            }
    }

    /// Hard sticker card: ink border + pixel-perfect offset shadow.
    /// Implemented as an outer ink shape with an inset fill shape (instead of
    /// `strokeBorder` + `fill`), which renders a clean single border without
    /// the faint anti-aliased "double line" that can appear with `.continuous`
    /// corner style when fill and stroke are layered separately.
    func stickerCard(
        fill: Color,
        ink: Color,
        cornerRadius: CGFloat = 22,
        shadow: CGFloat = 4,
        borderWidth: CGFloat = 2.5
    ) -> some View {
        let innerRadius = max(0, cornerRadius - borderWidth)
        return self
            .background(
                RoundedRectangle(cornerRadius: innerRadius, style: .continuous)
                    .fill(fill)
                    .padding(borderWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ink)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ink)
                    .offset(x: shadow, y: shadow)
            )
    }

    /// Two-layer border only — no offset shadow. Same outer-ink / inner-fill layering
    /// as `stickerCard`, used for text fields, meta rows, subtle chips, progress tracks.
    func stickerOutline(
        fill: Color,
        ink: Color,
        cornerRadius: CGFloat = 14,
        borderWidth: CGFloat = 2
    ) -> some View {
        let innerRadius = max(0, cornerRadius - borderWidth)
        return self
            .background(
                RoundedRectangle(cornerRadius: innerRadius, style: .continuous)
                    .fill(fill)
                    .padding(borderWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(ink)
            )
    }

    /// Thin outline only — pass an explicit `fill` so the ink border layer doesn't show through.
    func stickerBorder(fill: Color = .white, ink: Color, cornerRadius: CGFloat = 999, borderWidth: CGFloat = 2) -> some View {
        self.stickerOutline(fill: fill, ink: ink, cornerRadius: cornerRadius, borderWidth: borderWidth)
    }
}

// MARK: - Soft Scroll Container
struct CLScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let theme: CLTheme
    let topFade: CGFloat
    let bottomFade: CGFloat
    let content: Content

    init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        theme: CLTheme,
        topFade: CGFloat = 0,
        bottomFade: CGFloat = 30,
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.theme = theme
        self.topFade = topFade
        self.bottomFade = bottomFade
        self.content = content()
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content
        }
        .background(theme.bg)
        .softScrollEdges(theme: theme, top: topFade, bottom: bottomFade)
    }
}
