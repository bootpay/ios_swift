//
//  BootUser.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

public class BootUser: NSObject, Mappable, Codable {
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        userId <- map["user_id"]
        username <- map["username"]
        
        email <- map["email"]
        gender <- map["gender"]
        birth <- map["birth"]
        
        phone <- map["phone"]
        area <- map["area"]
        addr <- map["addr"]
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
