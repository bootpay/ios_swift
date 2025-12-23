//
//  CommerceUser.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

import Foundation

@objc public class CommerceUser: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case membershipType = "membership_type"
        case userId = "user_id"
        case name
        case phone
        case email
    }

    /// 회원 타입 (guest, member 등)
    @objc public var membershipType = "guest"

    /// 사용자 ID
    @objc public var userId: String?

    /// 사용자 이름
    @objc public var name: String?

    /// 전화번호
    @objc public var phone: String?

    /// 이메일
    @objc public var email: String?

    public func toJSON() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["membership_type"] = membershipType
        if let userId = userId { dict["user_id"] = userId }
        if let name = name { dict["name"] = name }
        if let phone = phone { dict["phone"] = phone }
        if let email = email { dict["email"] = email }
        return dict
    }
}
