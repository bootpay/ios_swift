//
//  AuthenticationController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class AuthenticationController: BasePaymentController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "본인인증"
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
        iconContainer.backgroundColor = UIColor(red: 23/255, green: 162/255, blue: 184/255, alpha: 0.1)
        iconContainer.layer.cornerRadius = 50
        iconContainer.translatesAutoresizingMaskIntoConstraints = false

        let shieldIcon = createImagePlaceholder(systemName: "person.badge.shield.checkmark.fill", size: 50)
        shieldIcon.tintColor = UIColor(red: 23/255, green: 162/255, blue: 184/255, alpha: 1)

        // 타이틀
        let titleLabel = createTitleLabel("본인인증이 필요합니다", fontSize: 24)
        titleLabel.textAlignment = .center

        let subtitleLabel = createSubtitleLabel("서비스 이용을 위해 본인인증을 진행해 주세요")
        subtitleLabel.textAlignment = .center

        // 안내 카드
        let infoCard = createCardView()
        let infoTitle = createTitleLabel("인증 안내", fontSize: 18)

        let info1 = createInfoRow(icon: "checkmark.shield.fill", text: "휴대폰 본인인증으로 진행됩니다")
        let info2 = createInfoRow(icon: "lock.shield.fill", text: "입력하신 정보는 안전하게 보호됩니다")
        let info3 = createInfoRow(icon: "clock.fill", text: "인증은 약 1분 정도 소요됩니다")

        // 주의사항 카드
        let noticeCard = createCardView()
        noticeCard.backgroundColor = UIColor(red: 255/255, green: 243/255, blue: 205/255, alpha: 1)

        let warningIcon = createImagePlaceholder(systemName: "exclamationmark.triangle.fill", size: 20)
        warningIcon.tintColor = UIColor(red: 133/255, green: 100/255, blue: 4/255, alpha: 1)

        let noticeText = createSubtitleLabel("본인 명의의 휴대폰으로만 인증이 가능합니다.\n타인의 명의로는 인증할 수 없습니다.")
        noticeText.textColor = UIColor(red: 133/255, green: 100/255, blue: 4/255, alpha: 1)
        noticeText.font = UIFont.systemFont(ofSize: 13)

        // 인증하기 버튼
        let authButton = createActionButton("본인인증 시작", color: UIColor(red: 23/255, green: 162/255, blue: 184/255, alpha: 1))
        authButton.addTarget(self, action: #selector(onAuthButtonTapped), for: .touchUpInside)

        // Add subviews
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(shieldIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(infoCard)
        infoCard.addSubview(infoTitle)
        infoCard.addSubview(info1)
        infoCard.addSubview(info2)
        infoCard.addSubview(info3)
        contentView.addSubview(noticeCard)
        noticeCard.addSubview(warningIcon)
        noticeCard.addSubview(noticeText)
        contentView.addSubview(authButton)

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

            iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            iconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 100),
            iconContainer.heightAnchor.constraint(equalToConstant: 100),

            shieldIcon.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            shieldIcon.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            infoCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            infoTitle.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            infoTitle.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),

            info1.topAnchor.constraint(equalTo: infoTitle.bottomAnchor, constant: 16),
            info1.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            info1.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),

            info2.topAnchor.constraint(equalTo: info1.bottomAnchor, constant: 12),
            info2.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            info2.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),

            info3.topAnchor.constraint(equalTo: info2.bottomAnchor, constant: 12),
            info3.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            info3.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            info3.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20),

            noticeCard.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 16),
            noticeCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            noticeCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            warningIcon.topAnchor.constraint(equalTo: noticeCard.topAnchor, constant: 16),
            warningIcon.leadingAnchor.constraint(equalTo: noticeCard.leadingAnchor, constant: 16),
            warningIcon.widthAnchor.constraint(equalToConstant: 20),
            warningIcon.heightAnchor.constraint(equalToConstant: 20),

            noticeText.topAnchor.constraint(equalTo: noticeCard.topAnchor, constant: 16),
            noticeText.leadingAnchor.constraint(equalTo: warningIcon.trailingAnchor, constant: 12),
            noticeText.trailingAnchor.constraint(equalTo: noticeCard.trailingAnchor, constant: -16),
            noticeText.bottomAnchor.constraint(equalTo: noticeCard.bottomAnchor, constant: -16),

            authButton.topAnchor.constraint(equalTo: noticeCard.bottomAnchor, constant: 32),
            authButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authButton.heightAnchor.constraint(equalToConstant: 56),
            authButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    func createInfoRow(icon: String, text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = createImagePlaceholder(systemName: icon, size: 18)
        iconView.tintColor = UIColor(red: 23/255, green: 162/255, blue: 184/255, alpha: 1)

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
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            container.heightAnchor.constraint(equalToConstant: 24)
        ])

        return container
    }

    @objc func onAuthButtonTapped() {
        startPayment()
    }

    override func startPayment() {
        let payload = generatePayload()
        payload.pg = "다날"
        payload.method = "본인인증"

        Bootpay.requestAuthentication(viewController: self, payload: payload)
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
