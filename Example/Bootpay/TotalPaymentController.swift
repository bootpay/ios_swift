//
//  TotalPaymentController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class TotalPaymentController: BasePaymentController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "주문/결제"
    }

    override func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // 주문 상품 카드
        let orderCard = createCardView()
        let orderTitle = createTitleLabel("주문 상품", fontSize: 18)

        // 상품 1
        let item1View = createCartItemView(
            icon: "tshirt.fill",
            name: "프리미엄 코튼 티셔츠",
            option: "White / M",
            qty: "1개",
            price: "₩500"
        )

        // 상품 2
        let item2View = createCartItemView(
            icon: "jacket.fill",
            name: "데님 청자켓",
            option: "Blue / L",
            qty: "2개",
            price: "₩500"
        )

        // 구분선
        let divider1 = createDivider()

        // 결제 정보 카드
        let paymentCard = createCardView()
        let paymentTitle = createTitleLabel("결제 정보", fontSize: 18)

        let subtotalRow = createPriceRow("상품 금액", "₩1,000")
        let shippingRow = createPriceRow("배송비", "무료")
        let divider2 = createDivider()
        let totalRow = createPriceRow("총 결제 금액", "₩1,000", isBold: true)

        // 결제 버튼
        let payButton = createActionButton("₩1,000 결제하기", color: UIColor(red: 40/255, green: 167/255, blue: 69/255, alpha: 1))
        payButton.addTarget(self, action: #selector(onPayButtonTapped), for: .touchUpInside)

        // Add subviews
        contentView.addSubview(orderCard)
        orderCard.addSubview(orderTitle)
        orderCard.addSubview(item1View)
        orderCard.addSubview(item2View)

        contentView.addSubview(paymentCard)
        paymentCard.addSubview(paymentTitle)
        paymentCard.addSubview(subtotalRow)
        paymentCard.addSubview(shippingRow)
        paymentCard.addSubview(divider2)
        paymentCard.addSubview(totalRow)

        contentView.addSubview(payButton)

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

            // Order Card
            orderCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            orderCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            orderCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            orderTitle.topAnchor.constraint(equalTo: orderCard.topAnchor, constant: 20),
            orderTitle.leadingAnchor.constraint(equalTo: orderCard.leadingAnchor, constant: 20),

            item1View.topAnchor.constraint(equalTo: orderTitle.bottomAnchor, constant: 16),
            item1View.leadingAnchor.constraint(equalTo: orderCard.leadingAnchor, constant: 20),
            item1View.trailingAnchor.constraint(equalTo: orderCard.trailingAnchor, constant: -20),

            item2View.topAnchor.constraint(equalTo: item1View.bottomAnchor, constant: 12),
            item2View.leadingAnchor.constraint(equalTo: orderCard.leadingAnchor, constant: 20),
            item2View.trailingAnchor.constraint(equalTo: orderCard.trailingAnchor, constant: -20),
            item2View.bottomAnchor.constraint(equalTo: orderCard.bottomAnchor, constant: -20),

            // Payment Card
            paymentCard.topAnchor.constraint(equalTo: orderCard.bottomAnchor, constant: 16),
            paymentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            paymentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            paymentTitle.topAnchor.constraint(equalTo: paymentCard.topAnchor, constant: 20),
            paymentTitle.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 20),

            subtotalRow.topAnchor.constraint(equalTo: paymentTitle.bottomAnchor, constant: 16),
            subtotalRow.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 20),
            subtotalRow.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -20),

            shippingRow.topAnchor.constraint(equalTo: subtotalRow.bottomAnchor, constant: 8),
            shippingRow.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 20),
            shippingRow.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -20),

            divider2.topAnchor.constraint(equalTo: shippingRow.bottomAnchor, constant: 12),
            divider2.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 20),
            divider2.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -20),
            divider2.heightAnchor.constraint(equalToConstant: 1),

            totalRow.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 12),
            totalRow.leadingAnchor.constraint(equalTo: paymentCard.leadingAnchor, constant: 20),
            totalRow.trailingAnchor.constraint(equalTo: paymentCard.trailingAnchor, constant: -20),
            totalRow.bottomAnchor.constraint(equalTo: paymentCard.bottomAnchor, constant: -20),

            // Pay Button
            payButton.topAnchor.constraint(equalTo: paymentCard.bottomAnchor, constant: 24),
            payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 56),
            payButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    func createCartItemView(icon: String, name: String, option: String, qty: String, price: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = UIColor(red: 248/255, green: 249/255, blue: 250/255, alpha: 1)
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iconView = createImagePlaceholder(systemName: icon, size: 24)

        let nameLabel = createTitleLabel(name, fontSize: 16)
        let optionLabel = createSubtitleLabel("\(option) | \(qty)")
        let priceLabel = createTitleLabel(price, fontSize: 16)

        container.addSubview(iconBg)
        iconBg.addSubview(iconView)
        container.addSubview(nameLabel)
        container.addSubview(optionLabel)
        container.addSubview(priceLabel)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            iconBg.topAnchor.constraint(equalTo: container.topAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 50),
            iconBg.heightAnchor.constraint(equalToConstant: 50),
            iconBg.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),

            optionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            optionLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            optionLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            priceLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }

    func createPriceRow(_ label: String, _ value: String, isBold: Bool = false) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let labelView = isBold ? createTitleLabel(label, fontSize: 16) : createSubtitleLabel(label)
        let valueView = isBold ? createTitleLabel(value, fontSize: 18) : createSubtitleLabel(value)

        container.addSubview(labelView)
        container.addSubview(valueView)

        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            container.heightAnchor.constraint(equalToConstant: 24)
        ])

        return container
    }

    func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor(red: 233/255, green: 236/255, blue: 239/255, alpha: 1)
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }

    @objc func onPayButtonTapped() {
        startPayment()
    }

    override func generatePayload() -> Payload {
        let payload = super.generatePayload()
        // 통합결제는 method/methods 를 지정하지 않는다 — 결제수단 선택 UI 가 직접 노출됨
        payload.method = nil
        payload.methods = nil
        return payload
    }

    override func startPayment() {
        let payload = generatePayload()

        Bootpay.requestPayment(
            viewController: self,
            payload: payload)
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

    private func showPaymentResult(data: [String: Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            let resultVC = PaymentResultController()
            resultVC.paymentData = data
            self?.navigationController?.pushViewController(resultVC, animated: true)
        }
    }
}
