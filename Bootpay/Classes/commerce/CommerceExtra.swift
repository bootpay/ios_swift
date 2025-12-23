//
//  CommerceExtra.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

import Foundation

@objc public class CommerceExtra: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case separatelyConfirmed = "separately_confirmed"
        case createOrderImmediately = "create_order_immediately"
    }

    /// 분리 확인 여부 (기본값: false)
    @objc public var separatelyConfirmed: Bool = false

    /// 즉시 주문 생성 여부 (기본값: true)
    @objc public var createOrderImmediately: Bool = true

    public func toJSON() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["separately_confirmed"] = separatelyConfirmed
        dict["create_order_immediately"] = createOrderImmediately
        return dict
    }
}
