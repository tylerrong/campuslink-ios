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
/// Gamified CampusLink system: clean white canvas, bold rounded type, color-block cards.
struct CLTheme {
    let primary: Color
    let primaryDeep: Color
    let ink: Color
    let onPrimary: Color
    let bg: Color
    let surface: Color
    let surfaceAlt: Color
    let card: Color
    let line: Color
    let text: Color
    let textMuted: Color
    let textFaint: Color
    let yellow: Color
    let lime: Color
    let pink: Color
    let success: Color
    let warning: Color
    let accentGreen: Color
    let accentBlue: Color
    let accentOrange: Color
    let tabBg: Color
    let tabFg: Color
    let isDark: Bool

    let borderWidth: CGFloat
    let borderThinWidth: CGFloat
    let shadowMd: CGFloat
    let shadowSm: CGFloat
    let shadowLg: CGFloat
    let radiusMd: CGFloat
    let radiusLg: CGFloat
    let radiusXl: CGFloat

    static func light(primary: Color = Color(hex: "D8292F")) -> CLTheme {
        CLTheme(
            primary: primary,
            primaryDeep: Color(hex: "A81A20"),
            ink: Color(hex: "111114"),
            onPrimary: .white,
            bg: Color(hex: "FFFFFF"),
            surface: .white,
            surfaceAlt: Color(hex: "F4F5F7"),
            card: .white,
            line: Color(hex: "ECECEF"),
            text: Color(hex: "111114"),
            textMuted: Color(hex: "6E6E76"),
            textFaint: Color(hex: "6E6E76").opacity(0.7),
            yellow: Color(hex: "F5C400"),
            lime: Color(hex: "B8F000"),
            pink: Color(hex: "D8292F"),
            success: Color(hex: "22C55E"),
            warning: Color(hex: "F59E0B"),
            accentGreen: Color(hex: "22C55E"),
            accentBlue: Color(hex: "3B82F6"),
            accentOrange: Color(hex: "FF6B35"),
            tabBg: .white,
            tabFg: Color(hex: "111114"),
            isDark: false,
            borderWidth: 1.0,
            borderThinWidth: 0.75,
            shadowMd: 3,
            shadowSm: 2,
            shadowLg: 5,
            radiusMd: 18,
            radiusLg: 28,
            radiusXl: 32
        )
    }

    static func dark(primary: Color = Color(hex: "D8292F")) -> CLTheme {
        CLTheme(
            primary: primary,
            primaryDeep: Color(hex: "A81A20"),
            ink: Color(hex: "FAFAFB"),
            onPrimary: .white,
            bg: Color(hex: "0B0B0D"),
            surface: Color(hex: "17171A"),
            surfaceAlt: Color(hex: "222226"),
            card: Color(hex: "17171A"),
            line: Color.white.opacity(0.13),
            text: Color(hex: "FAFAFB"),
            textMuted: Color(hex: "FAFAFB").opacity(0.62),
            textFaint: Color(hex: "FAFAFB").opacity(0.42),
            yellow: Color(hex: "F5C400"),
            lime: Color(hex: "C6F000"),
            pink: Color(hex: "F3A19D"),
            success: Color(hex: "3FE07A"),
            warning: Color(hex: "F5C400"),
            accentGreen: Color(hex: "22C55E"),
            accentBlue: Color(hex: "60A5FA"),
            accentOrange: Color(hex: "FF8A5B"),
            tabBg: Color(hex: "FAFAFB"),
            tabFg: Color(hex: "0B0B0D"),
            isDark: true,
            borderWidth: 1.0,
            borderThinWidth: 0.75,
            shadowMd: 3,
            shadowSm: 2,
            shadowLg: 5,
            radiusMd: 18,
            radiusLg: 28,
            radiusXl: 32
        )
    }
}

// MARK: - Typography
extension Font {
    /// Bold rounded display — gamified / bubbly headers.
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        let resolved: Font.Weight = {
            switch weight {
            case .regular, .medium: return .semibold
            case .semibold: return .bold
            case .bold: return .heavy
            case .heavy, .black: return .black
            default: return weight
            }
        }()
        return .system(size: size, weight: resolved, design: .rounded)
    }

    static func bodyFont(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func eyebrow(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

// MARK: - Motion
struct CLPressStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

// MARK: - Surfaces
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

    func softChromeEdge(theme: CLTheme, edge: VerticalEdge, height: CGFloat = 20) -> some View {
        self
            .overlay(alignment: .top) {
                if edge == .top {
                    theme.line.frame(height: 1)
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

    func stickerCard(
        fill: Color,
        ink: Color,
        cornerRadius: CGFloat = 28,
        shadow: CGFloat = 4,
        borderWidth: CGFloat = 0
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(
                shape
                    .fill(fill)
                    .shadow(
                        color: Color.black.opacity(shadow > 0 ? 0.07 : 0),
                        radius: max(0, shadow) * 4,
                        x: 0,
                        y: max(0, shadow) * 1.4
                    )
            )
            .overlay(
                Group {
                    if borderWidth > 0 {
                        shape.strokeBorder(Color(hex: "E7E7EA").opacity(0.9), lineWidth: borderWidth)
                    }
                }
            )
    }

    func stickerOutline(
        fill: Color,
        ink: Color,
        cornerRadius: CGFloat = 18,
        borderWidth: CGFloat = 1
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(shape.fill(fill))
            .overlay(shape.strokeBorder(Color(hex: "ECECEF"), lineWidth: borderWidth))
    }

    func stickerBorder(fill: Color = .white, ink: Color, cornerRadius: CGFloat = 999, borderWidth: CGFloat = 1) -> some View {
        self.stickerOutline(fill: fill, ink: ink, cornerRadius: cornerRadius, borderWidth: borderWidth)
    }

    func premiumHeroCard(
        fill: Color,
        ink: Color,
        cornerRadius: CGFloat = 32,
        borderWidth: CGFloat = 0
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(
                shape
                    .fill(fill)
                    .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 10)
            )
            .overlay(
                Group {
                    if borderWidth > 0 {
                        shape.strokeBorder(Color.white.opacity(0.08), lineWidth: borderWidth)
                    }
                }
            )
    }

    /// Soft color-block card used for gamified stats.
    func colorBlockCard(fill: Color, cornerRadius: CGFloat = 28) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(
                shape
                    .fill(fill)
                    .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
            )
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
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .background(theme.bg)
        .softScrollEdges(theme: theme, top: topFade, bottom: bottomFade)
    }
}

// MARK: - Money helpers
extension Int {
    var dollarsFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: Double(self) / 100.0)) ?? "$\(self / 100)"
    }

    var dollarsCompact: String {
        if self % 100 == 0 { return "$\(self / 100)" }
        return String(format: "$%.2f", Double(self) / 100.0)
    }
}
