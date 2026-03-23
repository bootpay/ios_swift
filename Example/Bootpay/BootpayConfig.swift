import Foundation

struct BootpayConfig {

    // 환경 설정: "development" 또는 "production"
    static let env = "development"

    static var isDevelopment: Bool {
        env == "development"
    }

    // PG API
    static var applicationId: String {
        isDevelopment ? "5b9f51264457636ab9a07cdd" : "5b8f6a4d396fa665fdc2b5e9"
    }

    // Commerce API
    static var clientKey: String {
        isDevelopment ? "hxS-Up--5RvT6oU6QJE0JA" : "sEN72kYZBiyMNytA8nUGxQ"
    }

    static var secretKey: String {
        isDevelopment ? "r5zxvDcQJiAP2PBQ0aJjSHQtblNmYFt6uFoEMhti_mg=" : "rnZLJamENRgfwTccwmI_Uu9cxsPpAV9X2W-Htg73yfU="
    }
}
