import Foundation

/// Bootpay 환경 설정
///
/// 우선순위: Info.plist (xcconfig 주입) → production fallback
///
/// 환경 전환 (로컬 테스트):
///   `Bootpay.xcconfig`를 생성하여 BOOTPAY_ENV / BOOTPAY_APPLICATION_ID / BOOTPAY_CLIENT_KEY
///   등을 정의하고, Xcode Project Settings의 Configurations에 Configuration File로 지정.
///   `Info.plist`에는 `$(BOOTPAY_*)` 변수 expansion으로 값이 주입됨.
///
/// 미설정 시 production 기본값으로 동작 (배포 안전 — production-default 규칙).
struct BootpayConfig {

    // ===== Production 기본값 (fallback) =====
    private static let prodApplicationId = "5b8f6a4d396fa665fdc2b5e9"
    private static let prodRestApplicationId = "5b8f6a4d396fa665fdc2b5ea"
    private static let prodPrivateKey = "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw="
    private static let prodClientKey = "sEN72kYZBiyMNytA8nUGxQ"
    private static let prodServerKey = "rnZLJamENRgfwTccwmI_Uu9cxsPpAV9X2W-Htg73yfU="
    private static let prodSecretKey = "rnZLJamENRgfwTccwmI_Uu9cxsPpAV9X2W-Htg73yfU="

    // ===== Development 기본값 =====
    private static let devApplicationId = "5b9f51264457636ab9a07cdd"
    private static let devRestApplicationId = "59b731f084382614ebf72215"
    private static let devPrivateKey = "WwDv0UjfwFa04wYG0LJZZv1xwraQnlhnHE375n52X0U="
    private static let devClientKey = "hxS-Up--5RvT6oU6QJE0JA"
    private static let devServerKey = "r5zxvDcQJiAP2PBQ0aJjSHQtblNmYFt6uFoEMhti_mg="
    private static let devSecretKey = "r5zxvDcQJiAP2PBQ0aJjSHQtblNmYFt6uFoEMhti_mg="

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
    static var applicationId: String {
        infoString("BootpayApplicationId") ?? (isDevelopment ? devApplicationId : prodApplicationId)
    }

    // PG REST API (EasyPay 전용)
    static var restApplicationId: String {
        infoString("BootpayRestApplicationId") ?? (isDevelopment ? devRestApplicationId : prodRestApplicationId)
    }

    static var serverKey: String {
        infoString("BootpayServerKey") ?? (isDevelopment ? devServerKey : prodServerKey)
    }

    /// Legacy alias. 기존 예제/사용자 코드 호환을 위해 유지합니다.
    static var privateKey: String {
        infoString("BootpayPrivateKey") ?? (isDevelopment ? devPrivateKey : prodPrivateKey)
    }

    // Commerce API
    static var clientKey: String {
        infoString("BootpayClientKey") ?? (isDevelopment ? devClientKey : prodClientKey)
    }

    static var secretKey: String {
        infoString("BootpaySecretKey") ?? (isDevelopment ? devSecretKey : prodSecretKey)
    }
}
