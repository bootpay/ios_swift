//
//  BootStatItem.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

public class BootpayStatItem: NSObject, Mappable, Codable {
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        itemName <- map["itemName"]
        itemImg <- map["itemImg"]
        unique <- map["unique"]
        
        cat1 <- map["cat1"]
        cat2 <- map["cat2"]
        cat3 <- map["cat3"]
    }
    
    @objc public var itemName = "" //상품명
    @objc public var itemImg = "" //상품이미지 주소
    @objc public var unique = "" //상품의 고유 PK
    @objc public var cat1 = "" //카테고리 상
    @objc public var cat2 = "" //카테고리 중
    @objc public var cat3 = "" //카테고리 하
}
