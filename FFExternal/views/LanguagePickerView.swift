import SwiftUI

struct LanguagePickerView: View {
    @AppStorage(FFLanguage.storageKey) private var storedLang = FFLanguage.english.rawValue
    @Environment(\.ffLanguage) private var lang

    let onContinue: () -> Void

    @State private var selected: FFLanguage = .english

    var body: some View {
        ZStack {
            FFBackground()

            VStack(spacing: 0) {
                Spacer(minLength: 80)

                Text("FFEX IOS")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(FFTheme.text)
                    .padding(.bottom, 8)

                Text("Select Language")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(FFTheme.textSecondary)
                    .padding(.bottom, 36)

                // Language list
                VStack(spacing: 0) {
                    ForEach(FFLanguage.allCases) { language in
                        Button {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                                selected = language
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(language.displayName)
                                    .font(.system(size: 16,
                                                  weight: selected == language ? .semibold : .regular,
                                                  design: .rounded))
                                    .foregroundStyle(selected == language ? FFTheme.text : FFTheme.textSecondary)

                                Spacer()

                                if selected == language {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(FFTheme.text)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(selected == language
                                        ? Color.white.opacity(0.08)
                                        : Color.clear)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.22, dampingFraction: 0.75), value: selected)

                        if language != FFLanguage.allCases.last {
                            Rectangle()
                                .fill(FFTheme.separator)
                                .frame(height: 0.6)
                                .padding(.leading, 20)
                        }
                    }
                }
                .background(FFTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                        .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
                )
                .padding(.horizontal, 24)

                Spacer()

                // Continue button
                FFButton(
                    title: "Continue",
                    icon: "arrow.right",
                    action: {
                        storedLang = selected.rawValue
                        onContinue()
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            selected = FFLanguage(rawValue: storedLang) ?? .english
        }
    }
}
