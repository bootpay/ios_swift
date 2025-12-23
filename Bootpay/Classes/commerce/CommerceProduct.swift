//
//  CommerceProduct.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

import Foundation

@objc public class CommerceProduct: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case duration
        case quantity
    }

    /// 상품 ID (Commerce 대시보드에서 생성된 ID)
    @objc public var productId = ""

    /// 구독 기간 (-1: 무기한)
    @objc public var duration: Int = -1

    /// 수량
    @objc public var quantity: Int = 1

    public func toJSON() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["product_id"] = productId
        dict["duration"] = duration
        dict["quantity"] = quantity
        return dict
    }
}
