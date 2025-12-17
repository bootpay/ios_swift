//
//  SubscriptionController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class SubscriptionController: BasePaymentController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "프리미엄 구독"
    }

    override func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // 헤더 아이콘
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor(red: 102/255, green: 16/255, blue: 242/255, alpha: 0.1)
        iconContainer.layer.cornerRadius = 40
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let crownIcon = createImagePlaceholder(systemName: "crown.fill", size: 40)
        crownIcon.tintColor = UIColor(red: 102/255, green: 16/255, blue: 242/255, alpha: 1)

        // 타이틀
        let titleLabel = createTitleLabel("Premium 멤버십", fontSize: 28)
        titleLabel.textAlignment = .center

        let subtitleLabel = createSubtitleLabel("더 많은 혜택을 누려보세요")
        subtitleLabel.textAlignment = .center

        // 가격 카드
        let priceCard = createCardView()
        priceCard.layer.borderWidth = 2
        priceCard.layer.borderColor = UIColor(red: 102/255, green: 16/255, blue: 242/255, alpha: 1).cgColor

        let priceLabel = createPriceLabel("₩1,000")
        priceLabel.textColor = UIColor(red: 102/255, green: 16/255, blue: 242/255, alpha: 1)
        let periodLabel = createSubtitleLabel("/ 월")

        let bestBadge = UILabel()
        bestBadge.text = "BEST"
        bestBadge.font = UIFont.boldSystemFont(ofSize: 12)
        bestBadge.textColor = .white
        bestBadge.backgroundColor = UIColor(red: 102/255, green: 16/255, blue: 242/255, alpha: 1)
        bestBadge.layer.cornerRadius = 4
        bestBadge.clipsToBounds = true
        bestBadge.textAlignment = .center
        bestBadge.translatesAutoresizingMaskIntoConstraints = false

        // 혜택 목록 카드
        let benefitsCard = createCardView()
        let benefitsTitle = createTitleLabel("구독 혜택", fontSize: 18)

        let benefit1 = createBenefitRow(icon: "checkmark.circle.fill", text: "무제한 콘텐츠 이용")
        let benefit2 = createBenefitRow(icon: "checkmark.circle.fill", text: "광고 없는 서비스")
        let benefit3 = createBenefitRow(icon: "checkmark.circle.fill", text: "오프라인 다운로드")
        let benefit4 = createBenefitRow(icon: "checkmark.circle.fill", text: "프리미엄 고객 지원")

        // 구독 버튼
        let subscribeButton = createActionButton("구독 시작하기", color: UIColor(red: 102/255, green: 16/255, blue: 242/255, alpha: 1))
        subscribeButton.addTarget(self, action: #selector(onSubscribeButtonTapped), for: .touchUpInside)

        // 안내 문구
        let noticeLabel = createSubtitleLabel("언제든지 구독을 취소할 수 있습니다")
        noticeLabel.textAlignment = .center
        noticeLabel.font = UIFont.systemFont(ofSize: 12)

        // Add subviews
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(crownIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(priceCard)
        priceCard.addSubview(priceLabel)
        priceCard.addSubview(periodLabel)
        priceCard.addSubview(bestBadge)
        contentView.addSubview(benefitsCard)
        benefitsCard.addSubview(benefitsTitle)
        benefitsCard.addSubview(benefit1)
        benefitsCard.addSubview(benefit2)
        benefitsCard.addSubview(benefit3)
        benefitsCard.addSubview(benefit4)
        contentView.addSubview(subscribeButton)
        contentView.addSubview(noticeLabel)

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

            iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            iconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 80),
            iconContainer.heightAnchor.constraint(equalToConstant: 80),

            crownIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            crownIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            priceCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            priceCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            priceCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            priceLabel.topAnchor.constraint(equalTo: priceCard.topAnchor, constant: 20),
            priceLabel.centerXAnchor.constraint(equalTo: priceCard.centerXAnchor, constant: -15),
            priceLabel.bottomAnchor.constraint(equalTo: priceCard.bottomAnchor, constant: -20),

            periodLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 4),
            periodLabel.bottomAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: -4),

            bestBadge.topAnchor.constraint(equalTo: priceCard.topAnchor, constant: 12),
            bestBadge.trailingAnchor.constraint(equalTo: priceCard.trailingAnchor, constant: -12),
            bestBadge.widthAnchor.constraint(equalToConstant: 50),
            bestBadge.heightAnchor.constraint(equalToConstant: 24),

            benefitsCard.topAnchor.constraint(equalTo: priceCard.bottomAnchor, constant: 16),
            benefitsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            benefitsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            benefitsTitle.topAnchor.constraint(equalTo: benefitsCard.topAnchor, constant: 20),
            benefitsTitle.leadingAnchor.constraint(equalTo: benefitsCard.leadingAnchor, constant: 20),

            benefit1.topAnchor.constraint(equalTo: benefitsTitle.bottomAnchor, constant: 16),
            benefit1.leadingAnchor.constraint(equalTo: benefitsCard.leadingAnchor, constant: 20),
            benefit1.trailingAnchor.constraint(equalTo: benefitsCard.trailingAnchor, constant: -20),

            benefit2.topAnchor.constraint(equalTo: benefit1.bottomAnchor, constant: 12),
            benefit2.leadingAnchor.constraint(equalTo: benefitsCard.leadingAnchor, constant: 20),
            benefit2.trailingAnchor.constraint(equalTo: benefitsCard.trailingAnchor, constant: -20),

            benefit3.topAnchor.constraint(equalTo: benefit2.bottomAnchor, constant: 12),
            benefit3.leadingAnchor.constraint(equalTo: benefitsCard.leadingAnchor, constant: 20),
            benefit3.trailingAnchor.constraint(equalTo: benefitsCard.trailingAnchor, constant: -20),

            benefit4.topAnchor.constraint(equalTo: benefit3.bottomAnchor, constant: 12),
            benefit4.leadingAnchor.constraint(equalTo: benefitsCard.leadingAnchor, constant: 20),
            benefit4.trailingAnchor.constraint(equalTo: benefitsCard.trailingAnchor, constant: -20),
            benefit4.bottomAnchor.constraint(equalTo: benefitsCard.bottomAnchor, constant: -20),

            subscribeButton.topAnchor.constraint(equalTo: benefitsCard.bottomAnchor, constant: 24),
            subscribeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subscribeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            subscribeButton.heightAnchor.constraint(equalToConstant: 56),

            noticeLabel.topAnchor.constraint(equalTo: subscribeButton.bottomAnchor, constant: 12),
            noticeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            noticeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    func createBenefitRow(icon: String, text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = createImagePlaceholder(systemName: icon, size: 20)
        iconView.tintColor = UIColor(red: 40/255, green: 167/255, blue: 69/255, alpha: 1)

        let label = createSubtitleLabel(text)
        label.textColor = UIColor(red: 52/255, green: 58/255, blue: 64/255, alpha: 1)

        container.addSubview(iconView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            container.heightAnchor.constraint(equalToConstant: 24)
        ])

        return container
    }

    @objc func onSubscribeButtonTapped() {
        startPayment()
    }

    override func startPayment() {
        let payload = generatePayload()
        payload.pg = "나이스페이"
        payload.method = "카드자동"

        Bootpay.requestSubscription(viewController: self, payload: payload)
        .onCancel { data in
            print("-- cancel: \(data)")
        }
        .onIssued { data in
            print("-- ready: \(data)")
        }
        .onConfirm { data in
            print("-- confirm: \(data)")
            return true
        }
        .onDone { data in
            print("-- done: \(data)")
        }
        .onError { data in
            print("-- error: \(data)")
        }
        .onClose {
            print("-- close")
        }
    }
}
