import Foundation
import UIKit

// MARK: - String Decryptor (XOR key 0x5A)

private enum _X {
    static let k: UInt8 = 0x5A
    static func d(_ b: [UInt8]) -> String {
        String(bytes: b.map { $0 ^ k }, encoding: .utf8) ?? ""
    }
}

// MARK: - Response Models
// Manual JSON parsing — Codable string literals exposed in binary; parse via XOR keys instead.

struct LicenseInfo {
    let key:         String
    let expiresAt:   String    // display string
    let expiryDate:  Date?
    let deviceName:  String
    let hwid:        String    // raw UUID from server
    let iOSVersion:  String
    let iPhoneModel: String
}

// MARK: - HWID
// Kirim raw identifierForVendor UUID penuh ke server — sesuai dengan spec API.

enum DeviceID {
    // "ffex.hwid" — storage key untuk UUID lokal
    private static let _hk: [UInt8] = [0x3c, 0x3c, 0x3f, 0x22, 0x74, 0x32, 0x2d, 0x33, 0x3e]

    /// UUID penuh dari identifierForVendor — dihantar ke server AS-IS.
    static var hwid: String {
        let key = _X.d(_hk)
        if let stored = UserDefaults.standard.string(forKey: key) { return stored }
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(uuid, forKey: key)
        return uuid
    }

    static var deviceName: String { UIDevice.current.name }

    static var iPhoneModel: String {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return iPhoneModelName(from: String(cString: machine))
    }

    static var iOSVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    private static func iPhoneModelName(from identifier: String) -> String {
        let map: [String: String] = [
            "iPhone17,1": "iPhone 16 Pro Max",
            "iPhone17,2": "iPhone 16 Pro",
            "iPhone17,3": "iPhone 16 Plus",
            "iPhone17,4": "iPhone 16",
            "iPhone16,1": "iPhone 15 Pro Max",
            "iPhone16,2": "iPhone 15 Pro",
            "iPhone15,4": "iPhone 15 Plus",
            "iPhone15,5": "iPhone 15",
            "iPhone15,2": "iPhone 14 Pro Max",
            "iPhone15,3": "iPhone 14 Pro",
            "iPhone14,7": "iPhone 14 Plus",
            "iPhone14,8": "iPhone 14",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 Mini",
            "iPhone14,5": "iPhone 13",
            "iPhone13,1": "iPhone 12 Mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "arm64":      "Simulator",
            "x86_64":     "Simulator",
        ]
        return map[identifier] ?? identifier
    }
}

// MARK: - License Service

enum LicenseService {

    // MARK: - XOR-encrypted constants

    // "https://ffex-chi.vercel.app/api/licenses/validate"
    private static let _au: [UInt8] = [
        0x32, 0x2e, 0x2e, 0x2a, 0x29, 0x60, 0x75, 0x75,
        0x3c, 0x3c, 0x3f, 0x22, 0x77, 0x39, 0x32, 0x33,
        0x74, 0x2c, 0x3f, 0x28, 0x39, 0x3f, 0x36, 0x74,
        0x3b, 0x2a, 0x2a, 0x75, 0x3b, 0x2a, 0x33, 0x75,
        0x36, 0x33, 0x39, 0x3f, 0x34, 0x29, 0x3f, 0x29,
        0x75, 0x2c, 0x3b, 0x36, 0x33, 0x3e, 0x3b, 0x2e, 0x3f
    ]

    // "ffex.license.key"
    private static let _sk: [UInt8] = [
        0x3c, 0x3c, 0x3f, 0x22, 0x74, 0x36, 0x33, 0x39,
        0x3f, 0x34, 0x29, 0x3f, 0x74, 0x31, 0x3f, 0x23
    ]

    // "ffex.license.expiry"
    private static let _ek: [UInt8] = [
        0x3c, 0x3c, 0x3f, 0x22, 0x74, 0x36, 0x33, 0x39,
        0x3f, 0x34, 0x29, 0x3f, 0x74, 0x3f, 0x22, 0x2a,
        0x33, 0x28, 0x23
    ]

    // JSON field names — decoded at call site
    // "valid"
    private static let _fv: [UInt8]  = [0x2c, 0x3b, 0x36, 0x33, 0x3e]
    // "error"
    private static let _fe: [UInt8]  = [0x3f, 0x28, 0x28, 0x35, 0x28]
    // "expires_at"
    private static let _fex: [UInt8] = [0x3f, 0x22, 0x2a, 0x33, 0x28, 0x3f, 0x29, 0x05, 0x3b, 0x2e]
    // "hwid"
    private static let _fh: [UInt8]  = [0x32, 0x2d, 0x33, 0x3e]
    // "key"
    private static let _rk: [UInt8]  = [0x31, 0x3f, 0x23]
    // "Content-Type"
    private static let _ch: [UInt8]  = [
        0x19, 0x35, 0x34, 0x2e, 0x3f, 0x34, 0x2e, 0x77,
        0x0e, 0x23, 0x2a, 0x3f
    ]
    // "application/json"
    private static let _ct: [UInt8]  = [
        0x3b, 0x2a, 0x2a, 0x36, 0x33, 0x39, 0x3b, 0x2e,
        0x33, 0x35, 0x34, 0x75, 0x30, 0x29, 0x35, 0x34
    ]
    // "POST"
    private static let _pm: [UInt8]  = [0x0a, 0x15, 0x09, 0x0e]

    // Error strings dari API
    // "Key expired"
    private static let _eExpired: [UInt8]  = [0x11, 0x3f, 0x23, 0x7a, 0x3f, 0x22, 0x2a, 0x33, 0x28, 0x3f, 0x3e]
    // "Key banned"
    private static let _eBanned:  [UInt8]  = [0x11, 0x3f, 0x23, 0x7a, 0x38, 0x3b, 0x34, 0x34, 0x3f, 0x3e]
    // "HWID mismatch"
    private static let _eHwid:    [UInt8]  = [
        0x12, 0x0d, 0x13, 0x1e, 0x7a, 0x37, 0x33, 0x29,
        0x37, 0x3b, 0x2e, 0x39, 0x32
    ]
    // "Invalid key"
    private static let _eInvalid: [UInt8]  = [
        0x13, 0x34, 0x2c, 0x3b, 0x36, 0x33, 0x3e, 0x7a,
        0x31, 0x3f, 0x23
    ]

    // MARK: - Computed accessors

    static var apiURL:     URL    { URL(string: _X.d(_au))! }
    static var storageKey: String { _X.d(_sk) }
    static var expiryKey:  String { _X.d(_ek) }

    // MARK: - Validate (login)

    static func validate(key: String) async throws -> LicenseInfo {
        guard let url = URL(string: _X.d(_au)) else { throw LicenseError.networkError }

        var req = URLRequest(url: url)
        req.httpMethod = _X.d(_pm)                                          // "POST"
        req.setValue(_X.d(_ct), forHTTPHeaderField: _X.d(_ch))             // Content-Type: application/json
        req.timeoutInterval = 15

        // Build body — field names decoded at runtime
        let bodyDict: [String: Any] = [
            _X.d(_rk): key,                   // "key"
            _X.d(_fh): DeviceID.hwid           // "hwid" — raw UUID
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else { throw LicenseError.networkError }
        guard (200..<300).contains(http.statusCode)   else { throw LicenseError.serverError(http.statusCode) }

        // Parse response manually — field name strings decoded at runtime
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw LicenseError.networkError
        }

        let validKey  = _X.d(_fv)   // "valid"
        let errorKey  = _X.d(_fe)   // "error"
        let expKey    = _X.d(_fex)  // "expires_at"
        let hwidKey   = _X.d(_fh)   // "hwid"

        guard let isValid = json[validKey] as? Bool, isValid else {
            // Map server error string ke LicenseError
            let errStr = (json[errorKey] as? String) ?? ""
            throw mapError(errStr)
        }

        // HWID check — server returns bound HWID kalau ada
        if let serverHwid = json[hwidKey] as? String,
           !serverHwid.isEmpty,
           serverHwid.uppercased() != DeviceID.hwid.uppercased() {
            throw LicenseError.hwidMismatch
        }

        let expiresAtRaw    = (json[expKey] as? String) ?? ""
        let expiryDate      = parseISODate(expiresAtRaw)

        if let exp = expiryDate, exp < Date() { throw LicenseError.expired }

        let formattedExpiry = expiryDate.map { formatDate($0) } ?? expiresAtRaw

        let info = LicenseInfo(
            key:         key,
            expiresAt:   formattedExpiry,
            expiryDate:  expiryDate,
            deviceName:  DeviceID.deviceName,
            hwid:        DeviceID.hwid,
            iOSVersion:  DeviceID.iOSVersion,
            iPhoneModel: DeviceID.iPhoneModel
        )
        store(key: key, expiryRaw: expiresAtRaw)
        return info
    }

    // MARK: - Map server error string → LicenseError

    private static func mapError(_ s: String) -> LicenseError {
        // Compare decoded strings supaya literal "Key expired" etc. tak ada dalam binary
        if s == _X.d(_eExpired) { return .expired }
        if s == _X.d(_eBanned)  { return .banned }
        if s == _X.d(_eHwid)    { return .hwidMismatch }
        if s == _X.d(_eInvalid) { return .invalidKey }
        return .invalidKey
    }

    // MARK: - Auto-session restore (server validation)

    static func restoreSession() async -> LicenseInfo? {
        guard let key = storedKey() else { return nil }

        // Fast local expiry check
        if let expRaw  = UserDefaults.standard.string(forKey: expiryKey),
           let expDate = parseISODate(expRaw), expDate < Date() {
            logout(); return nil
        }

        // Server re-validation — tangkap ban, delete, expire sebenar
        do {
            return try await validate(key: key)
        } catch {
            logout(); return nil
        }
    }

    // Synchronous local-only restore — untuk fast UI bootstrap sebelum server check
    static func restoreSessionLocal() -> LicenseInfo? {
        guard let key    = storedKey(),
              let expRaw = UserDefaults.standard.string(forKey: expiryKey) else { return nil }
        let expiryDate = parseISODate(expRaw)
        if let exp = expiryDate, exp < Date() { logout(); return nil }
        return LicenseInfo(
            key:         key,
            expiresAt:   expiryDate.map { formatDate($0) } ?? expRaw,
            expiryDate:  expiryDate,
            deviceName:  DeviceID.deviceName,
            hwid:        DeviceID.hwid,
            iOSVersion:  DeviceID.iOSVersion,
            iPhoneModel: DeviceID.iPhoneModel
        )
    }

    // MARK: - Periodic re-validation (setiap 60 saat dari MainMenuView)

    static func revalidateBackground(key: String) async -> Bool {
        do { _ = try await validate(key: key); return true }
        catch { return false }
    }

    // MARK: - Storage

    static func storedKey() -> String? {
        UserDefaults.standard.string(forKey: storageKey)
    }

    private static func store(key: String, expiryRaw: String) {
        UserDefaults.standard.set(key, forKey: storageKey)
        UserDefaults.standard.set(expiryRaw, forKey: expiryKey)
    }

    static func logout() {
        UserDefaults.standard.removeObject(forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: expiryKey)
    }

    // MARK: - Helpers

    private static func parseISODate(_ raw: String) -> Date? {
        let fmt1 = ISO8601DateFormatter()
        fmt1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = fmt1.date(from: raw) { return d }
        let fmt2 = ISO8601DateFormatter()
        fmt2.formatOptions = [.withInternetDateTime]
        return fmt2.date(from: raw)
    }

    private static func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }

    static func maskedKey(_ key: String) -> String {
        let parts = key.components(separatedBy: "-")
        guard parts.count >= 2 else {
            return String(repeating: "•", count: max(0, key.count - 4)) + String(key.suffix(4))
        }
        let last    = parts.last ?? ""
        let prefix  = parts.first ?? ""
        let midMask = Array(repeating: "••••", count: max(0, parts.count - 2))
        return ([prefix] + midMask + [last]).joined(separator: "-")
    }

    static func countdownString(from expiryDate: Date) -> String {
        let now  = Date()
        guard expiryDate > now else { return "Expired" }
        let diff    = expiryDate.timeIntervalSince(now)
        let days    = Int(diff) / 86400
        let hours   = (Int(diff) % 86400) / 3600
        let minutes = (Int(diff) % 3600) / 60
        if days > 0  { return "\(days)d \(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m \(Int(diff) % 60)s"
    }
}

// MARK: - Errors

enum LicenseError: LocalizedError {
    case invalidKey
    case networkError
    case serverError(Int)
    case hwidMismatch
    case expired
    case banned

    var errorDescription: String? {
        switch self {
        case .invalidKey:         return "Invalid key"
        case .networkError:       return "Network error — check your connection"
        case .serverError(let c): return "Server error (\(c))"
        case .hwidMismatch:       return "HWID mismatch"
        case .expired:            return "Key expired"
        case .banned:             return "Key banned"
        }
    }
}
