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
    // "https://api.github.com/repos/mkiw1464-debug/all/contents"
    private static let _apiBase: [UInt8] = [
        0x32, 0x2e, 0x2e, 0x2a, 0x29, 0x60, 0x75, 0x75, 0x3b, 0x2a, 0x33,
        0x74, 0x3d, 0x33, 0x2e, 0x32, 0x2f, 0x38, 0x74, 0x39, 0x35, 0x37,
        0x75, 0x28, 0x3f, 0x2a, 0x35, 0x29, 0x75, 0x37, 0x31, 0x33, 0x2d,
        0x6b, 0x6e, 0x6c, 0x6e, 0x77, 0x3e, 0x3f, 0x38, 0x2f, 0x3d, 0x75,
        0x3b, 0x36, 0x36, 0x75, 0x39, 0x35, 0x34, 0x2e, 0x3f, 0x34, 0x2e,
        0x29
    ]

    // "https://api.github.com/repos/mkiw1464-debug/all/git/trees/main?recursive=1"
    private static let _treesAPI: [UInt8] = [
        0x32, 0x2e, 0x2e, 0x2a, 0x29, 0x60, 0x75, 0x75, 0x3b, 0x2a, 0x33,
        0x74, 0x3d, 0x33, 0x2e, 0x32, 0x2f, 0x38, 0x74, 0x39, 0x35, 0x37,
        0x75, 0x28, 0x3f, 0x2a, 0x35, 0x29, 0x75, 0x37, 0x31, 0x33, 0x2d,
        0x6b, 0x6e, 0x6c, 0x6e, 0x77, 0x3e, 0x3f, 0x38, 0x2f, 0x3d, 0x75,
        0x3b, 0x36, 0x36, 0x75, 0x3d, 0x33, 0x2e, 0x75, 0x2e, 0x28, 0x3f,
        0x3f, 0x29, 0x75, 0x37, 0x3b, 0x33, 0x34, 0x65, 0x28, 0x3f, 0x39,
        0x2f, 0x28, 0x29, 0x33, 0x2c, 0x3f, 0x67, 0x6b
    ]

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

    static var apiBase:    String { _X.d(_apiBase) }
    static var rawBase:    String { _X.d(_rawBase) }
    static var statusFile: String { _X.d(_statusFile) }
    static var treesAPI:   String { _X.d(_treesAPI) }

    // MARK: - Repo path builders

    // Aim: AIM/{folderName}/   (same file for FF and FFMAX)
    // Holo: Holo/FF/  atau  Holo/FFMAX/
    static func repoPath(feature: FFFeature, game: FFGame) -> String {
        switch feature {
        case .aimBody, .aimNeck, .aimChest, .aimDrag, .magicBullet:
            return "AIM/\(feature.folderName)"
        case .hologram:
            let sub = game == .freeFire ? "FF" : "FFMAX"
            return "Holo/\(sub)"
        }
    }

    // MARK: - In-session file name cache

    private static var _nameCache: [String: String] = [:]
    private static let _lock = NSLock()

    private static func cacheKey(feature: FFFeature, game: FFGame) -> String {
        "\(feature.rawValue)_\(game.rawValue)"
    }

    // MARK: - Auto-detect filename (Git Trees API)
    // Guna Trees API bukan Contents API — Contents API 403 pada file > 1MB.
    // Trees API return semua path dalam repo tanpa size limit.

    private static var _treeCache: [String]? = nil   // semua blob paths dari repo

    private static func fetchTree() async throws -> [String] {
        _lock.lock()
        if let cached = _treeCache {
            _lock.unlock()
            return cached
        }
        _lock.unlock()

        guard let url = URL(string: treesAPI) else { throw FFCheatError.fileUnavailable }
        var req = URLRequest(url: url)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FFCheatError.fileUnavailable
        }

        struct GHTree:  Decodable { let tree: [GHNode] }
        struct GHNode:  Decodable { let path: String; let type: String }
        let tree = try JSONDecoder().decode(GHTree.self, from: data)
        let paths = tree.tree.filter { $0.type == "blob" }.map { $0.path }

        _lock.lock()
        _treeCache = paths
        _lock.unlock()

        return paths
    }

    static func resolveFileName(feature: FFFeature, game: FFGame) async throws -> String {
        let key = cacheKey(feature: feature, game: game)

        _lock.lock()
        if let cached = _nameCache[key] {
            _lock.unlock()
            return cached
        }
        _lock.unlock()

        let paths  = try await fetchTree()
        let folder = repoPath(feature: feature, game: game)   // e.g. "AIM/AimBody"
        let prefix = feature.filePrefix                        // "cache_res" or "shaders"

        // Cari path yang dalam folder betul DAN nama fail bermula dengan prefix
        guard let match = paths.first(where: { path in
            path.hasPrefix(folder + "/") &&
            (path as NSString).lastPathComponent.hasPrefix(prefix)
        }) else {
            throw FFCheatError.targetFileMissing
        }

        let fileName = (match as NSString).lastPathComponent

        _lock.lock()
        _nameCache[key] = fileName
        _lock.unlock()

        return fileName
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

    // MARK: - Availability check (HEAD only)

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

    // MARK: - Status JSON

    static var statusURL: URL? { URL(string: "\(rawBase)/\(statusFile)") }

    static func fetchStatus() async throws -> CheatStatus {
        guard let url = statusURL else { throw FFCheatError.fileUnavailable }
        var req = URLRequest(url: url)
        req.timeoutInterval = 10
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(CheatStatus.self, from: data)
    }
}

// MARK: - Cheat Status Model (untuk status card di MENU tab)

struct CheatStatus: Codable {
    var status:      String   // "ONLINE" / "OFFLINE" / "MAINTENANCE"
    var aimBody:     String
    var aimNeck:     String
    var aimChest:    String
    var aimDrag:     String
    var magicBullet: String
    var hologram:    String

    enum CodingKeys: String, CodingKey {
        case status
        case aimBody     = "aimBody"
        case aimNeck     = "aimNeck"
        case aimChest    = "aimChest"
        case aimDrag     = "aimDrag"
        case magicBullet = "magicBullet"
        case hologram    = "hologram"
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
        CheatStatus(status: "ONLINE", aimBody: "SAFE", aimNeck: "SAFE",
                    aimChest: "SAFE", aimDrag: "SAFE", magicBullet: "SAFE", hologram: "SAFE")
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
