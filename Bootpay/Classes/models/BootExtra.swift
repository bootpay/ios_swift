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
        cardQuota <- map["card_quota"]
        sellerName <- map["seller_name"]
        deliveryDay <- map["delivery_day"]
        locale <- map["locale"]
        offerPeriod <- map["offer_period"]
        
        displayCashReceipt <- map["display_cash_receipt"]
        depositExpiration <- map["deposit_expiration"]
        appScheme <- map["app_scheme"]
        useCardPoint <- map["use_card_point"]
        directCard <- map["direct_card"]
        
        useOrderId <- map["use_order_id"]
        internationalCardOnly <- map["international_card_only"]
        phoneCarrier <- map["phone_carrier"]
        directAppCard <- map["direct_app_card"]
        directSamsungpay <- map["direct_samsungpay"]
        testDeposit <- map["test_deposit"]
        popup <- map["popup"]
    }
    
    @objc public var cardQuota: String? //할부허용 범위 (5만원 이상 구매시)
    @objc public var sellerName: String? //노출되는 판매자명 설정
    @objc public var deliveryDay: Int = 1 //배송일자
    @objc public var locale = "ko" //결제창 언어지원
    @objc public var offerPeriod: String? //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨
    @objc public var displayCashReceipt = true // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
    @objc public var depositExpiration = "" //가상계좌 입금 만료일자 설정
    @objc public var appScheme: String? //모바일 앱에서 결제 완료 후 돌아오는 옵션 ( 아이폰만 적용 )
    @objc public var useCardPoint = true //카드 포인트 사용 여부 (토스만 가능)
    @objc public var directCard = "" //해당 카드로 바로 결제창 (토스만 가능)
    @objc public var useOrderId = false //가맹점 order_id로 PG로 전송
    @objc public var internationalCardOnly = false //해외 결제카드 선택 여부 (토스만 가능)
    @objc public var phoneCarrier: String? //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
    @objc public var directAppCard = "" //카드사앱으로 direct 호출
    @objc public var directSamsungpay = "" //삼성페이 바로 띄우기
    @objc public var testDeposit = "" //가상계좌 모의 입금
    @objc public var popup = false //네이버페이 등 특정 PG 일 경우 popup을 true로 해야함 
     
}
