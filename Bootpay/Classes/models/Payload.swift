//
//  Payload.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

open class Payload: NSObject, Codable {

    public override init() {}

    /// Dictionary에서 Payload 생성 (ObjectMapper 대체)
    public convenience init?(JSON: [String: Any]) {
        self.init()

        if let applicationId = JSON["application_id"] as? String {
            self.applicationId = applicationId
        }
        if let clientKey = JSON["client_key"] as? String {
            self.clientKey = clientKey
        }
        self.pg = JSON["pg"] as? String
        self.method = JSON["method"] as? String
        self.methods = JSON["methods"] as? [String]
        self.orderName = JSON["order_name"] as? String
        if let price = JSON["price"] as? Double {
            self.price = price
        }
        if let taxFree = JSON["tax_free"] as? Double {
            self.taxFree = taxFree
        }
        if let orderId = JSON["order_id"] as? String {
            self.orderId = orderId
        }
        if let subscriptionId = JSON["subscription_id"] as? String {
            self.subscriptionId = subscriptionId
        }
        if let authenticationId = JSON["authentication_id"] as? String {
            self.authenticationId = authenticationId
        }
        self.metadata = JSON["metadata"] as? [String: String]
        self.userToken = JSON["user_token"] as? String

        if JSON["extra"] is [String: Any] {
            self.extra = BootExtra()
        }
        if let userData = JSON["user"] as? [String: Any] {
            self.user = BootUser()
            self.user?.id = userData["id"] as? String
            self.user?.userId = userData["user_id"] as? String
            self.user?.username = userData["username"] as? String
            self.user?.email = userData["email"] as? String
            self.user?.gender = userData["gender"] as? Int ?? 0
            self.user?.birth = userData["birth"] as? String
            self.user?.phone = userData["phone"] as? String
            self.user?.area = userData["area"] as? String
            self.user?.addr = userData["addr"] as? String
        }
    }

    enum CodingKeys: String, CodingKey {
        case applicationId = "application_id"
        case clientKey = "client_key"
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
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if !clientKey.isEmpty {
            try container.encode(clientKey, forKey: .clientKey)
        } else {
            try container.encodeIfPresent(applicationId, forKey: .applicationId)
        }
        try container.encodeIfPresent(pg, forKey: .pg)

        if (methods?.count ?? 0) > 0 {
            try container.encodeIfPresent(methods!, forKey: .methods)
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

        try container.encodeIfPresent(userToken, forKey: .userToken)

        try container.encodeIfPresent(extra, forKey: .extra)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(items, forKey: .items)
    }

    @objc public var applicationId = ""
    @objc public var clientKey = ""
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

    @objc public var extra: BootExtra?
    @objc public var user: BootUser? = BootUser()
    @objc public var items: [BootItem]?

    // MARK: - Widget Request 관련
    @objc public var widgetKey: String? // "default-widget"
    @objc public var widgetUseTerms: Bool = false
    @objc public var widgetSandbox: Bool = false

    // MARK: - Widget Response 관련 (내부 사용)
    internal var widgetWalletId: String?
    internal var widgetData: WidgetData?
    internal var widgetSelectTerms: [WidgetTerm]?
    internal var widgetTermPassed: Bool = false
    internal var widgetCompleted: Bool = false

    /// 위젯이 결제 가능한 상태인지 확인
    @objc public var widgetIsCompleted: Bool {
        return widgetTermPassed && widgetCompleted
    }

    /// WidgetData를 Payload에 병합합니다.
    @objc public func mergeWidgetData(_ data: WidgetData?) {
        guard let data = data else { return }
        self.pg = data.pg
        self.method = data.method
        self.widgetWalletId = data.walletId
        self.widgetSelectTerms = data.selectTerms
        self.widgetTermPassed = data.termPassed
        self.widgetCompleted = data.completed
        self.widgetData = data
    }

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
