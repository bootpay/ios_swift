//
//  PgPaymentController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class PgPaymentController: BasePaymentController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "상품 상세"
    }

    override func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // 상품 이미지 영역
        let imageContainer = UIView()
        imageContainer.backgroundColor = UIColor(red: 233/255, green: 236/255, blue: 239/255, alpha: 1)
        imageContainer.translatesAutoresizingMaskIntoConstraints = false

        let productImage = createImagePlaceholder(systemName: "tshirt.fill", size: 100)
        imageContainer.addSubview(productImage)

        // 상품 정보 카드
        let infoCard = createCardView()

        let productName = createTitleLabel("프리미엄 코튼 티셔츠", fontSize: 22)
        let productDesc = createSubtitleLabel("부드러운 100% 오가닉 코튼 소재로 제작된 프리미엄 티셔츠입니다. 편안한 착용감과 세련된 디자인이 특징입니다.")
        let priceLabel = createPriceLabel("₩1,000")
        let originalPrice = createSubtitleLabel("₩1,500")

        // 취소선 추가
        let attributeString = NSMutableAttributedString(string: "₩1,500")
        attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        originalPrice.attributedText = attributeString

        // 구분선
        let divider = UIView()
        divider.backgroundColor = UIColor(red: 233/255, green: 236/255, blue: 239/255, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false

        // 배송 정보
        let shippingIcon = createImagePlaceholder(systemName: "shippingbox.fill", size: 20)
        let shippingLabel = createSubtitleLabel("무료배송 | 내일 도착 예정")

        // 구매 버튼
        let buyButton = createActionButton("구매하기 (client_key)", color: UIColor(red: 0/255, green: 123/255, blue: 255/255, alpha: 1))
        buyButton.addTarget(self, action: #selector(onBuyButtonTapped), for: .touchUpInside)
        let legacyButton = createActionButton("레거시 결제 (application_id)", color: UIColor(red: 108/255, green: 117/255, blue: 125/255, alpha: 1))
        legacyButton.addTarget(self, action: #selector(onLegacyButtonTapped), for: .touchUpInside)
        let missingKeyButton = createActionButton("키 없음 테스트 (NEED_CLIENT_KEY)", color: UIColor(red: 220/255, green: 53/255, blue: 69/255, alpha: 1))
        missingKeyButton.addTarget(self, action: #selector(onMissingKeyButtonTapped), for: .touchUpInside)

        // Add subviews
        contentView.addSubview(imageContainer)
        contentView.addSubview(infoCard)
        infoCard.addSubview(productName)
        infoCard.addSubview(productDesc)
        infoCard.addSubview(priceLabel)
        infoCard.addSubview(originalPrice)
        infoCard.addSubview(divider)
        infoCard.addSubview(shippingIcon)
        infoCard.addSubview(shippingLabel)
        contentView.addSubview(buyButton)
        contentView.addSubview(legacyButton)
        contentView.addSubview(missingKeyButton)

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

            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageContainer.heightAnchor.constraint(equalToConstant: 280),

            productImage.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            productImage.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),

            infoCard.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 16),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            productName.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            productName.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            productName.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),

            productDesc.topAnchor.constraint(equalTo: productName.bottomAnchor, constant: 8),
            productDesc.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            productDesc.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),

            priceLabel.topAnchor.constraint(equalTo: productDesc.bottomAnchor, constant: 16),
            priceLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),

            originalPrice.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            originalPrice.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 8),

            divider.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 16),
            divider.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            divider.heightAnchor.constraint(equalToConstant: 1),

            shippingIcon.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            shippingIcon.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            shippingIcon.widthAnchor.constraint(equalToConstant: 20),
            shippingIcon.heightAnchor.constraint(equalToConstant: 20),
            shippingIcon.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -20),

            shippingLabel.centerYAnchor.constraint(equalTo: shippingIcon.centerYAnchor),
            shippingLabel.leadingAnchor.constraint(equalTo: shippingIcon.trailingAnchor, constant: 8),

            buyButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 24),
            buyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            buyButton.heightAnchor.constraint(equalToConstant: 56),

            legacyButton.topAnchor.constraint(equalTo: buyButton.bottomAnchor, constant: 12),
            legacyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            legacyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            legacyButton.heightAnchor.constraint(equalToConstant: 56),

            missingKeyButton.topAnchor.constraint(equalTo: legacyButton.bottomAnchor, constant: 12),
            missingKeyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            missingKeyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            missingKeyButton.heightAnchor.constraint(equalToConstant: 56),
            missingKeyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    @objc func onBuyButtonTapped() {
        paymentAuthMode = .clientKey
        startPayment()
    }

    @objc func onLegacyButtonTapped() {
        paymentAuthMode = .legacyApplicationId
        startPayment()
    }

    @objc func onMissingKeyButtonTapped() {
        paymentAuthMode = .missingKey
        startPayment()
    }

    override func startPayment() {
        let payload = generatePayload()
        payload.method = "카드"

        if #available(iOS 13.0, *) {
            Bootpay.requestPayment(
                viewController: self,
                payload: payload,
                isModal: true,
                modalPresentationStyle: .automatic,
                animated: true)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onIssued { data in
                print("-- issued: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true
            }
            .onDone { [weak self] data in
                print("-- done: \(data)")
                self?.showPaymentResult(data: data)
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("-- close")
            }
        }
    }

    private func showPaymentResult(data: [String: Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            let resultVC = PaymentResultController()
            resultVC.paymentData = data
            self?.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}
