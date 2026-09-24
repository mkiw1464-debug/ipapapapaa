import Foundation

// MARK: - String Decryptor (shared key 0x5A)

private enum _X {
    static let k: UInt8 = 0x5A
    static func d(_ b: [UInt8]) -> String {
        String(bytes: b.map { $0 ^ k }, encoding: .utf8) ?? ""
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

    var isHologram: Bool { self == .hologram }
    var isAim:      Bool { !isHologram }
}

// MARK: - GitHub Manifest
// Nama fail hardcode — tiada API call, tiada auto-detect.
// Bila OB tukar nama: update _cacheResName atau _shadersName dan rebuild.

enum FFCheatManifest {

    // "https://raw.githubusercontent.com/mkiw1464-debug/all/main"
    private static let _rawBase: [UInt8] = [
        0x32, 0x2e, 0x2e, 0x2a, 0x29, 0x60, 0x75, 0x75, 0x28, 0x3b, 0x2d, 0x74,
        0x3d, 0x33, 0x2e, 0x32, 0x2f, 0x38, 0x2f, 0x29, 0x3f, 0x28, 0x39, 0x35,
        0x34, 0x2e, 0x3f, 0x34, 0x2e, 0x74, 0x39, 0x35, 0x37, 0x75, 0x37, 0x31,
        0x33, 0x2d, 0x6b, 0x6e, 0x6c, 0x6e, 0x77, 0x3e, 0x3f, 0x38, 0x2f, 0x3d,
        0x75, 0x3b, 0x36, 0x36, 0x75, 0x37, 0x3b, 0x33, 0x34,
    ]

    // "cache_res.GkLlYqzsX4AtTdE55sDMRh9sJOI~3D"
    private static let _cacheResName: [UInt8] = [
        0x39, 0x3b, 0x39, 0x32, 0x3f, 0x05, 0x28, 0x3f, 0x29, 0x74, 0x1d, 0x31,
        0x16, 0x36, 0x03, 0x2b, 0x20, 0x29, 0x02, 0x6e, 0x1b, 0x2e, 0x0e, 0x3e,
        0x1f, 0x6f, 0x6f, 0x29, 0x1e, 0x17, 0x08, 0x32, 0x63, 0x29, 0x10, 0x15,
        0x13, 0x24, 0x69, 0x1e,
    ]

    // "shaders.P0K3UG2TfecMBhWMMV~2Fu8ReudIk~3D"  ← FF
    private static let _shadersFF: [UInt8] = [
        0x29, 0x32, 0x3b, 0x3e, 0x3f, 0x28, 0x29, 0x74, 0x0a, 0x6a, 0x11, 0x69,
        0x0f, 0x1d, 0x68, 0x0e, 0x3c, 0x3f, 0x39, 0x17, 0x18, 0x32, 0x0d, 0x17,
        0x17, 0x0c, 0x24, 0x68, 0x1c, 0x2f, 0x62, 0x08, 0x3f, 0x2f, 0x3e, 0x13,
        0x31, 0x24, 0x69, 0x1e,
    ]

    // "shaders.HPt9DZviTSXL9hpGW9QNOMigNLA~3D"  ← FFMAX
    private static let _shadersFFMAX: [UInt8] = [
        0x29, 0x32, 0x3b, 0x3e, 0x3f, 0x28, 0x29, 0x74, 0x12, 0x0a, 0x2e, 0x63,
        0x1e, 0x00, 0x2c, 0x33, 0x0e, 0x09, 0x02, 0x16, 0x63, 0x32, 0x2a, 0x1d,
        0x0d, 0x63, 0x0b, 0x14, 0x15, 0x17, 0x33, 0x3d, 0x14, 0x16, 0x1b,
        0x24, 0x69, 0x1e,
    ]

    // "status.json"
    private static let _statusFile: [UInt8] = [
        0x29, 0x2e, 0x3b, 0x2e, 0x2f, 0x29, 0x74, 0x30, 0x29, 0x35, 0x34,
    ]

    // Folder paths
    private static let _pAimBody:   [UInt8] = [0x1b, 0x13, 0x17, 0x75, 0x1b, 0x33, 0x37, 0x18, 0x35, 0x3e, 0x23]
    private static let _pAimNeck:   [UInt8] = [0x1b, 0x13, 0x17, 0x75, 0x1b, 0x33, 0x37, 0x14, 0x3f, 0x39, 0x31]
    private static let _pAimChest:  [UInt8] = [0x1b, 0x13, 0x17, 0x75, 0x1b, 0x33, 0x37, 0x19, 0x32, 0x3f, 0x29, 0x2e]
    private static let _pAimDrag:   [UInt8] = [0x1b, 0x13, 0x17, 0x75, 0x1b, 0x33, 0x37, 0x1e, 0x28, 0x3b, 0x3d]
    private static let _pMagic:     [UInt8] = [0x1b, 0x13, 0x17, 0x75, 0x17, 0x3b, 0x3d, 0x33, 0x39, 0x18, 0x2f, 0x36, 0x36, 0x3f, 0x2e]
    private static let _pHoloFF:    [UInt8] = [0x12, 0x35, 0x36, 0x35, 0x75, 0x1c, 0x1c]
    private static let _pHoloFFMAX: [UInt8] = [0x12, 0x35, 0x36, 0x35, 0x75, 0x1c, 0x1c, 0x17, 0x1b, 0x02]

    static var rawBase:      String { _X.d(_rawBase) }
    static var cacheResName: String { _X.d(_cacheResName) }
    static var statusFile:   String { _X.d(_statusFile) }

    static func shadersName(for game: FFGame) -> String {
        game == .freeFire ? _X.d(_shadersFF) : _X.d(_shadersFFMAX)
    }

    static func repoFolder(feature: FFFeature, game: FFGame) -> String {
        switch feature {
        case .aimBody:     return _X.d(_pAimBody)
        case .aimNeck:     return _X.d(_pAimNeck)
        case .aimChest:    return _X.d(_pAimChest)
        case .aimDrag:     return _X.d(_pAimDrag)
        case .magicBullet: return _X.d(_pMagic)
        case .hologram:    return game == .freeFire ? _X.d(_pHoloFF) : _X.d(_pHoloFFMAX)
        }
    }

    static func fileName(for feature: FFFeature, game: FFGame) -> String {
        feature.isHologram ? shadersName(for: game) : cacheResName
    }

    static func rawURL(feature: FFFeature, game: FFGame) -> URL? {
        let folder = repoFolder(feature: feature, game: game)
        let name   = fileName(for: feature, game: game)
        return URL(string: "\(rawBase)/\(folder)/\(name)")
    }

    // MARK: - Download

    static func download(feature: FFFeature, game: FFGame) async throws -> Data {
        guard let url = rawURL(feature: feature, game: game) else {
            throw FFCheatError.fileUnavailable
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 60
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw FFCheatError.fileUnavailable
        }
        return data
    }

    // MARK: - Availability check

    static func checkAvailability(feature: FFFeature, game: FFGame) async -> Bool {
        guard let url = rawURL(feature: feature, game: game) else { return false }
        var req = URLRequest(url: url)
        req.httpMethod = "HEAD"
        req.timeoutInterval = 8
        do {
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
        req.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let (data, _) = try await URLSession.shared.data(for: req)
        return try JSONDecoder().decode(CheatStatus.self, from: data)
    }
}

// MARK: - Cheat Status Model

struct CheatStatus: Codable {
    var status:      String
    var aimBody:     String
    var aimNeck:     String
    var aimChest:    String
    var aimDrag:     String
    var magicBullet: String
    var hologram:    String

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

    static func aimBackupURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_cache_res.bak")
    }

    static func holoBackupURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_shaders.bak")
    }

    static func aimFileNameURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_aim_fname.txt")
    }

    static func holoFileNameURL(bundleID: String) -> URL {
        URL(fileURLWithPath: dir).appendingPathComponent("\(bundleID)_holo_fname.txt")
    }
}

// MARK: - Inject / Restore Service

enum FFCheatService {

    static func aimAssetDir(containerPath: String) -> URL {
        URL(fileURLWithPath: containerPath)
            .appendingPathComponent("Documents/contentcache/Compulsory/ios/gameassetbundles")
    }

    static func holoAssetDir(containerPath: String) -> URL {
        URL(fileURLWithPath: containerPath)
            .appendingPathComponent("Documents/contentcache/Optional/ios/gameassetbundles")
    }

    static func hasAimBackup(bundleID: String) -> Bool {
        FileManager.default.fileExists(atPath: Backups.aimBackupURL(bundleID: bundleID).path)
    }

    static func hasHoloBackup(bundleID: String) -> Bool {
        FileManager.default.fileExists(atPath: Backups.holoBackupURL(bundleID: bundleID).path)
    }

    // MARK: - Inject

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

    private static func injectAim(
        game: FFGame, feature: FFFeature,
        bundleID: String, containerPath: String
    ) async throws {
        let fm       = FileManager.default
        let assetDir = aimAssetDir(containerPath: containerPath)
        let fileName = FFCheatManifest.cacheResName
        let target   = assetDir.appendingPathComponent(fileName)

        guard fm.fileExists(atPath: target.path) else { throw FFCheatError.targetFileMissing }

        let backup = Backups.aimBackupURL(bundleID: bundleID)
        if !fm.fileExists(atPath: backup.path) {
            do { try fm.copyItem(at: target, to: backup) }
            catch { throw FFCheatError.backupFailed }
            try? fileName.write(to: Backups.aimFileNameURL(bundleID: bundleID),
                                atomically: true, encoding: .utf8)
        }

        let data = try await FFCheatManifest.download(feature: feature, game: game)
        let tmp  = assetDir.appendingPathComponent(".\(UUID().uuidString)")
        guard fm.createFile(atPath: tmp.path, contents: data) else {
            throw FFCheatError.replacementFailed("createFile failed")
        }
        guard rename(tmp.path, target.path) == 0 else {
            try? fm.removeItem(at: tmp)
            throw FFCheatError.replacementFailed("rename errno=\(errno)")
        }
        log("aim inject OK \(bundleID) \(feature.rawValue)")
    }

    private static func injectHolo(
        game: FFGame, bundleID: String, containerPath: String
    ) async throws {
        let fm       = FileManager.default
        let assetDir = holoAssetDir(containerPath: containerPath)
        let fileName = FFCheatManifest.shadersName(for: game)
        let target   = assetDir.appendingPathComponent(fileName)

        guard fm.fileExists(atPath: target.path) else { throw FFCheatError.targetFileMissing }

        let backup = Backups.holoBackupURL(bundleID: bundleID)
        if !fm.fileExists(atPath: backup.path) {
            do { try fm.copyItem(at: target, to: backup) }
            catch { throw FFCheatError.backupFailed }
            try? fileName.write(to: Backups.holoFileNameURL(bundleID: bundleID),
                                atomically: true, encoding: .utf8)
        }

        let data = try await FFCheatManifest.download(feature: .hologram, game: game)
        let tmp  = assetDir.appendingPathComponent(".\(UUID().uuidString)")
        guard fm.createFile(atPath: tmp.path, contents: data) else {
            throw FFCheatError.replacementFailed("createFile holo failed")
        }
        guard rename(tmp.path, target.path) == 0 else {
            try? fm.removeItem(at: tmp)
            throw FFCheatError.replacementFailed("rename holo errno=\(errno)")
        }
        log("holo inject OK \(bundleID)")
    }

    // MARK: - Restore

    static func restoreAim(game: FFGame) throws {
        let bundleID = game.bundleID
        guard let containerPath = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
            throw FFCheatError.containerNotFound(bundleID)
        }
        let handle = ContainerStore.grantContainerAccess(containerPath)
        defer { if handle >= 0 { bad_query_release(handle) } }

        let fm     = FileManager.default
        let backup = Backups.aimBackupURL(bundleID: bundleID)
        guard fm.fileExists(atPath: backup.path) else { throw FFCheatError.noBackup }

        let assetDir = aimAssetDir(containerPath: containerPath)
        let stored   = (try? String(contentsOf: Backups.aimFileNameURL(bundleID: bundleID),
                                    encoding: .utf8)) ?? FFCheatManifest.cacheResName
        let target   = assetDir.appendingPathComponent(stored)

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

        let fm     = FileManager.default
        let backup = Backups.holoBackupURL(bundleID: bundleID)
        guard fm.fileExists(atPath: backup.path) else { throw FFCheatError.noBackup }

        let assetDir = holoAssetDir(containerPath: containerPath)
        let stored   = (try? String(contentsOf: Backups.holoFileNameURL(bundleID: bundleID),
                                    encoding: .utf8)) ?? FFCheatManifest.shadersName(for: game)
        let target   = assetDir.appendingPathComponent(stored)

        _ = try? FileReplacementService.replace(target: target, with: backup)
        try? fm.removeItem(at: backup)
        try? fm.removeItem(at: Backups.holoFileNameURL(bundleID: bundleID))
        log("holo restore OK \(bundleID)")
    }
}
