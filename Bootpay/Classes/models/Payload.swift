//
//  Payload.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

public class Payload: NSObject, Mappable, Codable {
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        applicationId <- map["applicationId"]
        pg <- map["pg"]
        method <- map["method"]
        methods <- map["methods"]
        name <- map["name"]
        price <- map["price"]
        taxFree <- map["taxFree"]
        
        orderId <- map["orderId"]
        useOrderId <- map["useOrderId"]
        params <- map["params"]
        
        accountExpireAt <- map["accountExpireAt"]
        showAgreeWindow <- map["showAgreeWindow"]
        userToken <- map["userToken"]
        
        extra <- map["extra"]
        userInfo <- map["userInfo"]
        items <- map["items"]
    }
    
    @objc public var applicationId = ""
    @objc public var pg: String?
    @objc public var method: String?
    @objc public var methods: [String]?
    
    @objc public var name: String?
    @objc public var price = Double(0)
    @objc public var taxFree = Double(0)
    
    @objc public var orderId = ""
    @objc public var useOrderId = false
    @objc public var params: String?
    
    @objc public var accountExpireAt: String? // 가상계좌 입금 만료 기한
    @objc public var showAgreeWindow = false
    @objc public var userToken: String? //카드 간편결제, 생체결제시 필요한 파라미터
    
    @objc public var extra: BootExtra?
    @objc public var userInfo: BootUser?
    @objc public var items: [BootItem]?
    
    fileprivate func methodsToJson() -> String {
        guard let methods = self.methods else {return "" }
        var result = ""
        for v in methods {
            if result.count == 0 {
                result += "'\(v)'"
            } else {
                result += ",'\(v)'"
            }
        }
        return "[\(result)]"
    } 
}
