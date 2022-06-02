//
//  Payload.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

open class Payload: NSObject, Mappable, Codable {
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        applicationId <- map["application_id"]
        pg <- map["pg"]
        method <- map["method"]
        methods <- map["methods"]
        orderName <- map["order_name"]
        price <- map["price"]
        taxFree <- map["tax_free"]
        
        orderId <- map["order_id"]
        subscriptionId <- map["subscription_id"]
        authenticationId <- map["authentication_id"]
         
        metadata <- map["metadata"]
         
        userToken <- map["user_token"]
//        token <- map["token"]
        
        extra <- map["extra"] 
        user <- map["user"]
        items <- map["items"]
    }
    
    @objc public var applicationId = ""
    @objc public var pg: String?
    @objc public var method: String?
    @objc public var methods: [String]?
    
    @objc public var orderName: String?
    @objc public var price = Double(0)
    @objc public var taxFree = Double(0)
    
    @objc public var orderId = ""
    @objc public var subscriptionId = ""
    @objc public var authenticationId = ""
     
    @objc public var metadata: [String:String]?
     
    @objc public var userToken: String? //카드 간편결제, 생체결제시 필요한 파라미터
//    @objc public var token: String = "token" //비밀번호 결제 - 개발사는 사용하지 않는다. 부트페이 내부적으로 사용됨
//    @objc public var walletId: String = "res.wallets[0].wallet_id" //비밀번호 결제 - 개발사는 사용하지 않는다. 부트페이 내부적으로 사용됨
//    @objc public var authenticateType: String? //비밀번호 결제 - 개발사는 사용하지 않는다. 부트페이 내부적으로 사용됨
    
    @objc public var extra: BootExtra?
//    @objc public var userInfo: BootUser? = BootUser()
    @objc public var user: BootUser? = BootUser()
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
