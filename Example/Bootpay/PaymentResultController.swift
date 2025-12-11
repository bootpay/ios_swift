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
    private let statusImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let detailStackView = UIStackView()
    private let confirmButton = UIButton(type: .system)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "결제 결과"
        self.view.backgroundColor = .white
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

        // Status Image
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit
        statusImageView.tintColor = .systemGreen
        contentView.addSubview(statusImageView)

        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        // Message Label
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .darkGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        contentView.addSubview(messageLabel)

        // Detail Stack View
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.axis = .vertical
        detailStackView.spacing = 12
        detailStackView.backgroundColor = .systemGray6
        detailStackView.layer.cornerRadius = 12
        detailStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        detailStackView.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(detailStackView)

        // Confirm Button
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 10
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

            statusImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            statusImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            statusImageView.widthAnchor.constraint(equalToConstant: 80),
            statusImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: statusImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            detailStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 30),
            detailStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func displayResult() {
        guard let data = paymentData,
              let innerData = data["data"] as? [String: Any] else {
            showError()
            return
        }

        let status = innerData["status"] as? Int ?? 0

        if status == 1 {
            // 결제 성공
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = .systemGreen
            titleLabel.text = "결제 완료"
            titleLabel.textColor = .systemGreen
            messageLabel.text = "결제가 성공적으로 완료되었습니다."
        } else {
            // 결제 실패
            statusImageView.image = UIImage(systemName: "xmark.circle.fill")
            statusImageView.tintColor = .systemRed
            titleLabel.text = "결제 실패"
            titleLabel.textColor = .systemRed
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

    private func showError() {
        statusImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        statusImageView.tintColor = .systemOrange
        titleLabel.text = "결과 확인 불가"
        titleLabel.textColor = .systemOrange
        messageLabel.text = "결제 결과를 확인할 수 없습니다."
    }

    private func addDetailRow(title: String, value: String) {
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        titleLabel.text = title

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = .black
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
            valueLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
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

    // MARK: - Actions

    @objc private func confirmTapped() {
        // 메인 화면으로 돌아가기 (root로 pop)
        navigationController?.popToRootViewController(animated: true)
    }
}
