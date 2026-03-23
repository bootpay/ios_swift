//
//  CommerceExampleController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2024/12/23.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class CommerceExampleController: BasePaymentController {

    // 환경별 플랜 설정 (product ID)
    let ENV_PLANS: [String: [String: [String: String]]] = [
        "development": [
            "starter": [
                "monthly_product_id": "69268625d8df8fa1837cf661",
                "yearly_product_id": "692686c4d8df8fa1837cf666"
            ],
            "pro": [
                "monthly_product_id": "692686e5d8df8fa1837cf66b",
                "yearly_product_id": "69268721d8df8fa1837cf670"
            ],
            "enterprise": [
                "monthly_product_id": "69268783d8df8fa1837cf675",
                "yearly_product_id": "692687a2d8df8fa1837cf67a"
            ]
        ],
        "production": [
            "starter": [
                "monthly_product_id": "6927d893ff30795ff003d374",
                "yearly_product_id": "6927d8c310561eabadddcfae"
            ],
            "pro": [
                "monthly_product_id": "6927d8f9ff30795ff003d379",
                "yearly_product_id": "6927d9167f65277ba9ddcf71"
            ],
            "enterprise": [
                "monthly_product_id": "6927d8f9ff30795ff003d379",
                "yearly_product_id": "6927d9167f65277ba9ddcf71"
            ]
        ]
    ]

    // 플랜 정보
    let PLAN_INFO: [String: [String: Any]] = [
        "starter": [
            "name": "Starter",
            "monthly_price": 9900,
            "yearly_price": 7900,
            "features": ["5GB 클라우드 스토리지", "최대 3개 프로젝트", "기본 분석 대시보드"]
        ],
        "pro": [
            "name": "Professional",
            "monthly_price": 29900,
            "yearly_price": 23900,
            "features": ["100GB 클라우드 스토리지", "무제한 프로젝트", "고급 분석 및 리포트"]
        ],
        "enterprise": [
            "name": "Enterprise",
            "monthly_price": 99000,
            "yearly_price": 79000,
            "features": ["무제한 클라우드 스토리지", "무제한 프로젝트", "전용 계정 매니저"]
        ]
    ]

    var currentEnv: String { BootpayConfig.env }
    var isYearlyBilling = false
    var selectedPlan = "pro"

    // UI 컴포넌트
    var billingToggle: UISwitch!
    var starterCard: UIView!
    var proCard: UIView!
    var enterpriseCard: UIView!

    // 테마 컬러 (그라데이션 보라색)
    let primaryColor = UIColor(red: 102/255, green: 126/255, blue: 234/255, alpha: 1) // #667eea
    let secondaryColor = UIColor(red: 118/255, green: 75/255, blue: 162/255, alpha: 1) // #764ba2

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Commerce 구독"
    }

    override func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // 헤더
        let headerLabel = createTitleLabel("나에게 맞는 요금제를 선택하세요", fontSize: 22)
        headerLabel.textAlignment = .center

        let descLabel = createSubtitleLabel("모든 요금제에서 14일 무료 체험을 제공합니다")
        descLabel.textAlignment = .center

        // 결제 주기 토글
        let billingContainer = createBillingToggle()

        // 플랜 카드들
        starterCard = createPlanCard(
            planKey: "starter",
            icon: "🚀",
            isPopular: false
        )

        proCard = createPlanCard(
            planKey: "pro",
            icon: "⚡",
            isPopular: true
        )

        enterpriseCard = createPlanCard(
            planKey: "enterprise",
            icon: "🏢",
            isPopular: false
        )

        // Add subviews
        contentView.addSubview(headerLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(billingContainer)
        contentView.addSubview(starterCard)
        contentView.addSubview(proCard)
        contentView.addSubview(enterpriseCard)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            descLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            billingContainer.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 24),
            billingContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            starterCard.topAnchor.constraint(equalTo: billingContainer.bottomAnchor, constant: 24),
            starterCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            starterCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            proCard.topAnchor.constraint(equalTo: starterCard.bottomAnchor, constant: 16),
            proCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            proCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            enterpriseCard.topAnchor.constraint(equalTo: proCard.bottomAnchor, constant: 16),
            enterpriseCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            enterpriseCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            enterpriseCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])

        // Pro 카드 초기 선택 상태
        updateCardSelection()
    }

    func createBillingToggle() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let monthlyLabel = UILabel()
        monthlyLabel.text = "월간"
        monthlyLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        monthlyLabel.textColor = UIColor(red: 33/255, green: 37/255, blue: 41/255, alpha: 1)
        monthlyLabel.translatesAutoresizingMaskIntoConstraints = false

        billingToggle = UISwitch()
        billingToggle.onTintColor = primaryColor
        billingToggle.addTarget(self, action: #selector(billingToggleChanged), for: .valueChanged)
        billingToggle.translatesAutoresizingMaskIntoConstraints = false

        let yearlyLabel = UILabel()
        yearlyLabel.text = "연간"
        yearlyLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        yearlyLabel.textColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1)
        yearlyLabel.translatesAutoresizingMaskIntoConstraints = false

        let discountBadge = UILabel()
        discountBadge.text = "20% 할인"
        discountBadge.font = UIFont.boldSystemFont(ofSize: 11)
        discountBadge.textColor = UIColor(red: 21/255, green: 128/255, blue: 61/255, alpha: 1)
        discountBadge.backgroundColor = UIColor(red: 220/255, green: 252/255, blue: 231/255, alpha: 1)
        discountBadge.layer.cornerRadius = 10
        discountBadge.clipsToBounds = true
        discountBadge.textAlignment = .center
        discountBadge.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(monthlyLabel)
        container.addSubview(billingToggle)
        container.addSubview(yearlyLabel)
        container.addSubview(discountBadge)

        NSLayoutConstraint.activate([
            monthlyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            monthlyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            billingToggle.leadingAnchor.constraint(equalTo: monthlyLabel.trailingAnchor, constant: 12),
            billingToggle.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            yearlyLabel.leadingAnchor.constraint(equalTo: billingToggle.trailingAnchor, constant: 12),
            yearlyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            discountBadge.leadingAnchor.constraint(equalTo: yearlyLabel.trailingAnchor, constant: 8),
            discountBadge.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            discountBadge.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            discountBadge.widthAnchor.constraint(equalToConstant: 70),
            discountBadge.heightAnchor.constraint(equalToConstant: 22),

            container.heightAnchor.constraint(equalToConstant: 40)
        ])

        return container
    }

    func createPlanCard(planKey: String, icon: String, isPopular: Bool) -> UIView {
        guard let planInfo = PLAN_INFO[planKey] as? [String: Any],
              let name = planInfo["name"] as? String,
              let monthlyPrice = planInfo["monthly_price"] as? Int,
              let features = planInfo["features"] as? [String] else {
            return UIView()
        }

        let card = createCardView()

        if isPopular {
            card.layer.borderWidth = 2
            card.layer.borderColor = primaryColor.cgColor
        }

        // 인기 배지 (Pro만)
        if isPopular {
            let badge = UILabel()
            badge.text = "가장 인기"
            badge.font = UIFont.boldSystemFont(ofSize: 11)
            badge.textColor = .white
            badge.backgroundColor = primaryColor
            badge.layer.cornerRadius = 10
            badge.clipsToBounds = true
            badge.textAlignment = .center
            badge.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(badge)

            NSLayoutConstraint.activate([
                badge.topAnchor.constraint(equalTo: card.topAnchor, constant: -10),
                badge.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                badge.widthAnchor.constraint(equalToConstant: 70),
                badge.heightAnchor.constraint(equalToConstant: 22)
            ])
        }

        // 아이콘
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 32)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        // 플랜 이름
        let nameLabel = createTitleLabel(name, fontSize: 20)

        // 가격
        let priceLabel = UILabel()
        priceLabel.text = "₩\(formatPrice(monthlyPrice))"
        priceLabel.font = UIFont.boldSystemFont(ofSize: 28)
        priceLabel.textColor = isPopular ? primaryColor : UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1)
        priceLabel.tag = 100 // 가격 업데이트용 태그
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        let periodLabel = createSubtitleLabel("/월")

        // 기능 목록
        let featuresStack = UIStackView()
        featuresStack.axis = .vertical
        featuresStack.spacing = 8
        featuresStack.translatesAutoresizingMaskIntoConstraints = false

        for feature in features {
            let featureRow = createFeatureRow(feature)
            featuresStack.addArrangedSubview(featureRow)
        }

        // 선택 버튼
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("\(name) 시작하기", for: .normal)
        selectButton.setTitleColor(isPopular ? .white : UIColor(red: 71/255, green: 85/255, blue: 105/255, alpha: 1), for: .normal)
        selectButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        selectButton.backgroundColor = isPopular ? primaryColor : UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1)
        selectButton.layer.cornerRadius = 10
        selectButton.tag = planKey.hashValue
        selectButton.addTarget(self, action: #selector(planButtonTapped(_:)), for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false

        // 플랜 키 저장
        selectButton.accessibilityIdentifier = planKey

        card.addSubview(iconLabel)
        card.addSubview(nameLabel)
        card.addSubview(priceLabel)
        card.addSubview(periodLabel)
        card.addSubview(featuresStack)
        card.addSubview(selectButton)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: isPopular ? 24 : 20),
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),

            periodLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 4),
            periodLabel.bottomAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: -4),

            featuresStack.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            featuresStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            featuresStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            selectButton.topAnchor.constraint(equalTo: featuresStack.bottomAnchor, constant: 20),
            selectButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            selectButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            selectButton.heightAnchor.constraint(equalToConstant: 48),
            selectButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])

        return card
    }

    func createFeatureRow(_ text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UILabel()
        checkmark.text = "✓"
        checkmark.font = UIFont.boldSystemFont(ofSize: 14)
        checkmark.textColor = UIColor(red: 34/255, green: 197/255, blue: 94/255, alpha: 1)
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        let label = createSubtitleLabel(text)
        label.textColor = UIColor(red: 71/255, green: 85/255, blue: 105/255, alpha: 1)

        container.addSubview(checkmark)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            checkmark.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            checkmark.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            label.leadingAnchor.constraint(equalTo: checkmark.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            container.heightAnchor.constraint(equalToConstant: 24)
        ])

        return container
    }

    func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    @objc func billingToggleChanged() {
        isYearlyBilling = billingToggle.isOn
        updatePrices()
    }

    func updatePrices() {
        // 각 카드의 가격 라벨 업데이트
        updateCardPrice(starterCard, planKey: "starter")
        updateCardPrice(proCard, planKey: "pro")
        updateCardPrice(enterpriseCard, planKey: "enterprise")
    }

    func updateCardPrice(_ card: UIView, planKey: String) {
        guard let planInfo = PLAN_INFO[planKey] as? [String: Any],
              let monthlyPrice = planInfo["monthly_price"] as? Int,
              let yearlyPrice = planInfo["yearly_price"] as? Int,
              let priceLabel = card.viewWithTag(100) as? UILabel else {
            return
        }

        let price = isYearlyBilling ? yearlyPrice : monthlyPrice
        priceLabel.text = "₩\(formatPrice(price))"
    }

    func updateCardSelection() {
        // 선택 상태 업데이트
        starterCard.layer.borderColor = selectedPlan == "starter" ? primaryColor.cgColor : UIColor.clear.cgColor
        starterCard.layer.borderWidth = selectedPlan == "starter" ? 2 : 0

        proCard.layer.borderColor = primaryColor.cgColor
        proCard.layer.borderWidth = 2

        enterpriseCard.layer.borderColor = selectedPlan == "enterprise" ? primaryColor.cgColor : UIColor.clear.cgColor
        enterpriseCard.layer.borderWidth = selectedPlan == "enterprise" ? 2 : 0
    }

    @objc func planButtonTapped(_ sender: UIButton) {
        guard let planKey = sender.accessibilityIdentifier else { return }

        if planKey == "enterprise" {
            let alert = UIAlertController(
                title: "Enterprise 플랜",
                message: "Enterprise 플랜은 영업팀으로 문의해 주세요.\n이메일: sales@cloudsync.example.com",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }

        selectedPlan = planKey
        updateCardSelection()
        startPayment()
    }

    override func startPayment() {
        let clientKey = BootpayConfig.clientKey
        guard !clientKey.isEmpty,
              let plans = ENV_PLANS[currentEnv],
              let planConfig = plans[selectedPlan],
              let planInfo = PLAN_INFO[selectedPlan] as? [String: Any],
              let planName = planInfo["name"] as? String,
              let monthlyPrice = planInfo["monthly_price"] as? Int,
              let yearlyPrice = planInfo["yearly_price"] as? Int else {
            print("[CommerceExample] Configuration error - check Config.xcconfig")
            return
        }

        let productId = isYearlyBilling ? planConfig["yearly_product_id"] : planConfig["monthly_product_id"]
        let billingType = isYearlyBilling ? "연간" : "월간"
        let price = isYearlyBilling ? yearlyPrice : monthlyPrice

        guard let productId = productId else { return }

        print("[CommerceExample] 환경: \(currentEnv), 플랜: \(selectedPlan), 상품ID: \(productId)")

        // CommercePayload 생성
        let payload = CommercePayload()
        payload.clientKey = clientKey
        payload.name = "CloudSync Pro \(planName) 플랜"
        payload.memo = "\(billingType) 구독 결제"
        payload.price = Double(price)
        payload.redirectUrl = "https://api.bootpay.co.kr/v2/callback"
        // usage_api_url 설정 (commerce-example과 동일)
        payload.usageApiUrl = currentEnv == "production"
            ? "https://api.bootapi.com/v1/billing/usage"
            : "https://dev-api.bootapi.com/v1/billing/usage"
        payload.requestId = "order_\(Int(Date().timeIntervalSince1970))"
        payload.useAutoLogin = true
        payload.useNotification = true

        // 사용자 정보
        let user = CommerceUser()
        user.membershipType = "guest"
        user.userId = "demo_user_1234"
        user.name = "데모 사용자"
        user.phone = "01040334678"
        user.email = "demo@example.com"
        payload.user = user

        // 상품 정보
        let product = CommerceProduct()
        product.productId = productId
        product.duration = -1  // 무기한 구독
        product.quantity = 1
        payload.products = [product]

        // 메타데이터 (commerce-example과 동일)
        let orderId = payload.requestId ?? "order_\(Int(Date().timeIntervalSince1970))"
        payload.metadata = [
            "order_id": orderId,
            "plan_key": selectedPlan,
            "billing_type": billingType,
            "env": currentEnv,
            "selected_at": ISO8601DateFormatter().string(from: Date())
        ]

        // Extra 옵션 (commerce-example과 동일)
        let extra = CommerceExtra()
        extra.separatelyConfirmed = false
        extra.createOrderImmediately = true
        payload.extra = extra

        // 환경 설정
        // BootpayCommerce.setEnvironmentMode(currentEnv)

        // 결제 요청
        BootpayCommerce.requestCheckout(
            viewController: self,
            payload: payload,
            isModal: true
        )
        .onDone { data in
            print("-- Commerce done: \(data)")
            self.showPaymentResult(data: data)
        }
        .onError { data in
            print("-- Commerce error: \(data)")
            self.showPaymentResult(data: data)
        }
        .onCancel { data in
            print("-- Commerce cancel: \(data)")
            self.showPaymentResult(data: data)
        }
        .onClose {
            print("-- Commerce close")
        }
    }

    /// 결제 결과 화면으로 이동
    private func showPaymentResult(data: [String: Any]) {
        let resultVC = PaymentResultController()
        resultVC.paymentData = data
        navigationController?.pushViewController(resultVC, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
