//
//  WidgetExtra.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/8/24.
//


import ObjectMapper

open class WidgetExtra: NSObject, Mappable, Codable {
    
    @objc public var directCardCompany: String?
    
    @objc public var directCardQuota: String?
    
    @objc public var cardQuota: String?
     
    
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(directCardCompany, forKey: .directCardCompany)
        try container.encodeIfPresent(directCardQuota, forKey: .directCardQuota)
        try container.encodeIfPresent(cardQuota, forKey: .cardQuota)
    }
    
    public func mapping(map: Map) {
        directCardCompany <- map["direct_card_company"]
        directCardQuota <- map["direct_card_quota"]
        cardQuota <- map["card_quota"]
    }
}

