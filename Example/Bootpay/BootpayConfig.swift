import Foundation

/// Bootpay 환경 설정
///
/// 키는 모두 xcconfig 에서 주입 — `BootpayKeys.{debug,release}.xcconfig` 가 production 기본값
/// (committed baseline). 로컬 dev 환경 시 `Bootpay.xcconfig` (gitignored) 를 만들어 BOOTPAY_ENV/키를 override.
///
/// 흐름: xcconfig → Info.plist 변수 expansion → `Bundle.main.infoDictionary`
struct BootpayConfig {

    private static func infoString(_ key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !(trimmed.hasPrefix("$(") && trimmed.hasSuffix(")")) else {
            return nil
        }
        return trimmed
    }

    static let env: String = infoString("BootpayEnv") ?? "production"
    static var isDevelopment: Bool { env == "development" }

    // PG API
    static var applicationId: String { infoString("BootpayApplicationId") ?? "" }

    // PG REST API (EasyPay 전용)
    static var restApplicationId: String { infoString("BootpayRestApplicationId") ?? "" }

    // 주의: server_key (secret) 는 클라이언트에 절대 포함하지 말 것 — 서버 SDK 에서만 사용

    /// Legacy alias. 기존 예제/사용자 코드 호환을 위해 유지합니다.
    static var privateKey: String { infoString("BootpayPrivateKey") ?? "" }

    // Commerce API
    static var clientKey: String { infoString("BootpayClientKey") ?? "" }
}
