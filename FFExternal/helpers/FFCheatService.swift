import Foundation

// MARK: - String Decryptor (shared key 0x5A)

private enum _X {
    static let k: UInt8 = 0x5A
    static func d(_ b: [UInt8]) -> String {
        String(bytes: b.map { $0 ^ k }, encoding: .utf8) ?? ""
    }
    static func e(_ s: String) -> [UInt8] {
        s.utf8.map { $0 ^ k }
    }
}

// MARK: - Constants

enum FFGame: String, CaseIterable {
    case freeFire    = "__ff"
    case freefireMax = "__ffmax"

    var bundleID: String {
        switch self {
        case .freeFire:
            // "com.dts.freefireth"
            return _X.d([0x39, 0x35, 0x37, 0x74, 0x3e, 0x2e, 0x29, 0x74,
                         0x3c, 0x28, 0x3f, 0x3f, 0x3c, 0x33, 0x28, 0x3f, 0x2e, 0x32])
        case .freefireMax:
            // "com.dts.freefiremax"
            return _X.d([0x39, 0x35, 0x37, 0x74, 0x3e, 0x2e, 0x29, 0x74,
                         0x3c, 0x28, 0x3f, 0x3f, 0x3c, 0x33, 0x28, 0x3f, 0x37, 0x3b, 0x22])
        }
    }

    var displayName: String {
        switch self {
        case .freeFire:    return "Free Fire"
        case .freefireMax: return "Free Fire Max"
        }
    }
}

// MARK: - Feature

enum FFFeature: String, CaseIterable {
    case aimBody     = "AimBody"
    case aimNeck     = "AimNeck"
    case aimChest    = "AimChest"
    case aimDrag     = "AimDrag"
    case magicBullet = "MagicBullet"
    case hologram    = "Hologram"

    var folderName: String {
        switch self {
        case .aimBody:     return "AimBody"
        case .aimNeck:     return "AimNeck"
        case .aimChest:    return "AimChest"
        case .aimDrag:     return "AimDrag"
        case .magicBullet: return "MagicBullet"
        case .hologram:    return "Hologram"
        }
    }

    var displayName: String {
        switch self {
        case .aimBody:     return "AimBody"
        case .aimNeck:     return "AimNeck"
        case .aimChest:    return "AimChest"
        case .aimDrag:     return "AimDrag"
        case .magicBullet: return "Magic Bullet"
        case .hologram:    return "Hologram"
        }
    }

    /// Aim features inject di lobby. Hologram inject sebelum masuk game.
    var isHologram: Bool { self == .hologram }
    var isAim: Bool { !isHologram }

    // Target file prefix untuk auto-detect
    var filePrefix: String {
        switch self {
        case .aimBody, .aimNeck, .aimChest, .aimDrag, .magicBullet:
            // "cache_res"
            return _X.d([0x39, 0x3b, 0x39, 0x32, 0x3f, 0x05, 0x28, 0x3f, 0x29])
        case .hologram:
            // "shaders"
            return _X.d([0x29, 0x32, 0x3b, 0x3e, 0x3f, 0x28, 0x29])
        }
    }
}

// MARK: - GitHub Manifest

enum FFCheatManifest {
    // "https://raw.githubusercontent.com/mkiw1464-debug/all/main"
    private static let _rawBase: [UInt8] = [
        0x32, 0x2e, 0x2e, 0x2a, 0x29, 0x60, 0x75, 0x75, 0x28, 0x3b, 0x2d,
        0x74, 0x3d, 0x33, 0x2e, 0x32, 0x2f, 0x38, 0x2f, 0x29, 0x3f, 0x28,
        0x39, 0x35, 0x34, 0x2e, 0x3f, 0x34, 0x2e, 0x74, 0x39, 0x35, 0x37,
        0x75, 0x37, 0x31, 0x33, 0x2d, 0x6b, 0x6e, 0x6c, 0x6e, 0x77, 0x3e,
        0x3f, 0x38, 0x2f, 0x75, 0x3b, 0x36, 0x36, 0x75, 0x37, 0x3b, 0x33,
        0x34
    ]

    // "status.json"
    private static let _statusFile: [UInt8] = [
        0x29, 0x2e, 0x3b, 0x2e, 0x2f, 0x29, 0x74, 0x30, 0x29, 0x35, 0x34
    ]

    static var rawBase:    String { _X.d(_rawBase) }
    static var statusFile: String { _X.d(_statusFile) }

    // MARK: - Repo path builders

    static func repoPath(feature: FFFeature, game: FFGame) -> String {
        switch feature {
        case .aimBody, .aimNeck, .aimChest, .aimDrag, .magicBullet:
            return "AIM/\(feature.folderName)"
        case .hologram:
            return game == .freeFire ? "Holo/FF" : "Holo/FFMAX"
        }
    }

    // MARK: - Status JSON
    // status.json menyimpan nama file semasa OB — update bila OB tukar nama file.

    static var statusURL: URL? { URL(string: "\(rawBase)/\(statusFile)") }

    // Status cached dalam session
    private static var _statusCache: CheatStatus? = nil
    private static let _lock = NSLock()

    static func fetchStatus() async throws -> CheatStatus {
        guard let url = statusURL else { throw FFCheatError.fileUnavailable }
        var req = URLRequest(url: url)
        req.timeoutInterval = 10
        // Cache-bust: pastikan dapat versi terkini
        req.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, _) = try await URLSession.shared.data(for: req)
        let status = try JSONDecoder().decode(CheatStatus.self, from: data)
        _lock.lock()
        _statusCache = status
        _lock.unlock()
        return status
    }

    static func cachedStatus() -> CheatStatus? {
        _lock.lock()
        defer { _lock.unlock() }
        return _statusCache
    }

    // MARK: - Resolve filename dari status.json

    static func resolveFileName(feature: FFFeature, game: FFGame) async throws -> String {
        // Ambil status — cached kalau ada
        let status: CheatStatus
        if let cached = cachedStatus() {
            status = cached
        } else {
            status = try await fetchStatus()
        }
        switch feature {
        case .aimBody, .aimNeck, .aimChest, .aimDrag, .magicBullet:
            guard !status.cacheResName.isEmpty else { throw FFCheatError.targetFileMissing }
            return status.cacheResName
        case .hologram:
            let name = game == .freeFire ? status.shadersFFName : status.shadersFFMAXName
            guard !name.isEmpty else { throw FFCheatError.targetFileMissing }
            return name
        }
    }

    // MARK: - Download

    static func download(feature: FFFeature, game: FFGame) async throws -> (data: Data, fileName: String) {
        let name = try await resolveFileName(feature: feature, game: game)
        let path = repoPath(feature: feature, game: game)
        guard let url = URL(string: "\(rawBase)/\(path)/\(name)") else {
            throw FFCheatError.fileUnavailable
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 60
        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FFCheatError.fileUnavailable
        }
        return (data, name)
    }

    // MARK: - Availability check

    static func checkAvailability(feature: FFFeature, game: FFGame) async -> Bool {
        do {
            let name = try await resolveFileName(feature: feature, game: game)
            let path = repoPath(feature: feature, game: game)
            guard let url = URL(string: "\(rawBase)/\(path)/\(name)") else { return false }
            var req = URLRequest(url: url)
            req.httpMethod = "HEAD"
            req.timeoutInterval = 8
            let (_, r) = try await URLSession.shared.data(for: req)
            return (r as? HTTPURLResponse)?.statusCode == 200
        } catch { return false }
    }
}

// MARK: - Cheat Status Model

struct CheatStatus: Codable {
    var status:          String   // "ONLINE" / "OFFLINE" / "MAINTENANCE"
    var aimBody:         String
    var aimNeck:         String
    var aimChest:        String
    var aimDrag:         String
    var magicBullet:     String
    var hologram:        String
    var cacheResName:    String   // nama fail cache_res semasa OB
    var shadersFFName:   String   // nama fail shaders FF
    var shadersFFMAXName: String  // nama fail shaders FFMAX

    enum CodingKeys: String, CodingKey {
        case status
        case aimBody          = "aimBody"
        case aimNeck          = "aimNeck"
        case aimChest         = "aimChest"
        case aimDrag          = "aimDrag"
        case magicBullet      = "magicBullet"
        case hologram         = "hologram"
        case cacheResName     = "cacheResName"
        case shadersFFName    = "shadersFFName"
        case shadersFFMAXName = "shadersFFMAXName"
    }

    var isOperational: Bool { status.uppercased() == "ONLINE" }

    func featureStatus(for feature: FFFeature) -> String {
        switch feature {
        case .aimBody:     return aimBody
        case .aimNeck:     return aimNeck
        case .aimChest:    return aimChest
        case .aimDrag:     return aimDrag
        case .magicBullet: return magicBullet
        case .hologram:    return hologram
        }
    }

    static var placeholder: CheatStatus {
        CheatStatus(
            status: "ONLINE", aimBody: "SAFE", aimNeck: "SAFE",
            aimChest: "SAFE", aimDrag: "SAFE", magicBullet: "SAFE", hologram: "SAFE",
            cacheResName: "", shadersFFName: "", shadersFFMAXName: ""
        )
    }
}


// MARK: - Errors

enum FFCheatError: LocalizedError {
    case containerNotFound(String)
    case fileUnavailable
    case targetFileMissing
    case replacementFailed(String)
    case backupFailed
    case restoreFailed
    case noBackup

    var errorDescription: String? {
        switch self {
        case .containerNotFound(let id): return "App container not found: \(id)"
        case .fileUnavailable:           return "Cheat file unavailable — check GitHub"
        case .targetFileMissing:         return "Target game asset file not found"
        case .replacementFailed(let r):  return "File replacement failed: \(r)"
        case .backupFailed:              return "Failed to create backup"
        case .restoreFailed:             return "Failed to restore original file"
        case .noBackup:                  return "No backup found — inject first"
        }
    }
}

// MARK: - Backup helpers

private enum Backups {
    static var dir: String {
        let p = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? "/tmp")
            + "/ffext_backups"
        try? FileManager.default.createDirectory(atPath: p, withIntermediateDirectories: true)
        return p
    }

    // Aim backup: cache_res asal
    static func aimBackupURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_cache_res.bak")
    }

    // Holo backup: shaders asal
    static func holoBackupURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_shaders.bak")
    }

    // Track nama file yang di-inject (untuk restore ke path yang sama)
    static func aimFileNameURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_aim_fname.txt")
    }

    static func holoFileNameURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_holo_fname.txt")
    }
}

// MARK: - Inject / Restore Service

enum FFCheatService {

    // MARK: - Container asset paths

    /// Aim: Documents/contentcache/Compulsory/ios/gameassetbundles/{cache_res.*}
    static func aimAssetDir(containerPath: String) -> URL {
        URL(fileURLWithPath: containerPath)
            .appendingPathComponent("Documents/contentcache/Compulsory/ios/gameassetbundles")
    }

    /// Holo: Documents/contentcache/Optional/ios/gameassetbundles/{shaders.*}
    static func holoAssetDir(containerPath: String) -> URL {
        URL(fileURLWithPath: containerPath)
            .appendingPathComponent("Documents/contentcache/Optional/ios/gameassetbundles")
    }

    // MARK: - Has Backup

    static func hasAimBackup(bundleID: String) -> Bool {
        FileManager.default.fileExists(atPath: Backups.aimBackupURL(bundleID: bundleID).path)
    }

    static func hasHoloBackup(bundleID: String) -> Bool {
        FileManager.default.fileExists(atPath: Backups.holoBackupURL(bundleID: bundleID).path)
    }

    // MARK: - Inject (entry)

    static func inject(game: FFGame, feature: FFFeature) async throws {
        let bundleID = game.bundleID
        guard let containerPath = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
            throw FFCheatError.containerNotFound(bundleID)
        }
        let handle = ContainerStore.grantContainerAccess(containerPath)
        defer { if handle >= 0 { bad_query_release(handle) } }

        if feature.isHologram {
            try await injectHolo(game: game, bundleID: bundleID, containerPath: containerPath)
        } else {
            try await injectAim(game: game, feature: feature, bundleID: bundleID, containerPath: containerPath)
        }
    }

    // MARK: - Aim inject — auto-detect cache_res.* dalam folder, replace

    private static func injectAim(
        game: FFGame,
        feature: FFFeature,
        bundleID: String,
        containerPath: String
    ) async throws {
        let fm = FileManager.default
        let assetDir = aimAssetDir(containerPath: containerPath)

        // Auto-detect fail cache_res.* dalam folder
        guard fm.fileExists(atPath: assetDir.path) else {
            throw FFCheatError.targetFileMissing
        }
        let contents = (try? fm.contentsOfDirectory(atPath: assetDir.path)) ?? []
        let prefix = FFFeature.aimBody.filePrefix   // "cache_res"
        guard let existingName = contents.first(where: { $0.hasPrefix(prefix) }) else {
            throw FFCheatError.targetFileMissing
        }
        let target = assetDir.appendingPathComponent(existingName)

        // Backup
        let backup = Backups.aimBackupURL(bundleID: bundleID)
        if !fm.fileExists(atPath: backup.path) {
            do { try fm.copyItem(at: target, to: backup) }
            catch { throw FFCheatError.backupFailed }
            // Simpan nama fail asal untuk restore
            try? existingName.write(to: Backups.aimFileNameURL(bundleID: bundleID),
                                    atomically: true, encoding: .utf8)
        }

        // Download dari repo — auto-detect nama file cheat (boleh berbeza nama OB)
        let (data, _) = try await FFCheatManifest.download(feature: feature, game: game)

        // Replace atomically — guna nama fail asal (supaya game detect betul)
        let tmp = assetDir.appendingPathComponent(".\(UUID().uuidString)")
        guard fm.createFile(atPath: tmp.path, contents: data) else {
            throw FFCheatError.replacementFailed("createFile failed")
        }
        guard rename(tmp.path, target.path) == 0 else {
            try? fm.removeItem(at: tmp)
            throw FFCheatError.replacementFailed("rename errno=\(errno)")
        }
        log("aim inject OK \(bundleID) \(feature.rawValue) → \(existingName)")
    }

    // MARK: - Holo inject — auto-detect shaders.* dalam folder, replace

    private static func injectHolo(
        game: FFGame,
        bundleID: String,
        containerPath: String
    ) async throws {
        let fm = FileManager.default
        let assetDir = holoAssetDir(containerPath: containerPath)

        guard fm.fileExists(atPath: assetDir.path) else {
            throw FFCheatError.targetFileMissing
        }
        let contents = (try? fm.contentsOfDirectory(atPath: assetDir.path)) ?? []
        let prefix = FFFeature.hologram.filePrefix  // "shaders"
        guard let existingName = contents.first(where: { $0.hasPrefix(prefix) }) else {
            throw FFCheatError.targetFileMissing
        }
        let target = assetDir.appendingPathComponent(existingName)

        // Backup
        let backup = Backups.holoBackupURL(bundleID: bundleID)
        if !fm.fileExists(atPath: backup.path) {
            do { try fm.copyItem(at: target, to: backup) }
            catch { throw FFCheatError.backupFailed }
            try? existingName.write(to: Backups.holoFileNameURL(bundleID: bundleID),
                                    atomically: true, encoding: .utf8)
        }

        // Download
        let (data, _) = try await FFCheatManifest.download(feature: .hologram, game: game)

        let tmp = assetDir.appendingPathComponent(".\(UUID().uuidString)")
        guard fm.createFile(atPath: tmp.path, contents: data) else {
            throw FFCheatError.replacementFailed("createFile holo failed")
        }
        guard rename(tmp.path, target.path) == 0 else {
            try? fm.removeItem(at: tmp)
            throw FFCheatError.replacementFailed("rename holo errno=\(errno)")
        }
        log("holo inject OK \(bundleID) → \(existingName)")
    }

    // MARK: - Restore

    static func restoreAim(game: FFGame) throws {
        let bundleID = game.bundleID
        guard let containerPath = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
            throw FFCheatError.containerNotFound(bundleID)
        }
        let handle = ContainerStore.grantContainerAccess(containerPath)
        defer { if handle >= 0 { bad_query_release(handle) } }

        let fm = FileManager.default
        let backup = Backups.aimBackupURL(bundleID: bundleID)
        guard fm.fileExists(atPath: backup.path) else { throw FFCheatError.noBackup }

        let assetDir = aimAssetDir(containerPath: containerPath)
        // Gunakan nama fail yang disimpan semasa inject
        let storedName = (try? String(contentsOf: Backups.aimFileNameURL(bundleID: bundleID),
                                      encoding: .utf8)) ?? ""
        // Fallback: scan folder
        let target: URL
        if !storedName.isEmpty {
            target = assetDir.appendingPathComponent(storedName)
        } else {
            let prefix = FFFeature.aimBody.filePrefix
            let contents = (try? fm.contentsOfDirectory(atPath: assetDir.path)) ?? []
            let name = contents.first(where: { $0.hasPrefix(prefix) }) ?? ""
            target = assetDir.appendingPathComponent(name)
        }

        _ = try? FileReplacementService.replace(target: target, with: backup)
        try? fm.removeItem(at: backup)
        try? fm.removeItem(at: Backups.aimFileNameURL(bundleID: bundleID))
        log("aim restore OK \(bundleID)")
    }

    static func restoreHolo(game: FFGame) throws {
        let bundleID = game.bundleID
        guard let containerPath = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
            throw FFCheatError.containerNotFound(bundleID)
        }
        let handle = ContainerStore.grantContainerAccess(containerPath)
        defer { if handle >= 0 { bad_query_release(handle) } }

        let fm = FileManager.default
        let backup = Backups.holoBackupURL(bundleID: bundleID)
        guard fm.fileExists(atPath: backup.path) else { throw FFCheatError.noBackup }

        let assetDir = holoAssetDir(containerPath: containerPath)
        let storedName = (try? String(contentsOf: Backups.holoFileNameURL(bundleID: bundleID),
                                      encoding: .utf8)) ?? ""
        let target: URL
        if !storedName.isEmpty {
            target = assetDir.appendingPathComponent(storedName)
        } else {
            let prefix = FFFeature.hologram.filePrefix
            let contents = (try? fm.contentsOfDirectory(atPath: assetDir.path)) ?? []
            let name = contents.first(where: { $0.hasPrefix(prefix) }) ?? ""
            target = assetDir.appendingPathComponent(name)
        }

        _ = try? FileReplacementService.replace(target: target, with: backup)
        try? fm.removeItem(at: backup)
        try? fm.removeItem(at: Backups.holoFileNameURL(bundleID: bundleID))
        log("holo restore OK \(bundleID)")
    }
}
