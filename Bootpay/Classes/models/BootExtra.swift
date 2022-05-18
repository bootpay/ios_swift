//
//  BootExtra.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//
import ObjectMapper


public class BootExtra: NSObject, Mappable, Codable {
    
    
    public override init() {
        super.init()
        self.appScheme = self.externalURLScheme() 
//        self.appScheme = (self.externalURLScheme() ?? "") + "://"
    }
    public required init?(map: Map) {
        super.init() 
        mapping(map: map)
    }
    
    func externalURLScheme() -> String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
            let externalURLScheme = urlSchemes.first as? String else { return nil }

        return externalURLScheme
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
        enableErrorWebhook <- map["enable_error_webhook"]
        separatelyConfirmed <- map["separately_confirmed"]
        confirmOnlyRestApi <- map["confirm_only_rest_api"]
        openType <- map["open_type"]
        redirectUrl <- map["redirect_url"]
        displaySuccessResult <- map["display_success_result"]
        displayErrorResult <- map["display_error_result"]
        useWelcomepayment <- map["use_welcomepayment"]
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
    @objc public var directAppCard = false //카드사앱으로 direct 호출
    @objc public var directSamsungpay = false //삼성페이 바로 띄우기
    @objc public var testDeposit = false //가상계좌 모의 입금
    @objc public var enableErrorWebhook = false //결제 오류시 Feedback URL로 webhook
//    @objc public var popup = true //네이버페이 등 특정 PG 일 경우 popup을 true로 해야함
    @objc public var separatelyConfirmed = true // confirm 이벤트를 호출할지 말지, false일 경우 자동승인
    @objc public var confirmOnlyRestApi = false //REST API로만 승인 처리
    @objc public var openType = "redirect" //페이지 오픈 type, [iframe, popup, redirect] 중 택 1
    @objc public var useBootpayInappSdk = true //native app에서는 redirect를 완성도있게 지원하기 위한 옵션
    @objc public var redirectUrl: String? = "https://api.bootpay.co.kr/v2" //open_type이 redirect일 경우 페이지 이동할 URL (  오류 및 결제 완료 모두 수신 가능 )
    @objc public var displaySuccessResult = false //결제 완료되면 부트페이가 제공하는 완료창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
    @objc public var displayErrorResult = true //결제가 실패하면 부트페이가 제공하는 실패창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
    @objc public var useWelcomepayment = false //웰컴 재판모듈 진행시 true
}
