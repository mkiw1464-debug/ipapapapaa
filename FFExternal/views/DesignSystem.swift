import SwiftUI

// MARK: - FF External Design System
// Theme: iOS dark grey + white — clean, bold, no gimmicks

enum FFTheme {
    // MARK: Colors
    // Background — deep iOS grouped grey (not pure black, not white)
    static let background        = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let backgroundSecond  = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let card              = Color(red: 0.19, green: 0.19, blue: 0.21)
    static let cardElevated      = Color(red: 0.23, green: 0.23, blue: 0.25)

    static let glass             = Color.white.opacity(0.06)
    static let glassBorder       = Color.white.opacity(0.10)
    static let separator         = Color.white.opacity(0.08)

    // Text
    static let text              = Color.white
    static let textSecondary     = Color(white: 0.55)
    static let textTertiary      = Color(white: 0.38)

    // Accent — pure white for primary actions (iOS dark mode style)
    static let accent            = Color.white
    static let accentAlt         = Color(white: 0.75)

    // Semantic
    static let success           = Color(red: 0.18, green: 0.78, blue: 0.38)   // iOS green
    static let danger            = Color(red: 0.95, green: 0.28, blue: 0.28)   // iOS red
    static let warn              = Color(red: 0.95, green: 0.70, blue: 0.15)   // iOS yellow

    // MARK: Typography
    static let titleFont    = Font.system(size: 30, weight: .bold,    design: .rounded)
    static let subtitleFont = Font.system(size: 14, weight: .regular, design: .rounded)
    static let bodyFont     = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let captionFont  = Font.system(size: 12, weight: .regular, design: .rounded)
    static let labelFont    = Font.system(size: 11, weight: .semibold, design: .rounded)
    static let monoFont     = Font.system(size: 13, weight: .medium,  design: .monospaced)

    // MARK: Shape
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

    // Legacy alias kept so existing call sites compile
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
        case .primary:   return Color.white
        case .secondary: return FFTheme.cardElevated
        case .danger:    return FFTheme.danger.opacity(0.15)
        }
    }
    private var labelColor: Color {
        switch style {
        case .primary:   return Color(red: 0.08, green: 0.08, blue: 0.09)
        case .secondary: return FFTheme.text
        case .danger:    return FFTheme.danger
        }
    }
    private var borderColor: Color {
        switch style {
        case .primary:   return Color.clear
        case .secondary: return FFTheme.glassBorder
        case .danger:    return FFTheme.danger.opacity(0.4)
        }
    }
}
