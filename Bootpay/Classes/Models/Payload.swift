//
//  Payload.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

enum PayloadKeys: String, CodingKey {
      case applicationId = "application_id"
      case pg
      case method
      case methods
      case orderName = "order_name"
      case price
      case taxFree = "tax_free"
      case orderId = "order_id"
      case subscriptionId = "subscription_id"
      case authenticationId = "authentication_id"
      case metadata
      case userToken = "user_token"
      case extra
      case user
      case items
      case key = "key"
      case widget
      case useBootpayInappSDK = "use_bootpay_inapp_sdk"
      case oopay
      case currency
      case walletId = "wallet_id"
      case terms
      case useTerms = "use_terms"
      case sandbox
}

open class Payload: NSObject, Mappable, Codable {
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
//    public required init(from decoder: Decoder) throws {
//        _ = CodingKeys.self
//
//        print("Payload dd")
////        self.method
//
//    }
    
    
    
    public func encode(to encoder: Encoder) throws {

        
//        var container = encoder.
        var container = encoder.container(keyedBy: PayloadKeys.self)
        
        try container.encodeIfPresent(applicationId, forKey: .applicationId)
        try container.encodeIfPresent(pg, forKey: .pg)
        

        if (methods?.count ?? 0) > 0 {
            try container.encodeIfPresent(methods!, forKey: .method)
        } else {
            try container.encodeIfPresent(method, forKey: .method)
        }
        try container.encodeIfPresent(orderName, forKey: .orderName)
        try container.encodeIfPresent(price, forKey: .price)
        try container.encodeIfPresent(taxFree, forKey: .taxFree)
        
        try container.encodeIfPresent(orderId, forKey: .orderId)
        try container.encodeIfPresent(subscriptionId, forKey: .subscriptionId)
        try container.encodeIfPresent(authenticationId, forKey: .authenticationId)
        
        try container.encodeIfPresent(metadata, forKey: .metadata)
        
        
        
        try container.encodeIfPresent(extra, forKey: .extra)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(items, forKey: .items)
        
        try container.encodeIfPresent(widgetKey, forKey: .key)
        try container.encodeIfPresent(widgetUseTerms, forKey: .useTerms)
        try container.encodeIfPresent(widgetSandbox, forKey: .sandbox)
        
        
        if(widgetKey != nil) {
            try container.encode(1, forKey: .widget)
            try container.encode(true, forKey: .useBootpayInappSDK)
            
        }
        try container.encodeIfPresent(currency, forKey: .currency)
        try container.encodeIfPresent(_widgetWalletId, forKey: .walletId)
        try container.encodeIfPresent(widgetUseTerms, forKey: .terms)
        try container.encodeIfPresent(userToken, forKey: .userToken)
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
    
    @objc public var applicationId: String?
    @objc public var pg: String?
    @objc public var method: String?
    @objc public var methods: [String]?
    
    @objc public var orderName: String?
    @objc public var price = Double(0)
    @objc public var taxFree = Double(0)
    
    @objc public var orderId: String?
    @objc public var subscriptionId: String?
    @objc public var authenticationId: String?
     
    @objc public var metadata: [String:String]?
     
    @objc public var userToken: String? //카드 간편결제, 생체결제시 필요한 파라미터
//    @objc public var token: String = "token" //비밀번호 결제 - 개발사는 사용하지 않는다. 부트페이 내부적으로 사용됨
//    @objc public var walletId: String = "res.wallets[0].wallet_id" //비밀번호 결제 - 개발사는 사용하지 않는다. 부트페이 내부적으로 사용됨
//    @objc public var authenticateType: String? //비밀번호 결제 - 개발사는 사용하지 않는다. 부트페이 내부적으로 사용됨
    
    @objc public var extra: BootExtra?
//    @objc public var userInfo: BootUser? = BootUser()
    @objc public var user: BootUser? = BootUser()
    @objc public var items: [BootItem]?
    
    
    //widget 관련
    @objc public var widgetKey: String?
    @objc public var widgetUseTerms = false
    @objc public var widgetSandbox = false
    @objc public var widgetOopay: Oopay?
    
    @objc public var currency: String?
    @objc public var _widgetWalletId: String?
    @objc public var _widgetData: WidgetData? = WidgetData()
    @objc public var _widgetSelectTerms: [WidgetTerm]?
//    @objc public var _widgetWalletId = ""
    @objc public var _widgetTermPassed = false
    @objc public var _widgetCompleted = false
    
//    private var key: ;
    
    
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
    
    public func mergeWidgetData(data: WidgetData) {
        self._widgetData = data
        
        if(data.pg != nil) { self.pg = data.pg }
        if(data.method != nil) { self.method = data.method }
        
        self._widgetCompleted = data.completed
        self._widgetTermPassed = data.termPassed
        if data.currency != nil { self.currency = data.currency }
        if data.selectTerms != nil { self._widgetSelectTerms = data.selectTerms }
        if data.walletId != nil { self._widgetWalletId = data.walletId }
        
        if(self.extra == nil) { self.extra = BootExtra() }
        if(data.extra != nil) {
            if(data.extra?.directCardCompany != nil) { self.extra?.directCardCompany = data.extra?.directCardCompany ?? "" }
            if(data.extra?.directCardQuota != nil) { self.extra?.directCardQuota = data.extra?.directCardQuota ?? "" }
            if(data.extra?.cardQuota != nil) { self.extra?.cardQuota = data.extra?.cardQuota ?? "" }
            
        }
    }
    
    public func getWidgetIsCompleted() -> Bool {
        print("getWidgetIsCompleted : \(_widgetCompleted) , \(_widgetTermPassed)")
        return _widgetCompleted && _widgetTermPassed
    }
}
