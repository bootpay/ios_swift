//
//  BootExtra.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//
import ObjectMapper

public class BootExtra: NSObject, Mappable, Codable {
    
    @objc public var cardQuota: String? // 할부허용 범위 (5만원 이상 구매시)
    @objc public var sellerName: String? // 노출되는 판매자명 설정
    @objc public var deliveryDay: Int = 1 // 배송일자
    @objc public var locale: String = "ko" // 결제창 언어지원
    @objc public var offerPeriod: String? // 결제창 제공기간, 지원하는 PG만 적용됨
    @objc public var displayCashReceipt: Bool = true // 현금영수증 보일지 말지
    @objc public var depositExpiration: String = "" // 가상계좌 입금 만료일자 설정
    @objc public var appScheme: String? // 모바일 앱에서 결제 완료 후 돌아오는 옵션
    @objc public var useCardPoint: Bool = true // 카드 포인트 사용 여부
    @objc public var directCardCompany: String = "" // 해당 카드로 바로 결제창
    @objc public var directCardQuota: String = "" // 해당 카드로 바로 결제창
    
    
    
    @objc public var useOrderId: Bool = false // 가맹점 order_id로 PG로 전송
    @objc public var internationalCardOnly: Bool = false // 해외 결제카드 선택 여부
    @objc public var phoneCarrier: String? // 본인인증 시 고정할 통신사명
    @objc public var directAppCard: Bool = false // 카드사앱으로 direct 호출
    @objc public var directSamsungpay: Bool = false // 삼성페이 바로 띄우기
    @objc public var testDeposit: Bool = false // 가상계좌 모의 입금
    @objc public var enableErrorWebhook: Bool = false // 결제 오류시 Feedback URL로 webhook
    @objc public var separatelyConfirmed: Bool = true // confirm 이벤트 호출 여부
    @objc public var confirmOnlyRestApi: Bool = false // REST API로만 승인 처리
    @objc public var openType: String = "redirect" // 페이지 오픈 type, [iframe, popup, redirect] 중 택 1
    @objc public var useBootpayInappSdk: Bool = true // native app에서 redirect를 완성도있게 지원하기 위한 옵션
    @objc public var redirectUrl: String? = "https://api.bootpay.co.kr/v2" // open_type이 redirect일 경우 페이지 이동할 URL
    @objc public var displaySuccessResult: Bool = false // 결제 완료 후 부트페이가 제공하는 완료창으로 보여주기
    @objc public var displayErrorResult: Bool = true // 결제가 실패하면 부트페이가 제공하는 실패창으로 보여주기
    @objc public var subscribeTestPayment: Bool = true // 100원 결제 후 취소
    @objc public var disposableCupDeposit: Int = 0 // 배달대행 플랫폼을 위한 컵 보증금 가격
    @objc public var useWelcomepayment: Bool = false // 웰컴 재판모듈 진행시 true
    @objc public var firstSubscriptionComment: String? // 자동결제 price > 0 조건일 때 첫 결제 관련 메세지
    @objc public var enableCardCompanies: [String]? // 허용할 카드사 리스트
    @objc public var exceptCardCompanies: [String]? // 제외할 카드사 리스트
    @objc public var enableEasyPayments: [String]? // 노출될 간편결제 리스트
    @objc public var confirmGraceSeconds: Int = 10 // 결제승인 유예시간
    @objc public var ageLimit: Int = 0 // 본인인증 나이제한
    @objc public var escrow: Bool = false
    @objc public var timeout: Int = 30 // 결제만료 시간 (분단위)
    @objc public var commonEventWebhook: Bool = false // 창닫기, 결제만료 웹훅 추가
    @objc public var showCloseButton: Bool = false
    
    public override init() {
        super.init()
        self.appScheme = self.externalURLScheme()
    }
    
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func externalURLScheme() -> String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]],
              let urlTypeDictionary = urlTypes.first,
              let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [String],
              let externalURLScheme = urlSchemes.first else {
            return nil
        }
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
        directCardQuota <- map["direct_card_quota"]
        directCardCompany <- map["direct_card_company"]
        
        
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
        disposableCupDeposit <- map["disposable_cup_deposit"]
        timeout <- map["timeout"]
        commonEventWebhook <- map["common_event_webhook"]
        enableCardCompanies <- map["enable_card_companies"]
        exceptCardCompanies <- map["except_card_companies"]
        enableEasyPayments <- map["enable_easy_payments"]
        firstSubscriptionComment <- map["first_subscription_comment"]
        confirmGraceSeconds <- map["confirm_grace_seconds"]
        subscribeTestPayment <- map["subscribe_test_payment"]
        ageLimit <- map["age_limit"]
        escrow <- map["escrow"]
    }
}
