//
//  Oopay.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/8/24.
//

import ObjectMapper

open class Oopay: NSObject, Mappable, Codable {
    
    @objc public var cardQuota: [Int]?
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cardQuota, forKey: .cardQuota)
    }
    
    public func mapping(map: Map) {
        cardQuota <- map["card_quota"]
    }
     
}
