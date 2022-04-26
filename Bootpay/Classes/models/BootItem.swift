//
//  BootItem.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

public class BootItem: NSObject, Mappable, Codable {
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        name <- map["name"]
        qty <- map["qty"]
        id <- map["id"]
        
        price <- map["price"]
        cat1 <- map["cat1"]
        cat2 <- map["cat2"]
        cat3 <- map["cat3"]
    }
    
    @objc public var name = "" //아이템 이름
    @objc public var qty: Int = 0  //상품 판매된 수량
    @objc public var id: String? //상품의 고유 PK
    @objc public var price = Double(0) //상품 하나당 판매 가격
    @objc public var cat1: String? //카테고리 상
    @objc public var cat2: String? //카테고리 중
    @objc public var cat3: String? //카테고리 하
}
