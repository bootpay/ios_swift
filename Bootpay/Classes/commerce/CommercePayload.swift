//
//  CommercePayload.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

import Foundation

@objc public class CommercePayload: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case clientKey = "client_key"
        case name
        case memo
        case user
        case price
        case redirectUrl = "redirect_url"
        case usageApiUrl = "usage_api_url"
        case useAutoLogin = "use_auto_login"
        case requestId = "request_id"
        case useNotification = "use_notification"
        case products
        case metadata
        case extra
    }

    /// 클라이언트 키 (Commerce 대시보드에서 발급)
    @objc public var clientKey = ""

    /// 청구서/주문 이름
    @objc public var name: String?

    /// 메모
    @objc public var memo: String?

    /// 사용자 정보
    @objc public var user: CommerceUser?

    /// 결제 금액
    @objc public var price: Double = 0

    /// 결제 완료 후 리다이렉트 URL
    @objc public var redirectUrl: String?

    /// 사용량 API URL (구독 결제 시)
    @objc public var usageApiUrl: String?

    /// 자동 로그인 사용 여부
    @objc public var useAutoLogin: Bool = false

    /// 요청 ID (주문 ID)
    @objc public var requestId: String?

    /// 알림 사용 여부
    @objc public var useNotification: Bool = false

    /// 상품 목록
    @objc public var products: [CommerceProduct]?

    /// 메타데이터 (추가 정보) - Objective-C용
    @objc public var metadata: [String: String]?

    /// 메타데이터 (추가 정보) - Swift Any 타입 지원
    public var metadataAny: [String: Any]?

    /// 추가 옵션
    @objc public var extra: CommerceExtra?

    /// JSON Dictionary로 변환
    public func toJSON() -> [String: Any] {
        var dict: [String: Any] = [:]

        dict["client_key"] = clientKey
        if let name = name { dict["name"] = name }
        if let memo = memo { dict["memo"] = memo }
        if let user = user { dict["user"] = user.toJSON() }
        if price > 0 { dict["price"] = price }
        if let redirectUrl = redirectUrl { dict["redirect_url"] = redirectUrl }
        if let usageApiUrl = usageApiUrl { dict["usage_api_url"] = usageApiUrl }
        dict["use_auto_login"] = useAutoLogin
        if let requestId = requestId { dict["request_id"] = requestId }
        dict["use_notification"] = useNotification

        if let products = products {
            dict["products"] = products.map { $0.toJSON() }
        }

        // metadataAny 우선, 없으면 metadata 사용
        if let metadataAny = metadataAny, !metadataAny.isEmpty {
            dict["metadata"] = metadataAny
        } else if let metadata = metadata, !metadata.isEmpty {
            dict["metadata"] = metadata
        }

        if let extra = extra { dict["extra"] = extra.toJSON() }

        return dict
    }

    /// JSON 문자열로 변환
    public func toJSONString() -> String {
        let dict = toJSON()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("[CommercePayload] JSON 변환 오류: \(error)")
        }
        return "{}"
    }
}
