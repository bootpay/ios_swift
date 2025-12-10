//
//  BootExtra.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

public class BootExtra: NSObject, Codable {

    public override init() {
        super.init()
        self.appScheme = self.externalURLScheme()
    }

    enum CodingKeys: String, CodingKey {
        case cardQuota = "card_quota"
        case sellerName = "seller_name"
        case deliveryDay = "delivery_day"
        case locale
        case offerPeriod = "offer_period"
        case displayCashReceipt = "display_cash_receipt"
        case depositExpiration = "deposit_expiration"
        case appScheme = "app_scheme"
        case useCardPoint = "use_card_point"
        case directCard = "direct_card"
        case useOrderId = "use_order_id"
        case internationalCardOnly = "international_card_only"
        case phoneCarrier = "phone_carrier"
        case directAppCard = "direct_app_card"
        case directSamsungpay = "direct_samsungpay"
        case testDeposit = "test_deposit"
        case enableErrorWebhook = "enable_error_webhook"
        case separatelyConfirmed = "separately_confirmed"
        case confirmOnlyRestApi = "confirm_only_rest_api"
        case openType = "open_type"
        case useBootpayInappSdk = "use_bootpay_inapp_sdk"
        case redirectUrl = "redirect_url"
        case displaySuccessResult = "display_success_result"
        case displayErrorResult = "display_error_result"
        case useWelcomepayment = "use_welcomepayment"
        case disposableCupDeposit = "disposable_cup_deposit"
        case timeout
        case commonEventWebhook = "common_event_webhook"
        case enableCardCompanies = "enable_card_companies"
        case exceptCardCompanies = "except_card_companies"
        case enableEasyPayments = "enable_easy_payments"
        case firstSubscriptionComment = "first_subscription_comment"
        case confirmGraceSeconds = "confirm_grace_seconds"
        case subscribeTestPayment = "subscribe_test_payment"
        case ageLimit = "age_limit"
        case escrow
        case showCloseButton = "show_close_button"
    }

    func externalURLScheme() -> String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
            let externalURLScheme = urlSchemes.first as? String else { return nil }

        return externalURLScheme
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
    @objc public var separatelyConfirmed = true // confirm 이벤트를 호출할지 말지, false일 경우 자동승인
    @objc public var confirmOnlyRestApi = false //REST API로만 승인 처리
    @objc public var openType = "redirect" //페이지 오픈 type, [iframe, popup, redirect] 중 택 1
    @objc public var useBootpayInappSdk = true //native app에서는 redirect를 완성도있게 지원하기 위한 옵션
    @objc public var redirectUrl: String? = "https://api.bootpay.co.kr/v2" //open_type이 redirect일 경우 페이지 이동할 URL (  오류 및 결제 완료 모두 수신 가능 )
    @objc public var displaySuccessResult = false //결제 완료되면 부트페이가 제공하는 완료창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
    @objc public var displayErrorResult = true //결제가 실패하면 부트페이가 제공하는 실패창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
    @objc public var useWelcomepayment = false //웰컴 재판모듈 진행시 true

    @objc public var disposableCupDeposit: Int = 0 //배달대행 플랫폼을 위한 컵 보증급 가격
    @objc public var timeout: Int = 30 //결제만료 시간 (분단위)
    @objc public var commonEventWebhook = false //창닫기, 결제만료 웹훅 추가

    @objc public var ageLimit: Int = 0 //본인인증 나이제한
    @objc public var subscribeTestPayment = true //100원 결제 후 취소
    @objc public var escrow = false

    @objc public var enableCardCompanies: [String]?
    @objc public var exceptCardCompanies: [String]? //제외할 카드사 리스트 ( enable_card_companies가 우선순위를 갖는다 )
    @objc public var enableEasyPayments: [String]? //노출될 간편결제 리스트

    @objc public var firstSubscriptionComment: String? //자동결제 price > 0 조건일 때 첫 결제 관련 메세지

    @objc public var confirmGraceSeconds: Int = 10 //결제승인 유예시간 ( 승인 요청을 여러번하더라도 승인 이후 특정 시간동안 계속해서 결제 response_data 를 리턴한다 )

    @objc public var showCloseButton: Bool = false
}
