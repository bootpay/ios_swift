//
//  WidgetController.swift
//  Bootpay_Example
//
//  Created by TaeSup Yoon on 7/5/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//
import UIKit
import Bootpay


class WidgetController: BaseController {

    private lazy var button = UIButton()
    var payload = Payload()
    var widgetView: UIView?
    var label = UILabel()
    private let widgetContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UILabel 설정
        label.text = "위젯 테스트"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 배경 색상 설정
        self.view.backgroundColor = .brown

        // UIButton 설정
        button.backgroundColor = .systemBlue
        button.setTitle("결제하기", for: .normal)
        button.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        updatePaymentButtonState()

        // Payload 설정
        payload.applicationId = "5b8f6a4d396fa665fdc2b5e9"
        payload.orderName = "부트페이 결제테스트"
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.widgetSandbox = true
        payload.widgetUseTerms = true
        payload.price = 1000
        payload.widgetKey = "default-widget"
        payload.extra = BootExtra()
        payload.extra?.displaySuccessResult = true

        // WidgetView 설정
        widgetView = BootpayWidget.render(
            payload: payload,
            onWidgetResize: { height in
                print("onWidgetResize: \(height)")
            },
            onWidgetReady: {
                print("onWidgetReady")
            },
            onWidgetChangePayment: { widgetData in
                print("onWidgetChangePayment: \(widgetData.toJSON())")
                self.payload.mergeWidgetData(data: widgetData)
                self.updatePaymentButtonState()
            },
            onWidgetChangeAgreeTerm: { widgetData in
                print("onWidgetChangeAgreeTerm: \(widgetData.toJSON())")
                self.payload.mergeWidgetData(data: widgetData)
                self.updatePaymentButtonState()
            },
            needReloadWidget: {
                if self.widgetView != nil {
                    self.widgetContainerView.subviews.forEach { $0.removeFromSuperview() }
                    self.widgetContainerView.addSubview(self.widgetView!)
                    self.setupWidgetContainerConstraints()
                }
            }
        )

        // View에 추가
        self.stackView.addArrangedSubview(label)
        widgetContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.addArrangedSubview(widgetContainerView)
        if let widgetView = widgetView {
            widgetView.translatesAutoresizingMaskIntoConstraints = false
            widgetContainerView.addSubview(widgetView)
            setupWidgetContainerConstraints()
        }
        self.stackView.addArrangedSubview(button)
 
    }

    func updatePaymentButtonState() {
        button.backgroundColor = payload.getWidgetIsCompleted() == true ? .systemBlue : .darkGray
    }

    @objc func requestPayment() {
        print("requestPayment click")
        
        BootpayWidget.requestPayment(
            payload: self.payload
        ).onCancel { data in
            print("-- cancel: \(data)")
        }
        .onIssued { data in
            print("-- issued: \(data)")
        }
        .onConfirm { data in
            print("-- confirm: \(data)")
            return true // 재고가 있어서 결제를 최종 승인하려 할 경우
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

    private func setupWidgetContainerConstraints() {
        guard let widgetView = widgetView else { return }
        NSLayoutConstraint.activate([
            widgetView.topAnchor.constraint(equalTo: widgetContainerView.topAnchor),
            widgetView.leadingAnchor.constraint(equalTo: widgetContainerView.leadingAnchor),
            widgetView.trailingAnchor.constraint(equalTo: widgetContainerView.trailingAnchor),
            widgetView.bottomAnchor.constraint(equalTo: widgetContainerView.bottomAnchor)
        ])
    }
     
}
