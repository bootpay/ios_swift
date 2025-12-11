//
//  WidgetController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2024/12/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class WidgetController: UIViewController {

    // MARK: -
    let _applicationId = "5b8f6a4d396fa665fdc2b5e9"

    var widgetView: BootpayWidgetView!
    var widgetController: BootpayWidgetController!
    var payButton: UIButton!
    var scrollView: UIScrollView!
    var contentView: UIView!

    var widgetHeightConstraint: NSLayoutConstraint!
    var payload: Payload!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "위젯 결제"
        self.view.backgroundColor = .white

        setupPayload()
        setupUI()
        setupWidgetController()
        startWidget()
    }

    // MARK: - Setup

    func setupPayload() {
        payload = Payload()
        payload.applicationId = _applicationId
        payload.price = 1000
        payload.orderId = String(Int(Date().timeIntervalSince1970 * 1000))
        payload.orderName = "테스트 상품"

        // Widget 설정
        payload.widgetKey = "default-widget"
        payload.widgetSandbox = true
        payload.widgetUseTerms = true

        // User 설정
        payload.user = BootUser()
        payload.user?.id = "test_user_1234"
        payload.user?.username = "홍길동"
        payload.user?.email = "test@bootpay.co.kr"
        payload.user?.phone = "01012341234"

        // Extra 설정
        payload.extra = BootExtra()
//        payload.extra?.displaySuccessResult = true
        payload.extra?.appScheme = "bootpaySwift"
    }

    func setupUI() {
        // ScrollView
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Content View
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // 상품 정보 라벨
        let productLabel = UILabel()
        productLabel.text = "주문 상품: 테스트 상품"
        productLabel.font = .boldSystemFont(ofSize: 18)
        productLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(productLabel)

        let priceLabel = UILabel()
        priceLabel.text = "결제 금액: 1,000원"
        priceLabel.font = .systemFont(ofSize: 16)
        priceLabel.textColor = .systemBlue
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)

        // Widget View
        widgetView = BootpayWidgetView()
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        // widgetView.backgroundColor = .systemYellow.withAlphaComponent(0.3) // 웹뷰 영역 확인용
        // widgetView.layer.borderWidth = 1
        // widgetView.layer.borderColor = UIColor.systemOrange.cgColor
        contentView.addSubview(widgetView)

        // Pay Button
        payButton = UIButton(type: .system)
        payButton.setTitle("1,000원 결제하기", for: .normal)
        payButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        payButton.backgroundColor = .systemGray
        payButton.setTitleColor(.white, for: .normal)
        payButton.layer.cornerRadius = 10
        payButton.isEnabled = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
        view.addSubview(payButton)

        // Constraints
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -10),

            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Product Label
            productLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            productLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            productLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Price Label
            priceLabel.topAnchor.constraint(equalTo: productLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Widget View
            widgetView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            widgetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            widgetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            widgetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Pay Button
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            payButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Widget Height Constraint (초기 높이)
        widgetHeightConstraint = widgetView.heightAnchor.constraint(equalToConstant: 516)
        widgetHeightConstraint.isActive = true
    }

    func setupWidgetController() {
        widgetController = BootpayWidgetController()

        // 닫기 시 동작 설정 (기본값: popViewController)
        // .popViewController - NavigationController에서 pop
        // .dismissViewController - Modal dismiss
        // .none - 직접 처리 (onClose에서)
        widgetController.closeAction = .popViewController

        // Ready 콜백
        widgetController.onReady = { [weak self] in
            print("[Widget] Ready")
        }

        // Resize 콜백
        widgetController.onResize = { [weak self] height in
            print("[Widget] Resize: \(height)")
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.widgetHeightConstraint.constant = height
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        // 결제수단 변경 콜백
        widgetController.onChangePayment = { [weak self] data in
            print("[Widget] Payment Changed: pg=\(data.pg ?? ""), method=\(data.method ?? "")")
            guard let self = self else { return }
            self.payload.mergeWidgetData(data)
            self.updatePayButtonState()
        }

        // 약관동의 변경 콜백
        widgetController.onChangeAgreeTerm = { [weak self] data in
            print("[Widget] Term Changed: termPassed=\(data.termPassed), completed=\(data.completed)")
            guard let self = self else { return }
            self.payload.mergeWidgetData(data)
            self.updatePayButtonState()
        }

        // 에러 콜백
        widgetController.onError = { data in
            print("[Widget] Error: \(data)")
        }

        // 취소 콜백
        widgetController.onCancel = { data in
            print("[Widget] Cancel: \(data)")
        }

        // 완료 콜백
        widgetController.onDone = { [weak self] data in
            print("[Widget] Done: \(data)")
            self?.showAlert(title: "결제 완료", message: "결제가 성공적으로 완료되었습니다.")
        }

        // 확인 콜백
        widgetController.onConfirm = { data in
            print("[Widget] Confirm: \(data)")
            return true // 결제 진행
        }

        // 가상계좌 발급 콜백
        widgetController.onIssued = { data in
            print("[Widget] Issued: \(data)")
        }

        // 닫기 콜백
        widgetController.onClose = {
            print("[Widget] Close")
        }

        // 위젯 뷰에 컨트롤러 연결
        widgetView.controller = widgetController
    }

    func startWidget() {
        widgetView.payload = payload
        widgetView.startWidget()
    }

    // MARK: - Actions

    func updatePayButtonState() {
        let isCompleted = payload.widgetIsCompleted

        DispatchQueue.main.async { [weak self] in
            self?.payButton.isEnabled = isCompleted
            self?.payButton.backgroundColor = isCompleted ? .systemBlue : .systemGray
        }
    }

    @objc func requestPayment() {
        guard payload.widgetIsCompleted else {
            showAlert(title: "알림", message: "결제수단 선택과 약관동의를 완료해주세요.")
            return
        }

        print("[Widget] Request Payment: \(payload.toJSON())")
        widgetController.requestPayment(payload: payload)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Payload Extension

extension Payload {
    func toJSON() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["application_id"] = applicationId
        if let pg = pg { dict["pg"] = pg }
        if let method = method { dict["method"] = method }
        if let orderName = orderName { dict["order_name"] = orderName }
        dict["price"] = price
        dict["order_id"] = orderId
        return dict
    }
}
