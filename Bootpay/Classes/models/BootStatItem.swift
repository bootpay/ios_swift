//
//  BootStatItem.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

public class BootpayStatItem: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case itemName = "item_name"
        case itemImg = "item_img"
        case unique
        case price
        case cat1
        case cat2
        case cat3
    }

    @objc public var itemName = "" //상품명
    @objc public var itemImg = "" //상품이미지 주소
    @objc public var unique = "" //상품의 고유 PK
    @objc public var price = Double(0) // 가격
    @objc public var cat1 = "" //카테고리 상
    @objc public var cat2 = "" //카테고리 중
    @objc public var cat3 = "" //카테고리 하

    public func toJSON() -> [String: Any] {
        return [
            "item_name": itemName,
            "item_img": itemImg,
            "unique": unique,
            "price": price,
            "cat1": cat1,
            "cat2": cat2,
            "cat3": cat3
        ]
    }
}
