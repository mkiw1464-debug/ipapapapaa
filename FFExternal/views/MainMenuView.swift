import SwiftUI

// MARK: - App State

class FFAppState: ObservableObject {
    @Published var exploitStatus: ExploitStatus = .notStarted
    @Published var exploitRunning = false

    // Per-game inject state — aim dan holo berasingan
    @Published var ffAimInjected:  Bool = false
    @Published var ffHoloInjected: Bool = false
    @Published var ffMaxAimInjected:  Bool = false
    @Published var ffMaxHoloInjected: Bool = false

    private var autoRunDone = false

    var isSupported: Bool {
        if case .unsupported = exploitStatus { return false }
        return true
    }

    func boot() {
        let v = AppInfo.versionTuple
        let supported = ExploitSupportPolicy.isSupported(
            major: v.major, minor: v.minor, patch: v.patch, build: AppInfo.osBuild
        )
        if !supported {
            exploitStatus = .unsupported("iOS \(AppInfo.osVersion)")
            return
        }
        if KernelExploit.requiresSandboxEscape && KernelExploit.hasSandboxAccess() {
            exploitStatus = .success(method: "kexploit")
            return
        }
        if !autoRunDone { autoRunDone = true; runExploit() }
    }

    func runExploit() {
        guard !exploitRunning, !exploitStatus.isSuccess else { return }
        exploitRunning = true
        exploitStatus  = .notStarted
        DispatchQueue.global(qos: .userInitiated).async {
            let ok = KernelExploit.run()
            DispatchQueue.main.async {
                self.exploitRunning = false
                self.exploitStatus  = ok
                    ? .success(method: "kexploit")
                    : .failed(method: "kexploit", code: -1)
            }
        }
    }

    func syncInjectedState() {
        let ff    = FFGame.freeFire.bundleID
        let ffMax = FFGame.freefireMax.bundleID
        ffAimInjected     = FFCheatService.hasAimBackup(bundleID: ff)
        ffHoloInjected    = FFCheatService.hasHoloBackup(bundleID: ff)
        ffMaxAimInjected  = FFCheatService.hasAimBackup(bundleID: ffMax)
        ffMaxHoloInjected = FFCheatService.hasHoloBackup(bundleID: ffMax)
    }

    func aimInjected(for game: FFGame) -> Binding<Bool> {
        Binding(
            get: { game == .freeFire ? self.ffAimInjected : self.ffMaxAimInjected },
            set: { v in
                if game == .freeFire { self.ffAimInjected = v }
                else { self.ffMaxAimInjected = v }
            }
        )
    }

    func holoInjected(for game: FFGame) -> Binding<Bool> {
        Binding(
            get: { game == .freeFire ? self.ffHoloInjected : self.ffMaxHoloInjected },
            set: { v in
                if game == .freeFire { self.ffHoloInjected = v }
                else { self.ffMaxHoloInjected = v }
            }
        )
    }
}

// MARK: - Main Menu

struct MainMenuView: View {
    @Environment(\.ffLanguage) private var lang
    @StateObject private var state = FFAppState()

    @AppStorage("ffColorScheme") private var storedScheme = "dark"

    @State private var selectedTab:        Int           = 0
    @State private var countdown:          String        = ""
    @State private var showLogoutConfirm   = false
    @State private var showLanguagePicker  = false
    @State private var cheatStatus:        CheatStatus   = .placeholder
    @State private var statusLoading:      Bool          = true
    @State private var revalidateTick:     Int           = 0

    let licenseInfo: LicenseInfo
    let onLogout: () -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Content
            TabView(selection: $selectedTab) {
                menuTab
                    .tag(0)
                gameTab
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.32, dampingFraction: 0.85), value: selectedTab)

            // Bottom tab bar
            bottomTabBar
        }
        .background(FFTheme.background.ignoresSafeArea())
        .onAppear {
            state.boot()
            state.syncInjectedState()
            refreshCountdown()
        }
        .task { await loadStatus() }
        .onChange(of: selectedTab) { tab in
            if tab == 0 { Task { await loadStatus() } }
        }
        .onReceive(timer) { _ in
            refreshCountdown()
            if let exp = licenseInfo.expiryDate, exp < Date() { onLogout() }
            revalidateTick += 1
            if revalidateTick >= 60 {
                revalidateTick = 0
                Task {
                    let still = await LicenseService.revalidateBackground(key: licenseInfo.key)
                    if !still { await MainActor.run { onLogout() } }
                    await loadStatus()
                }
            }
        }
        .alert(lang.t("logout_confirm_title"), isPresented: $showLogoutConfirm) {
            Button(lang.t("logout_confirm_yes"), role: .destructive) { onLogout() }
            Button(lang.t("logout_confirm_cancel"), role: .cancel) {}
        } message: {
            Text(lang.t("logout_confirm_msg"))
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView(onContinue: { showLanguagePicker = false })
        }
    }

    // MARK: - Load status

    private func loadStatus() async {
        statusLoading = true
        if let s = try? await FFCheatManifest.fetchStatus() {
            await MainActor.run { cheatStatus = s; statusLoading = false }
        } else {
            await MainActor.run { statusLoading = false }
        }
    }

    private func refreshCountdown() {
        if let exp = licenseInfo.expiryDate {
            countdown = LicenseService.countdownString(from: exp)
        }
    }

    // MARK: - MENU Tab

    private var menuTab: some View {
        ZStack(alignment: .top) {
            FFTheme.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    menuHeader
                    VStack(spacing: 14) {
                        statusCard
                            .padding(.horizontal, 20)
                        infoCard
                            .padding(.horizontal, 20)
                        telegramRow
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    // MARK: - Menu Header

    private var menuHeader: some View {
        HStack(spacing: 10) {
            Text(lang.t("header_title"))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(FFTheme.text)

            Spacer()

            // Dark / Light toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    storedScheme = storedScheme == "dark" ? "light" : "dark"
                }
            } label: {
                Image(systemName: storedScheme == "dark" ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FFTheme.text)
                    .frame(width: 36, height: 36)
                    .background(FFTheme.card)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(FFTheme.glassBorder, lineWidth: 0.8))
            }
            .buttonStyle(.plain)

            // Language
            Button { showLanguagePicker = true } label: {
                Image(systemName: "globe")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FFTheme.text)
                    .frame(width: 36, height: 36)
                    .background(FFTheme.card)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(FFTheme.glassBorder, lineWidth: 0.8))
            }
            .buttonStyle(.plain)

            // Logout
            Button { showLogoutConfirm = true } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(FFTheme.danger)
                    .frame(width: 36, height: 36)
                    .background(FFTheme.danger.opacity(0.12))
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(FFTheme.danger.opacity(0.25), lineWidth: 0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
    }

    // MARK: - Status Card

    private var statusCard: some View {
        VStack(spacing: 0) {
            cardSectionHeader(lang.t("cheat_status_title"))

            // Overall status row
            statusRow(
                label: lang.t("status_label"),
                value: cheatStatus.status.uppercased(),
                note: nil,
                statusColor: statusColor(cheatStatus.status)
            )

            rowSep

            statusRow(label: "AIMBODY",      value: cheatStatus.aimBody.uppercased(),     note: nil, statusColor: statusColor(cheatStatus.aimBody))
            rowSep
            statusRow(label: "AIMNECK",      value: cheatStatus.aimNeck.uppercased(),     note: nil, statusColor: statusColor(cheatStatus.aimNeck))
            rowSep
            statusRow(label: "AIMCHEST",     value: cheatStatus.aimChest.uppercased(),    note: nil, statusColor: statusColor(cheatStatus.aimChest))
            rowSep
            statusRow(label: "AIMDRAG",      value: cheatStatus.aimDrag.uppercased(),     note: nil, statusColor: statusColor(cheatStatus.aimDrag))
            rowSep
            statusRow(label: "MAGIC BULLET", value: cheatStatus.magicBullet.uppercased(), note: nil, statusColor: statusColor(cheatStatus.magicBullet))
            rowSep
            statusRow(label: "HOLOGRAM",     value: cheatStatus.hologram.uppercased(),    note: nil, statusColor: statusColor(cheatStatus.hologram))
        }
        .background(FFTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
        )
        .redacted(reason: statusLoading ? .placeholder : [])
    }

    private func statusRow(label: String, value: String, note: String?, statusColor: Color) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(FFTheme.textSecondary)
                    .tracking(0.5)
                if let note {
                    Text(note)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(FFTheme.textTertiary)
                }
            }
            Spacer()
            HStack(spacing: 5) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 7, height: 7)
                Text(value)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)
                    .tracking(0.4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(statusColor.opacity(0.10))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(statusColor.opacity(0.25), lineWidth: 0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private func statusColor(_ value: String) -> Color {
        switch value.uppercased() {
        case "ONLINE", "SAFE":       return FFTheme.success
        case "MAINTENANCE":          return FFTheme.warn
        default:                     return FFTheme.danger
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(spacing: 0) {
            cardSectionHeader(lang.t("info_card_title"))

            infoRow(icon: "key.fill",    label: lang.t("info_key"),
                    value: LicenseService.maskedKey(licenseInfo.key),
                    mono: true, color: FFTheme.textSecondary)
            rowSep
            infoRow(icon: "clock.fill",  label: lang.t("info_expired"),
                    value: countdown.isEmpty ? licenseInfo.expiresAt : countdown,
                    mono: true, color: expiryColor)
            rowSep
            infoRow(icon: "iphone",      label: lang.t("info_device"),
                    value: licenseInfo.iPhoneModel, mono: false, color: FFTheme.textSecondary)
            rowSep
            infoRow(icon: "apple.logo",  label: lang.t("info_ios"),
                    value: "iOS \(licenseInfo.iOSVersion)", mono: true, color: FFTheme.textSecondary)
        }
        .background(FFTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
        )
    }

    private func infoRow(icon: String, label: String, value: String, mono: Bool, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(FFTheme.textSecondary)
                .frame(width: 16)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(FFTheme.textSecondary)
                .tracking(0.7)
            Spacer()
            Text(value)
                .font(mono
                      ? .system(size: 12, weight: .bold, design: .monospaced)
                      : .system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }

    private var expiryColor: Color {
        guard let exp = licenseInfo.expiryDate else { return FFTheme.textSecondary }
        let r = exp.timeIntervalSince(Date())
        if r < 0      { return FFTheme.danger }
        if r < 86400  { return FFTheme.danger }
        if r < 259200 { return FFTheme.warn }
        return FFTheme.success
    }

    // MARK: - Telegram row

    private var telegramRow: some View {
        Button {
            if let url = URL(string: "https://t.me/ffexternal") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(FFTheme.textSecondary)
                Text(lang.t("telegram"))
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(FFTheme.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(FFTheme.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(FFTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                    .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - GAME Tab

    private var gameTab: some View {
        Group {
            if !cheatStatus.isOperational && !statusLoading {
                // Cheat offline / maintenance — lock GAME tab
                ZStack {
                    FFTheme.background.ignoresSafeArea()
                    VStack(spacing: 14) {
                        Image(systemName: cheatStatus.status.uppercased() == "OFFLINE"
                              ? "xmark.circle.fill" : "wrench.and.screwdriver.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(statusColor(cheatStatus.status))
                        Text(cheatStatus.status.uppercased() == "OFFLINE"
                             ? lang.t("cheat_offline_msg")
                             : lang.t("cheat_maintenance_msg"))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(FFTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
            } else {
                GameTabContent(
                    state: state,
                    exploitReady: state.exploitStatus.isSuccess
                )
            }
        }
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach([0, 1], id: \.self) { idx in
                let label = idx == 0 ? lang.t("tab_menu") : lang.t("tab_game")
                let icon  = idx == 0 ? "list.bullet.rectangle" : "gamecontroller.fill"
                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                        selectedTab = idx
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: selectedTab == idx ? .semibold : .regular))
                            .foregroundStyle(selectedTab == idx ? FFTheme.text : FFTheme.textTertiary)
                        Text(label)
                            .font(.system(size: 10, weight: selectedTab == idx ? .bold : .regular,
                                          design: .rounded))
                            .foregroundStyle(selectedTab == idx ? FFTheme.text : FFTheme.textTertiary)
                            .tracking(0.5)
                        Capsule()
                            .fill(selectedTab == idx ? FFTheme.text : Color.clear)
                            .frame(height: 2)
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            FFTheme.card
                .overlay(
                    Rectangle()
                        .fill(FFTheme.separator)
                        .frame(height: 0.6),
                    alignment: .top
                )
        )
    }

    // MARK: - Shared helpers

    private func cardSectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(FFTheme.textSecondary)
                .tracking(1.0)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var rowSep: some View {
        Rectangle().fill(FFTheme.separator).frame(height: 0.6)
            .padding(.leading, 16)
    }
}

// MARK: - Game Tab Content (2 game, swipe between them)

struct GameTabContent: View {
    @Environment(\.ffLanguage) private var lang
    @ObservedObject var state: FFAppState
    let exploitReady: Bool

    @State private var selectedGame: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            gameSelector
            TabView(selection: $selectedGame) {
                GameMenuView(
                    game: .freeFire,
                    aimInjected:  state.aimInjected(for: .freeFire),
                    holoInjected: state.holoInjected(for: .freeFire),
                    exploitReady: exploitReady
                ).tag(0)
                GameMenuView(
                    game: .freefireMax,
                    aimInjected:  state.aimInjected(for: .freefireMax),
                    holoInjected: state.holoInjected(for: .freefireMax),
                    exploitReady: exploitReady
                ).tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.32, dampingFraction: 0.85), value: selectedGame)
        }
    }

    private var gameSelector: some View {
        HStack(spacing: 0) {
            ForEach([FFGame.freeFire, FFGame.freefireMax].indices, id: \.self) { i in
                let game: FFGame = i == 0 ? .freeFire : .freefireMax
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.78)) {
                        selectedGame = i
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text(game.displayName)
                            .font(.system(size: 14,
                                          weight: selectedGame == i ? .bold : .regular,
                                          design: .rounded))
                            .foregroundStyle(selectedGame == i ? FFTheme.text : FFTheme.textSecondary)
                        Capsule()
                            .fill(selectedGame == i ? FFTheme.text : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
        }
        .background(FFTheme.card)
        .overlay(Rectangle().fill(FFTheme.separator).frame(height: 0.6), alignment: .bottom)
    }
}

// MARK: - Game Menu View

struct GameMenuView: View {
    @Environment(\.ffLanguage) private var lang
    let game:         FFGame
    @Binding var aimInjected:  Bool
    @Binding var holoInjected: Bool
    let exploitReady: Bool

    @State private var selectedFeature:      FFFeature = .aimBody
    @State private var injecting             = false
    @State private var showTerminal          = false
    @State private var terminalLines: [String] = []
    @State private var showSuccess           = false
    @State private var showRestoreSuccess    = false
    @State private var errorMessage: String? = nil
    @State private var availability: [FFFeature: Bool] = [:]
    @State private var checkingAvailability  = true

    private var isHoloSelected: Bool { selectedFeature == .hologram }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                featureGrid
                    .padding(.horizontal, 16)
                hintCard
                    .padding(.horizontal, 16)
                actionSection
                    .padding(.horizontal, 16)

                if let err = errorMessage {
                    Text(err)
                        .font(FFTheme.captionFont)
                        .foregroundStyle(FFTheme.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                }

                Spacer(minLength: 24)
            }
            .padding(.top, 16)
        }
        .overlay(
            Group {
                if showTerminal       { terminalOverlay }
                if showSuccess        { successOverlay(text: lang.t("inject_success"),  icon: "checkmark.seal.fill",              color: FFTheme.success) }
                if showRestoreSuccess { successOverlay(text: lang.t("restore_success"), icon: "arrow.uturn.backward.circle.fill", color: FFTheme.warn) }
            }
        )
        .animation(.easeInOut(duration: 0.22), value: errorMessage)
        .task { await checkAvailability() }
    }

    // MARK: - Feature Grid (3 columns)

    private var featureGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(FFFeature.allCases, id: \.self) { feature in
                FeatureCard(
                    feature: feature,
                    isSelected: selectedFeature == feature,
                    available: availability[feature] ?? true,
                    loading: checkingAvailability
                ) {
                    if availability[feature] ?? true {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.7)) {
                            selectedFeature = feature
                        }
                    }
                }
            }
        }
    }

    // MARK: - Hint Card

    private var hintCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(FFTheme.textSecondary)
                .font(.system(size: 13))
                .padding(.top, 1)
            Text(isHoloSelected
                 ? lang.t("inject_hint_holo")
                 : lang.t("inject_hint_aim"))
                .font(FFTheme.captionFont)
                .foregroundStyle(FFTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut(duration: 0.18), value: isHoloSelected)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FFTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
        )
    }

    // MARK: - Action Section
    // Aim dan Holo masing-masing ada inject/restore state sendiri

    private var actionSection: some View {
        Group {
            if isHoloSelected {
                // Hologram buttons
                if !holoInjected {
                    FFButton(
                        title: injecting ? lang.t("injecting") : lang.t("inject"),
                        icon: injecting ? nil : "cube.fill",
                        action: doInjectHolo,
                        isLoading: injecting,
                        isDisabled: injecting || !(availability[.hologram] ?? true)
                    )
                } else {
                    FFButton(
                        title: lang.t("restore"),
                        icon: "arrow.uturn.backward.circle.fill",
                        action: doRestoreHolo,
                        isDisabled: injecting,
                        style: .secondary
                    )
                }
            } else {
                // Aim buttons
                if !aimInjected {
                    FFButton(
                        title: injecting ? lang.t("injecting") : lang.t("inject"),
                        icon: injecting ? nil : "bolt.fill",
                        action: doInjectAim,
                        isLoading: injecting,
                        isDisabled: injecting || !(availability[selectedFeature] ?? true)
                    )
                } else {
                    FFButton(
                        title: lang.t("restore"),
                        icon: "arrow.uturn.backward.circle.fill",
                        action: doRestoreAim,
                        isDisabled: injecting,
                        style: .secondary
                    )
                }
            }
        }
    }

    // MARK: - Terminal Overlay

    private var terminalOverlay: some View {
        ZStack {
            Color.black.opacity(0.82).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 1, green: 0.37, blue: 0.33)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 1, green: 0.73, blue: 0.18)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 0.15, green: 0.78, blue: 0.40)).frame(width: 10, height: 10)
                    Spacer()
                    Text("FF External — Inject")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.05))

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(terminalLines.indices, id: \.self) { i in
                            Text(terminalLines[i])
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundStyle(lineColor(terminalLines[i]))
                        }
                        Text("█")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 180)
                .background(Color.black.opacity(0.9))
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(FFTheme.glassBorder, lineWidth: 0.8)
            )
            .padding(.horizontal, 28)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private func lineColor(_ line: String) -> Color {
        if line.contains("Success") || line.contains("OK")     { return FFTheme.success }
        if line.contains("Error")   || line.contains("FAIL")   { return FFTheme.danger }
        if line.contains("Inject")  || line.contains("Exploit") { return FFTheme.accentAlt }
        return .white.opacity(0.70)
    }

    private func successOverlay(text: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(FFTheme.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FFTheme.background.opacity(0.90).ignoresSafeArea())
        .transition(.opacity)
    }

    // MARK: - Actions

    private func doInjectAim() {
        let feature = selectedFeature
        runInject(label: feature.displayName) {
            try await FFCheatService.inject(game: game, feature: feature)
        } onSuccess: {
            aimInjected = true
        }
    }

    private func doInjectHolo() {
        runInject(label: "Hologram") {
            try await FFCheatService.inject(game: game, feature: .hologram)
        } onSuccess: {
            holoInjected = true
        }
    }

    private func runInject(label: String, op: @escaping () async throws -> Void, onSuccess: @escaping () -> Void) {
        terminalLines = []
        errorMessage  = nil
        withAnimation { showTerminal = true }

        func line(_ s: String) { DispatchQueue.main.async { terminalLines.append(s) } }

        Task {
            line("Exploiting \(game.displayName)")
            try? await Task.sleep(for: .milliseconds(400))
            line("Injecting \(label)")
            try? await Task.sleep(for: .milliseconds(500))
            do {
                try await op()
                line("Success inject \(label)")
                try? await Task.sleep(for: .milliseconds(600))
                await MainActor.run {
                    withAnimation { showTerminal = false }
                    onSuccess()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation { showSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { showSuccess = false }
                        }
                    }
                }
            } catch {
                line("Error: \(error.localizedDescription)")
                try? await Task.sleep(for: .milliseconds(1500))
                await MainActor.run {
                    withAnimation { showTerminal = false }
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func doRestoreAim() {
        errorMessage = nil
        injecting    = true
        Task {
            do {
                try FFCheatService.restoreAim(game: game)
                await MainActor.run {
                    injecting    = false
                    aimInjected  = false
                    withAnimation { showRestoreSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation { showRestoreSuccess = false }
                    }
                }
            } catch {
                await MainActor.run { injecting = false; errorMessage = error.localizedDescription }
            }
        }
    }

    private func doRestoreHolo() {
        errorMessage = nil
        injecting    = true
        Task {
            do {
                try FFCheatService.restoreHolo(game: game)
                await MainActor.run {
                    injecting     = false
                    holoInjected  = false
                    withAnimation { showRestoreSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation { showRestoreSuccess = false }
                    }
                }
            } catch {
                await MainActor.run { injecting = false; errorMessage = error.localizedDescription }
            }
        }
    }

    private func checkAvailability() async {
        checkingAvailability = true
        var result: [FFFeature: Bool] = [:]
        await withTaskGroup(of: (FFFeature, Bool).self) { group in
            for feature in FFFeature.allCases {
                group.addTask {
                    let ok = await FFCheatManifest.checkAvailability(feature: feature, game: self.game)
                    return (feature, ok)
                }
            }
            for await (f, ok) in group { result[f] = ok }
        }
        await MainActor.run { availability = result; checkingAvailability = false }
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let feature:    FFFeature
    let isSelected: Bool
    let available:  Bool
    let loading:    Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.15) : FFTheme.cardElevated)
                        .frame(width: 44, height: 44)
                    if loading {
                        ProgressView().controlSize(.mini).tint(FFTheme.textSecondary)
                    } else {
                        Image(systemName: featureIcon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(
                                !available  ? FFTheme.textTertiary :
                                isSelected  ? FFTheme.text         : FFTheme.textSecondary
                            )
                    }
                }

                Text(feature.displayName)
                    .font(.system(size: 11,
                                  weight: isSelected ? .bold : .regular,
                                  design: .rounded))
                    .foregroundStyle(
                        !available  ? FFTheme.textTertiary :
                        isSelected  ? FFTheme.text         : FFTheme.textSecondary
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if !available && !loading {
                    Text("N/A")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(FFTheme.danger)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.10) : FFTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color.white.opacity(0.35) : FFTheme.glassBorder,
                                lineWidth: isSelected ? 1.2 : 0.8
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
            .opacity((!available && !loading) ? 0.45 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isSelected)
    }

    private var featureIcon: String {
        switch feature {
        case .aimBody:     return "figure.stand"
        case .aimNeck:     return "scope"
        case .aimChest:    return "target"
        case .aimDrag:     return "cursorarrow.motionlines"
        case .magicBullet: return "burst.fill"
        case .hologram:    return "cube.transparent.fill"
        }
    }
}
