//
//  PaymentResultController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2024/12/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class PaymentResultController: UIViewController {

    // MARK: - Properties

    var paymentData: [String: Any]?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let cardView = UIView()
    private let statusImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let detailStackView = UIStackView()
    private let confirmButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "결제 결과"
        self.view.backgroundColor = .systemBackground
        self.navigationItem.hidesBackButton = true

        setupUI()
        displayResult()
    }

    // MARK: - Setup

    private func setupUI() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Content View
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Card View (결과 카드)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12
        contentView.addSubview(cardView)

        // Status Image
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        cardView.addSubview(statusImageView)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        cardView.addSubview(titleLabel)

        // Message Label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        cardView.addSubview(messageLabel)

        // Detail Stack View
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.axis = .vertical
        detailStackView.spacing = 16
        detailStackView.backgroundColor = .tertiarySystemBackground
        detailStackView.layer.cornerRadius = 12
        detailStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        detailStackView.isLayoutMarginsRelativeArrangement = true
        cardView.addSubview(detailStackView)

        // Confirm Button
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 14
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        view.addSubview(confirmButton)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            statusImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 40),
            statusImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 80),
            statusImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: statusImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),

            detailStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            detailStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            detailStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            detailStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func displayResult() {
        guard let data = paymentData else {
            showError()
            return
        }

        // Commerce 응답 형식 확인 (event 필드가 있으면 Commerce)
        if let event = data["event"] as? String {
            displayCommerceResult(data: data, event: event)
            return
        }

        // Widget/일반 결제 응답 형식
        guard let innerData = data["data"] as? [String: Any] else {
            showError()
            return
        }

        let status = innerData["status"] as? Int ?? 0

        if status == 1 {
            // 결제 성공
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = .systemGreen
            titleLabel.text = "결제 완료"
            messageLabel.text = "결제가 성공적으로 완료되었습니다."
        } else {
            // 결제 실패
            statusImageView.image = UIImage(systemName: "xmark.circle.fill")
            statusImageView.tintColor = .systemRed
            titleLabel.text = "결제 실패"
            messageLabel.text = "결제 처리 중 문제가 발생했습니다."
        }

        // 상세 정보 표시
        addDetailRow(title: "주문명", value: innerData["order_name"] as? String ?? "-")
        addDetailRow(title: "결제금액", value: formatPrice(innerData["price"] as? Int ?? 0))
        addDetailRow(title: "결제수단", value: innerData["method"] as? String ?? "-")
        addDetailRow(title: "PG사", value: innerData["pg"] as? String ?? "-")
        addDetailRow(title: "주문번호", value: innerData["order_id"] as? String ?? "\(innerData["order_id"] ?? "-")")
        addDetailRow(title: "영수증 ID", value: innerData["receipt_id"] as? String ?? "-")

        if let purchasedAt = innerData["purchased_at"] as? String {
            addDetailRow(title: "결제일시", value: formatDate(purchasedAt))
        }
    }

    /// Commerce 결과 표시
    private func displayCommerceResult(data: [String: Any], event: String) {
        switch event {
        case "done":
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = .systemGreen
            titleLabel.text = "구독 신청 완료"
            messageLabel.text = "구독이 성공적으로 시작되었습니다."
            confirmButton.backgroundColor = .systemGreen

        case "issued":
            statusImageView.image = UIImage(systemName: "building.columns.circle.fill")
            statusImageView.tintColor = .systemBlue
            titleLabel.text = "가상계좌 발급 완료"
            messageLabel.text = data["message"] as? String ?? "가상계좌가 발급되었습니다.\n입금 후 자동으로 구독이 시작됩니다."
            confirmButton.backgroundColor = .systemBlue

        case "cancel":
            statusImageView.image = UIImage(systemName: "arrow.uturn.backward.circle.fill")
            statusImageView.tintColor = .systemOrange
            titleLabel.text = "결제 취소"
            messageLabel.text = data["message"] as? String ?? "결제가 취소되었습니다."
            confirmButton.backgroundColor = .systemOrange

        case "error":
            statusImageView.image = UIImage(systemName: "exclamationmark.circle.fill")
            statusImageView.tintColor = .systemRed
            titleLabel.text = "결제 실패"
            messageLabel.text = data["message"] as? String ?? "결제 처리 중 오류가 발생했습니다."
            confirmButton.backgroundColor = .systemRed

        default:
            showError()
            return
        }

        // Commerce 상세 정보 표시
        if let orderNumber = data["order_number"] as? String {
            addDetailRow(title: "주문번호", value: orderNumber)
        }
        if let requestId = data["request_id"] as? String {
            addDetailRow(title: "요청 ID", value: requestId)
        }
        if let receiptId = data["receipt_id"] as? String {
            addDetailRow(title: "영수증 ID", value: receiptId)
        }

        // 가상계좌 정보 표시 (issued 이벤트)
        if event == "issued" {
            if let bankName = data["bankname"] as? String {
                addDetailRow(title: "입금 은행", value: bankName)
            }
            if let account = data["account"] as? String {
                addDetailRow(title: "계좌번호", value: account)
            }
            if let accountHolder = data["accounthodler"] as? String {
                addDetailRow(title: "예금주", value: accountHolder)
            }
            if let expireDate = data["expiredate"] as? String {
                addDetailRow(title: "입금 기한", value: formatExpireDate(expireDate))
            }
            if let price = data["price"] as? Int {
                addDetailRow(title: "입금 금액", value: formatPrice(price))
            }
        }

        // metadata 표시
        if let metadata = data["metadata"] as? [String: Any] {
            if let planKey = metadata["plan_key"] as? String {
                addDetailRow(title: "플랜", value: planKey.capitalized)
            }
            if let billingType = metadata["billing_type"] as? String {
                addDetailRow(title: "결제 주기", value: billingType)
            }
        }
    }

    private func showError() {
        statusImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        statusImageView.tintColor = .systemOrange
        titleLabel.text = "결과 확인 불가"
        messageLabel.text = "결제 결과를 확인할 수 없습니다."
    }

    private func addDetailRow(title: String, value: String) {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.text = value
        valueLabel.numberOfLines = 0

        rowView.addSubview(titleLabel)
        rowView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),

            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: rowView.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
            valueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])

        detailStackView.addArrangedSubview(rowView)
    }

    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: price)) ?? "\(price)") + "원"
    }

    private func formatDate(_ dateString: String) -> String {
        // ISO 8601 형식을 간단한 형식으로 변환
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            outputFormatter.locale = Locale(identifier: "ko_KR")
            return outputFormatter.string(from: date)
        }
        return dateString
    }

    private func formatExpireDate(_ dateString: String) -> String {
        // 가상계좌 만료일 형식: "2021-01-17 00:00:00"
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "ko_KR")

        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy년 MM월 dd일 HH:mm까지"
            outputFormatter.locale = Locale(identifier: "ko_KR")
            return outputFormatter.string(from: date)
        }
        return dateString
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        // 메인 화면으로 돌아가기 (root로 pop)
        navigationController?.popToRootViewController(animated: true)
    }
}
