//
//  WidgetData.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/8/24.
//

import ObjectMapper

open class WidgetData: NSObject, Mappable, Codable {
    
    
    @objc public var pg: String?
    @objc public var method: String?
    @objc public var walletId: String?
    
//    private List<WidgetTerm> selectTerms = new ArrayList<>();
    @objc public var selectTerms: [WidgetTerm]?
    
    @objc public var currency: String?
    
    @objc public var termPassed: Bool = false
    
    @objc public var completed: Bool = false
    
    @objc public var extra: WidgetExtra?
//    private WidgetExtra extra
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(pg, forKey: .pg)
        try container.encodeIfPresent(method, forKey: .method)
        try container.encodeIfPresent(walletId, forKey: .walletId)
        
        try container.encodeIfPresent(selectTerms, forKey: .selectTerms)
        try container.encodeIfPresent(currency, forKey: .currency)
        try container.encodeIfPresent(termPassed, forKey: .termPassed)
        try container.encodeIfPresent(completed, forKey: .completed)
        try container.encodeIfPresent(extra, forKey: .extra)
    }
    
    public func mapping(map: Map) {
        pg <- map["pg"]
        method <- map["method"]
        walletId <- map["wallet_id"]
        
        selectTerms <- map["select_terms"]
        currency <- map["currency"]
        termPassed <- map["term_passed"]
        completed <- map["completed"]
        extra <- map["extra"]
    }
    
}
