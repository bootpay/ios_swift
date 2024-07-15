//
//  BrowserOpenType.swift
//  Bootpay
//
//  Created by Taesup Yoon on 11/6/23.
//

import ObjectMapper

open class BrowserOpenType: NSObject, Mappable, Codable {
    @objc public var browser = ""
    @objc public var openType = ""
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        browser <- map["browser"]
        openType <- map["open_type"]
    }
}
