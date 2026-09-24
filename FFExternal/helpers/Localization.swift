import Foundation
import SwiftUI

// MARK: - Languages

enum FFLanguage: String, CaseIterable, Identifiable {
    static let storageKey = "ffLanguage"

    case english    = "en"
    case indonesian = "id"
    case brazilian  = "pt-BR"
    case arabic     = "ar"
    case taiwanese  = "zh-TW"
    case vietnamese = "vi"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:    return "English"
        case .indonesian: return "Indonesia"
        case .brazilian:  return "Português (BR)"
        case .arabic:     return "العربية"
        case .taiwanese:  return "繁體中文"
        case .vietnamese: return "Tiếng Việt"
        }
    }

    func t(_ key: String) -> String {
        strings[key] ?? key
    }

    private var strings: [String: String] {
        switch self {
        case .english:
            return [
                "select_language":        "Select Language",
                "continue":               "Continue",
                "login_title":            "FFEX IOS",
                "key_placeholder":        "FFEX-XXXXXXX",
                "validate":               "Validate",
                "validating":             "Validating...",
                "key_invalid":            "Invalid or expired key",
                "key_valid":              "Access granted",
                "key_label":              "License Key",
                "validate_btn":           "Validate",
                "device_not_supported":   "Your device version is not supported",
                "tab_menu":               "MENU",
                "tab_game":               "GAME",
                "header_title":           "FFEX IOS",
                "status_label":           "STATUS",
                "status_online":          "ONLINE",
                "status_offline":         "OFFLINE",
                "status_maintenance":     "MAINTENANCE",
                "info_key":               "KEY",
                "info_expired":           "EXPIRED",
                "info_device":            "DEVICE MODEL",
                "info_ios":               "IOS VERSION",
                "cheat_status_title":     "CHEAT STATUS",
                "info_card_title":        "KEY INFORMATION",
                "telegram":               "Join for Updates · t.me/ffexternal",
                "inject":                 "Inject",
                "restore":               "Restore",
                "injecting":              "Injecting...",
                "inject_success":         "Inject Successful",
                "restore_success":        "Files Restored",
                "inject_hint_aim":        "Inject while in lobby. Restore before going offline.",
                "inject_hint_holo":       "Inject before entering the match. Restore before going offline.",
                "unavailable":            "Unavailable",
                "logout":                 "Logout",
                "logout_confirm_title":   "Logout",
                "logout_confirm_msg":     "You will need to enter your key again.",
                "logout_confirm_yes":     "Logout",
                "logout_confirm_cancel":  "Cancel",
                "err_device_mismatch":    "Key is bound to another device",
                "err_expired":            "License key has expired",
                "already_injected":       "Injected",
                "cheat_offline_msg":      "Cheat is currently offline. Injection is disabled.",
                "cheat_maintenance_msg":  "Cheat is under maintenance. Injection is disabled.",
            ]

        case .indonesian:
            return [
                "select_language":        "Pilih Bahasa",
                "continue":               "Lanjutkan",
                "login_title":            "FFEX IOS",
                "key_placeholder":        "FFEX-XXXXXXX",
                "validate":               "Validasi",
                "validating":             "Memvalidasi...",
                "key_invalid":            "Kunci tidak valid atau kadaluarsa",
                "key_valid":              "Akses diberikan",
                "key_label":              "Kunci Lisensi",
                "validate_btn":           "Validasi",
                "device_not_supported":   "Versi perangkat Anda tidak didukung",
                "tab_menu":               "MENU",
                "tab_game":               "GAME",
                "header_title":           "FFEX IOS",
                "status_label":           "STATUS",
                "status_online":          "ONLINE",
                "status_offline":         "OFFLINE",
                "status_maintenance":     "MAINTENANCE",
                "info_key":               "KEY",
                "info_expired":           "EXPIRED",
                "info_device":            "MODEL PERANGKAT",
                "info_ios":               "VERSI IOS",
                "cheat_status_title":     "STATUS CHEAT",
                "info_card_title":        "INFORMASI KEY",
                "telegram":               "Gabung untuk Update · t.me/ffexternal",
                "inject":                 "Inject",
                "restore":                "Restore",
                "injecting":              "Menginjeksi...",
                "inject_success":         "Inject Berhasil",
                "restore_success":        "File Dipulihkan",
                "inject_hint_aim":        "Inject saat di lobby. Restore sebelum offline.",
                "inject_hint_holo":       "Inject sebelum masuk game. Restore sebelum offline.",
                "unavailable":            "Tidak Tersedia",
                "logout":                 "Keluar",
                "logout_confirm_title":   "Keluar",
                "logout_confirm_msg":     "Kamu perlu masukkan key lagi nanti.",
                "logout_confirm_yes":     "Keluar",
                "logout_confirm_cancel":  "Batal",
                "err_device_mismatch":    "Key sudah terikat ke perangkat lain",
                "err_expired":            "Key lisensi sudah kadaluarsa",
                "already_injected":       "Sudah Diinjeksi",
                "cheat_offline_msg":      "Cheat sedang offline. Inject dinonaktifkan.",
                "cheat_maintenance_msg":  "Cheat sedang maintenance. Inject dinonaktifkan.",
            ]

        case .brazilian:
            return [
                "select_language":        "Selecionar Idioma",
                "continue":               "Continuar",
                "login_title":            "FFEX IOS",
                "key_placeholder":        "FFEX-XXXXXXX",
                "validate":               "Validar",
                "validating":             "Validando...",
                "key_invalid":            "Chave inválida ou expirada",
                "key_valid":              "Acesso concedido",
                "key_label":              "Chave de Licença",
                "validate_btn":           "Validar",
                "device_not_supported":   "A versão do seu dispositivo não é suportada",
                "tab_menu":               "MENU",
                "tab_game":               "GAME",
                "header_title":           "FFEX IOS",
                "status_label":           "STATUS",
                "status_online":          "ONLINE",
                "status_offline":         "OFFLINE",
                "status_maintenance":     "MANUTENÇÃO",
                "info_key":               "KEY",
                "info_expired":           "EXPIRA",
                "info_device":            "MODELO DO DISPOSITIVO",
                "info_ios":               "VERSÃO IOS",
                "cheat_status_title":     "STATUS DO CHEAT",
                "info_card_title":        "INFORMAÇÕES DA KEY",
                "telegram":               "Entrar para Updates · t.me/ffexternal",
                "inject":                 "Injetar",
                "restore":                "Restaurar",
                "injecting":              "Injetando...",
                "inject_success":         "Injeção Concluída",
                "restore_success":        "Arquivos Restaurados",
                "inject_hint_aim":        "Injete no lobby. Restaure antes de ficar offline.",
                "inject_hint_holo":       "Injete antes de entrar na partida. Restaure antes de ficar offline.",
                "unavailable":            "Indisponível",
                "logout":                 "Sair",
                "logout_confirm_title":   "Sair",
                "logout_confirm_msg":     "Você precisará inserir sua chave novamente.",
                "logout_confirm_yes":     "Sair",
                "logout_confirm_cancel":  "Cancelar",
                "err_device_mismatch":    "Chave vinculada a outro dispositivo",
                "err_expired":            "Chave de licença expirada",
                "already_injected":       "Já Injetado",
                "cheat_offline_msg":      "O cheat está offline. Injeção desativada.",
                "cheat_maintenance_msg":  "O cheat está em manutenção. Injeção desativada.",
            ]

        case .arabic:
            return [
                "select_language":        "اختر اللغة",
                "continue":               "استمرار",
                "login_title":            "FFEX IOS",
                "key_placeholder":        "FFEX-XXXXXXX",
                "validate":               "تحقق",
                "validating":             "جارٍ التحقق...",
                "key_invalid":            "المفتاح غير صالح أو منتهي الصلاحية",
                "key_valid":              "تم منح الوصول",
                "key_label":              "مفتاح الترخيص",
                "validate_btn":           "تحقق",
                "device_not_supported":   "إصدار جهازك غير مدعوم",
                "tab_menu":               "القائمة",
                "tab_game":               "اللعبة",
                "header_title":           "FFEX IOS",
                "status_label":           "الحالة",
                "status_online":          "متصل",
                "status_offline":         "غير متصل",
                "status_maintenance":     "صيانة",
                "info_key":               "المفتاح",
                "info_expired":           "انتهاء الصلاحية",
                "info_device":            "طراز الجهاز",
                "info_ios":               "إصدار IOS",
                "cheat_status_title":     "حالة الغش",
                "info_card_title":        "معلومات المفتاح",
                "telegram":               "انضم للتحديثات · t.me/ffexternal",
                "inject":                 "حقن",
                "restore":                "استعادة",
                "injecting":              "جارٍ الحقن...",
                "inject_success":         "تم الحقن بنجاح",
                "restore_success":        "تمت استعادة الملفات",
                "inject_hint_aim":        "احقن في اللوبي. استعد قبل الخروج.",
                "inject_hint_holo":       "احقن قبل دخول المباراة. استعد قبل الخروج.",
                "unavailable":            "غير متاح",
                "logout":                 "تسجيل الخروج",
                "logout_confirm_title":   "تسجيل الخروج",
                "logout_confirm_msg":     "ستحتاج إلى إدخال مفتاحك مجدداً.",
                "logout_confirm_yes":     "خروج",
                "logout_confirm_cancel":  "إلغاء",
                "err_device_mismatch":    "المفتاح مرتبط بجهاز آخر",
                "err_expired":            "مفتاح الترخيص منتهي الصلاحية",
                "already_injected":       "تم الحقن",
                "cheat_offline_msg":      "الغش غير متصل حالياً. الحقن معطّل.",
                "cheat_maintenance_msg":  "الغش تحت الصيانة. الحقن معطّل.",
            ]

        case .taiwanese:
            return [
                "select_language":        "選擇語言",
                "continue":               "繼續",
                "login_title":            "FFEX IOS",
                "key_placeholder":        "FFEX-XXXXXXX",
                "validate":               "驗證",
                "validating":             "驗證中...",
                "key_invalid":            "金鑰無效或已過期",
                "key_valid":              "已授予訪問權限",
                "key_label":              "授權金鑰",
                "validate_btn":           "驗證",
                "device_not_supported":   "您的設備版本不受支援",
                "tab_menu":               "選單",
                "tab_game":               "遊戲",
                "header_title":           "FFEX IOS",
                "status_label":           "狀態",
                "status_online":          "線上",
                "status_offline":         "離線",
                "status_maintenance":     "維護中",
                "info_key":               "金鑰",
                "info_expired":           "到期",
                "info_device":            "裝置型號",
                "info_ios":               "IOS 版本",
                "cheat_status_title":     "外掛狀態",
                "info_card_title":        "金鑰資訊",
                "telegram":               "加入更新 · t.me/ffexternal",
                "inject":                 "注入",
                "restore":                "還原",
                "injecting":              "注入中...",
                "inject_success":         "注入成功",
                "restore_success":        "檔案已還原",
                "inject_hint_aim":        "在大廳注入。離線前請還原。",
                "inject_hint_holo":       "進入比賽前注入。離線前請還原。",
                "unavailable":            "不可用",
                "logout":                 "登出",
                "logout_confirm_title":   "登出",
                "logout_confirm_msg":     "您需要重新輸入金鑰。",
                "logout_confirm_yes":     "登出",
                "logout_confirm_cancel":  "取消",
                "err_device_mismatch":    "金鑰已綁定至其他裝置",
                "err_expired":            "授權金鑰已過期",
                "already_injected":       "已注入",
                "cheat_offline_msg":      "外掛目前離線，注入已停用。",
                "cheat_maintenance_msg":  "外掛維護中，注入已停用。",
            ]

        case .vietnamese:
            return [
                "select_language":        "Chọn Ngôn Ngữ",
                "continue":               "Tiếp Tục",
                "login_title":            "FFEX IOS",
                "key_placeholder":        "FFEX-XXXXXXX",
                "validate":               "Xác Nhận",
                "validating":             "Đang xác nhận...",
                "key_invalid":            "Khóa không hợp lệ hoặc đã hết hạn",
                "key_valid":              "Truy cập được cấp",
                "key_label":              "Khóa Bản Quyền",
                "validate_btn":           "Xác Nhận",
                "device_not_supported":   "Phiên bản thiết bị của bạn không được hỗ trợ",
                "tab_menu":               "MENU",
                "tab_game":               "GAME",
                "header_title":           "FFEX IOS",
                "status_label":           "TRẠNG THÁI",
                "status_online":          "TRỰC TUYẾN",
                "status_offline":         "NGOẠI TUYẾN",
                "status_maintenance":     "BẢO TRÌ",
                "info_key":               "KEY",
                "info_expired":           "HẾT HẠN",
                "info_device":            "MÔ HÌNH THIẾT BỊ",
                "info_ios":               "PHIÊN BẢN IOS",
                "cheat_status_title":     "TRẠNG THÁI CHEAT",
                "info_card_title":        "THÔNG TIN KEY",
                "telegram":               "Tham gia để cập nhật · t.me/ffexternal",
                "inject":                 "Chèn",
                "restore":                "Khôi Phục",
                "injecting":              "Đang chèn...",
                "inject_success":         "Chèn Thành Công",
                "restore_success":        "Đã Khôi Phục Tệp",
                "inject_hint_aim":        "Chèn khi ở sảnh. Khôi phục trước khi thoát.",
                "inject_hint_holo":       "Chèn trước khi vào trận. Khôi phục trước khi thoát.",
                "unavailable":            "Không Có Sẵn",
                "logout":                 "Đăng Xuất",
                "logout_confirm_title":   "Đăng Xuất",
                "logout_confirm_msg":     "Bạn sẽ cần nhập lại khóa.",
                "logout_confirm_yes":     "Đăng Xuất",
                "logout_confirm_cancel":  "Hủy",
                "err_device_mismatch":    "Khóa đã được gắn với thiết bị khác",
                "err_expired":            "Khóa bản quyền đã hết hạn",
                "already_injected":       "Đã Chèn Rồi",
                "cheat_offline_msg":      "Cheat hiện ngoại tuyến. Tính năng chèn bị tắt.",
                "cheat_maintenance_msg":  "Cheat đang bảo trì. Tính năng chèn bị tắt.",
            ]
        }
    }
}

// MARK: - Environment Key

private struct FFLanguageKey: EnvironmentKey {
    static let defaultValue = FFLanguage.english
}

extension EnvironmentValues {
    var ffLanguage: FFLanguage {
        get { self[FFLanguageKey.self] }
        set { self[FFLanguageKey.self] = newValue }
    }
}
