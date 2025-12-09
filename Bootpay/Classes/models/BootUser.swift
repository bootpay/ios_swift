//
//  BootUser.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

public class BootUser: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case username
        case email
        case gender
        case birth
        case phone
        case area
        case addr
    }

    @objc public var id: String?
    @objc public var userId: String?
    @objc public var username: String?
    @objc public var email: String?
    @objc public var gender = 0
    @objc public var birth: String?
    @objc public var phone: String?
    @objc public var area: String?
    @objc public var addr: String?

    open func setEncodedValueAll() {
        if let id = self.id {
            self.id = id.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let userId = self.userId {
            self.userId = userId.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let username = self.username {
            self.username = username.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let email = self.email {
            self.email = email.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let birth = self.birth {
            self.birth = birth.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let phone = self.phone {
            self.phone = phone.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let area = self.area {
            self.area = area.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
        if let addr = self.addr {
            self.addr = addr.replace(target: "\"", withString: "'").replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        }
    }
}
