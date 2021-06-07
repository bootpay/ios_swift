//
//  BootItem.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

public class BootItem: NSObject, Codable {
    @objc public var itemName = "" //아이템 이름
    @objc public var qty: Int = 0  //상품 판매된 수량
    @objc public var unique: String? //상품의 고유 PK
    @objc public var price = Double(0) //상품 하나당 판매 가격
    @objc public var cat1: String? //카테고리 상
    @objc public var cat2: String? //카테고리 중
    @objc public var cat3: String? //카테고리 하
}
