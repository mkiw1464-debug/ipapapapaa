import SwiftUI

// MARK: - FF External Design System
// Adaptive light/dark — guna UIColor yang auto-respond ikut colorScheme sistem.

enum FFTheme {
    // MARK: - Background
    // Dark: hampir hitam | Light: grouped background iOS
    static let background = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
            : UIColor.systemGroupedBackground
    })

    static let card = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.19, green: 0.19, blue: 0.21, alpha: 1)
            : UIColor.secondarySystemGroupedBackground
    })

    static let cardElevated = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.23, green: 0.23, blue: 0.25, alpha: 1)
            : UIColor.tertiarySystemGroupedBackground
    })

    static let glassBorder = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor.black.withAlphaComponent(0.08)
    })

    static let separator = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.separator
    })

    // MARK: - Text
    static let text          = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary  = Color(UIColor.tertiaryLabel)

    // MARK: - Accent
    static let accent    = Color.primary
    static let accentAlt = Color.secondary

    // MARK: - Semantic
    static let success = Color(red: 0.18, green: 0.78, blue: 0.38)
    static let danger  = Color(red: 0.95, green: 0.28, blue: 0.28)
    static let warn    = Color(red: 0.95, green: 0.70, blue: 0.15)

    // MARK: - Typography (font sistem iPhone)
    static let titleFont    = Font.system(size: 30, weight: .bold,    design: .rounded)
    static let subtitleFont = Font.system(size: 14, weight: .regular, design: .rounded)
    static let bodyFont     = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let captionFont  = Font.system(size: 12, weight: .regular, design: .rounded)
    static let labelFont    = Font.system(size: 11, weight: .semibold, design: .rounded)
    static let monoFont     = Font.system(size: 13, weight: .medium,  design: .monospaced)

    // MARK: - Shape
    static let cornerRadius: CGFloat = 16
    static let cardPadding:  CGFloat = 16
}

// MARK: - Background

struct FFBackground: View {
    var body: some View {
        FFTheme.background.ignoresSafeArea()
    }
}

// MARK: - Card modifier

struct CardModifier: ViewModifier {
    var padding: CGFloat = FFTheme.cardPadding
    var radius:  CGFloat = FFTheme.cornerRadius
    var color:   Color   = FFTheme.card

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
                    )
            )
    }
}

extension View {
    func ffCard(padding: CGFloat = FFTheme.cardPadding,
                radius:  CGFloat = FFTheme.cornerRadius,
                color:   Color   = FFTheme.card) -> some View {
        modifier(CardModifier(padding: padding, radius: radius, color: color))
    }

    func glassCard(padding: CGFloat = FFTheme.cardPadding,
                   cornerRadius: CGFloat = FFTheme.cornerRadius) -> some View {
        ffCard(padding: padding, radius: cornerRadius)
    }

    func shimmerBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
        )
    }
}

// MARK: - Primary Button

struct FFButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var isLoading: Bool  = false
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle { case primary, secondary, danger }

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(labelColor)
                        .scaleEffect(0.85)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(FFTheme.bodyFont)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(labelColor)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius - 2, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FFTheme.cornerRadius - 2, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 0.8)
            )
            .opacity(isDisabled ? 0.40 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
    }

    private var bgColor: Color {
        switch style {
        case .primary:   return Color.primary
        case .secondary: return FFTheme.cardElevated
        case .danger:    return FFTheme.danger.opacity(0.15)
        }
    }

    private var labelColor: Color {
        switch style {
        case .primary:   return colorScheme == .dark ? .black : .white
        case .secondary: return FFTheme.text
        case .danger:    return FFTheme.danger
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:   return Color.clear
        case .secondary: return FFTheme.glassBorder
        case .danger:    return FFTheme.danger.opacity(0.30)
        }
    }
}
