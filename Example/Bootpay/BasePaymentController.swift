//
//  BasePaymentController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

class BasePaymentController: UIViewController {
    enum PaymentAuthMode {
        case clientKey
        case legacyApplicationId
        case missingKey
    }

    let _applicationId = BootpayConfig.applicationId // analytics/legacy 호환용
    let _clientKey = BootpayConfig.clientKey
    let _restApplicationId = BootpayConfig.restApplicationId
    // 주의: secret_key (secret) 는 클라이언트에 절대 포함하지 말 것 — 서버 SDK 에서만 사용
    var paymentAuthMode: PaymentAuthMode = .clientKey

    override func viewDidLoad() {
        super.viewDidLoad()
        Bootpay.setEnvironmentMode(BootpayConfig.env)
        self.view.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1)
        bootpayAnalyticsUserTrace()
        bootpayAnalyticsPageTrace()
        setupUI()
    }

    // 서브클래스에서 오버라이드하여 UI 설정
    func setupUI() {
        // Override in subclass
    }

    // 서브클래스에서 오버라이드하여 결제 시작
    func startPayment() {
        // Override in subclass
    }

    // MARK: - UI Helpers

    func createCardView() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.1
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }

    func createTitleLabel(_ text: String, fontSize: CGFloat = 20) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: fontSize)
        label.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createSubtitleLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createPriceLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(red: 52/255, green: 58/255, blue: 64/255, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    func createActionButton(_ title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func createImagePlaceholder(systemName: String, size: CGFloat = 80) -> UIImageView {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: size, weight: .light)
            imageView.image = UIImage(systemName: systemName, withConfiguration: config)
        }
        imageView.tintColor = UIColor(red: 173/255, green: 181/255, blue: 189/255, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    // MARK: - Analytics

    func bootpayAnalyticsUserTrace() {
        BootpayAnalytics.userTrace(id: "1234",
                                   email: "testUser@gmail.com",
                                   gender: 1,
                                   birth: "1994-10-14",
                                   phone: "01012341234",
                                   area: "서울",
                                   applicationId: _applicationId
        )
    }

    func bootpayAnalyticsPageTrace() {
        let item1 = BootpayStatItem()
        item1.itemName = "나는 아이템1"
        item1.unique = "item_01"
        item1.price = 500
        item1.cat1 = "TOP"
        item1.cat2 = "티셔츠"
        item1.cat3 = "반팔티"

        let item2 = BootpayStatItem()
        item2.itemName = "나는 아이템1"
        item2.unique = "item_02"
        item2.price = 250
        item2.cat1 = "TOP"
        item2.cat2 = "데님"
        item2.cat3 = "청자켓"

        BootpayAnalytics.pageTrace(
            "main_page_1234",
            applicationId: _applicationId,
            items: [item1, item2]
        )
    }

    // MARK: - Payload

    func generatePayload() -> Payload {
        let payload = Payload()
        applyAuth(to: payload, mode: paymentAuthMode)

        payload.price = 1000
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.pg = "나이스페이"
        // method 는 자식 컨트롤러가 책임지고 설정한다 (PG/구독/본인인증).
        // 통합결제는 method 를 비워두어 결제수단 선택 UI 가 직접 노출되도록 한다.
        payload.orderName = "테스트 아이템"
        payload.extra = BootExtra()
        payload.extra?.displaySuccessResult = true

        payload.extra?.appScheme = "bootpaySwift"

        let item1 = BootItem()
        item1.name = "나는 아이템1"
        item1.qty = 1
        item1.id = "item_01"
        item1.price = 500
        item1.cat1 = "TOP"
        item1.cat2 = "티셔츠"
        item1.cat3 = "반팔티"

        let item2 = BootItem()
        item2.name = "나는 아이템1"
        item2.qty = 2
        item2.id = "item_02"
        item2.price = 250
        item2.cat1 = "TOP"
        item2.cat2 = "데님"
        item2.cat3 = "청자켓"
        payload.items = [item1, item2]

        let customParams: [String: String] = [
            "callbackParam1": "value12",
            "callbackParam2": "value34",
            "callbackParam3": "value56",
            "callbackParam4": "value78",
        ]

        payload.metadata = customParams
        payload.user = generateUser()

        return payload
    }

    func applyAuth(to payload: Payload, mode: PaymentAuthMode) {
        switch mode {
        case .clientKey:
            payload.clientKey = _clientKey
        case .legacyApplicationId:
            payload.applicationId = _applicationId
        case .missingKey:
            break // NEED_CLIENT_KEY 검증용
        }
    }

    func dicToJson(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonStr = String(data: jsonData, encoding: .utf8)
            if let jsonStr = jsonStr {
                return jsonStr
            }
            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }

    func generateUser() -> BootUser {
        let user = BootUser()
        user.id = "123456abcdffffe23456789012345613245167891223111"
        user.userId = "123456abcdffffe23456789012345613245167891223111"
        user.area = "서울"
        user.gender = 1
        user.email = "test1234@gmail.com"
        user.phone = "01012344567"
        user.birth = "1988-06-10"
        user.username = "홍길동"
        return user
    }
}
