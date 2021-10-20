//
//  BootExtra.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//
import ObjectMapper


public class BootExtra: NSObject, Mappable, Codable {
    
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        startAt <- map["startAt"]
        endAt <- map["endAt"]
        expireMonth <- map["expireMonth"]
        vbankResult <- map["vbankResult"]
        quotas <- map["quotas"]
        appScheme <- map["appScheme"]
        
        locale <- map["locale"]
        offerPeriod <- map["offerPeriod"]
        
        popup <- map["popup"]
        quickPopup <- map["quickPopup"]
        
        carrier <- map["carrier"]
        ageLimit <- map["ageLimit"]
    }
    
    @objc public var startAt: String? // 정기 결제 시작일 - 시작일을 지정하지 않으면 그 날 당일로부터 결제가 가능한 Billing key 지급
    @objc public var endAt: String? // 정기결제 만료일 -  기간 없음 - 무제한
    @objc public var expireMonth = 0 //정기결제가 적용되는 개월 수 (정기결제 사용시)
    @objc public var vbankResult = true //가상계좌 결과창을 볼지 말지 (가상계좌 사용시)
    @objc public var quotas = [Int]() //할부허용 범위 (5만원 이상 구매시)
    @objc public var appScheme: String? //app2app 결제시 return 받을 intent scheme
    
    @objc public var locale = "ko" //결제창 언어지원
    @objc public var offerPeriod: String? //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨
    @objc public var popup = 0 //1이면 popup, 0이면 iframe 연동
    @objc public var quickPopup = 0 //1: popup 호출시 버튼을 띄우지 않는다. 0: 일 경우 버튼을 호출한다
    @objc public var dispCashResult = "Y" // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
    @objc public var escrow = 0
    @objc public var iosCloseButton = false
    @objc public var onestore = BootOneStore()
    
    @objc public var carrier: String? //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능 
    @objc public var ageLimit: Int = 0 // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능
    
    
    @objc public var theme = "purple" //통합 결제창 색상 지정 (purple, red, custom 지정 가능 )
    @objc public var customBackground: String? //theme가 custom인 경우 배경 색 지정 가능 ( ex: #f2f2f2 )
    @objc public var customFontColor: String? //theme가 custom인 경우 폰트색 지정 가능 ( ex: #333333 )
    @objc public var topMargin: Double = 0.0 
}
