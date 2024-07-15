//
//  BootExtraCardEasyOption.swift
//  Bootpay
//
//  Created by Taesup Yoon on 11/6/23.
//

import ObjectMapper

public class BootExtraCardEasyOption: NSObject, Mappable, Codable {
    @objc public var title: String?
    
    public override init() {
        super.init()
    }
    
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        title <- map["title"]
    }
}
