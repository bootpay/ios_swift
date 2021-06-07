//
//  BootStatItem.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

public class BootpayStatItem: NSObject, Codable {
    @objc public var itemName = "" //상품명
    @objc public var itemImg = "" //상품이미지 주소
    @objc public var unique = "" //상품의 고유 PK
    @objc public var cat1 = "" //카테고리 상
    @objc public var cat2 = "" //카테고리 중
    @objc public var cat3 = "" //카테고리 하
}
