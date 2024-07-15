//
//  WidgetTerm.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/8/24.
//

import ObjectMapper

open class WidgetTerm: NSObject, Mappable, Codable {
    
    @objc public var termId: String?
    
    @objc public var pk: String?
    
    @objc public var title: String?
    
    @objc public var agree: String?
    
    @objc public var termType: Int = -1
    
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(termId, forKey: .termId)
        try container.encodeIfPresent(pk, forKey: .pk)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(agree, forKey: .agree)
        try container.encodeIfPresent(termType, forKey: .termType)
    }
    
    public func mapping(map: Map) {
        termId <- map["term_id"]
        pk <- map["pk"]
        title <- map["title"]
        agree <- map["agree"]
        termType <- map["termType"]
    }
}
