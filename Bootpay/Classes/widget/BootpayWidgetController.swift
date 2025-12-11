//
//  BootpayWidgetController.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/10.
//

import Foundation
import UIKit
import WebKit

/// 위젯 닫기 시 동작 옵션
@objc public enum WidgetCloseAction: Int {
    /// 현재 ViewController를 pop (NavigationController 사용 시)
    case popViewController
    /// 현재 ViewController를 dismiss (Modal 사용 시)
    case dismissViewController
    /// 아무 동작 안함 (가맹점이 onClose에서 직접 처리)
    case none
}

/// 부트페이 위젯을 제어하는 컨트롤러
/// 위젯의 상태를 관리하고, 결제 요청을 처리합니다.
@objc public class BootpayWidgetController: NSObject {

    // MARK: - Properties

    /// 델리게이트 (약한 참조)
    @objc public weak var delegate: BootpayWidgetDelegate?

    /// 내부 웹뷰 참조 (BootpayWidgetView에서 설정)
    internal weak var widgetView: BootpayWidgetView?

    /// 현재 위젯 높이
    @objc public private(set) var widgetHeight: CGFloat = 300.0

    /// 위젯 데이터 (결제수단, 약관동의 등)
    @objc public private(set) var widgetData: WidgetData?

    /// 닫기 시 동작 (기본값: popViewController)
    @objc public var closeAction: WidgetCloseAction = .popViewController

    // MARK: - Closure-based Callbacks (Swift 전용)

    /// 위젯 준비 완료 콜백
    public var onReady: (() -> Void)?

    /// 위젯 높이 변경 콜백
    public var onResize: ((CGFloat) -> Void)?

    /// 결제 수단 변경 콜백
    public var onChangePayment: ((WidgetData) -> Void)?

    /// 약관 동의 변경 콜백
    public var onChangeAgreeTerm: ((WidgetData) -> Void)?

    /// 에러 콜백
    public var onError: (([String: Any]) -> Void)?

    /// 취소 콜백
    public var onCancel: (([String: Any]) -> Void)?

    /// 완료 콜백
    public var onDone: (([String: Any]) -> Void)?

    /// 확인 콜백 (true 반환시 결제 진행)
    public var onConfirm: (([String: Any]) -> Bool)?

    /// 가상계좌 발급 콜백
    public var onIssued: (([String: Any]) -> Void)?

    /// 닫기 콜백
    public var onClose: (() -> Void)?

    // MARK: - Initialization

    @objc public override init() {
        super.init()
    }

    // MARK: - Public Methods

    /// 위젯 데이터를 업데이트합니다.
    /// - Parameters:
    ///   - payload: 업데이트할 페이로드
    ///   - refresh: 위젯을 새로고침할지 여부
    @objc public func update(payload: Payload, refresh: Bool = false) {
        widgetView?.widgetUpdate(payload: payload, refresh: refresh)
    }

    /// 결제를 요청합니다.
    /// - Parameter payload: 결제 페이로드 (nil이면 현재 위젯 데이터 사용)
    @objc public func requestPayment(payload: Payload? = nil) {
        widgetView?.widgetRequestPayment(payload: payload)
    }

    /// 결제를 확인합니다. (confirm 이벤트에서 호출)
    @objc public func transactionConfirm() {
        widgetView?.transactionConfirm()
    }

    // MARK: - Internal Methods (BootpayWidgetView에서 호출)

    internal func handleReady() {
        onReady?()
        delegate?.bootpayWidgetReady?()
    }

    internal func handleResize(height: CGFloat) {
        guard widgetHeight != height else { return }
        widgetHeight = height
        onResize?(height)
        delegate?.bootpayWidgetResize?(height: height)
    }

    internal func handleChangePayment(data: WidgetData) {
        widgetData = data
        onChangePayment?(data)
        delegate?.bootpayWidgetChangePayment?(data: data)
    }

    internal func handleChangeAgreeTerm(data: WidgetData) {
        widgetData = data
        onChangeAgreeTerm?(data)
        delegate?.bootpayWidgetChangeAgreeTerm?(data: data)
    }

    internal func handleError(data: [String: Any]) {
        onError?(data)
        delegate?.bootpayWidgetError?(data: data)
    }

    internal func handleCancel(data: [String: Any]) {
        onCancel?(data)
        delegate?.bootpayWidgetCancel?(data: data)
    }

    internal func handleDone(data: [String: Any]) {
        onDone?(data)
        delegate?.bootpayWidgetDone?(data: data)
    }

    internal func handleConfirm(data: [String: Any]) -> Bool {
        if let confirm = onConfirm {
            return confirm(data)
        }
        if let delegateResult = delegate?.bootpayWidgetConfirm?(data: data) {
            return delegateResult
        }
        return true
    }

    internal func handleIssued(data: [String: Any]) {
        onIssued?(data)
        delegate?.bootpayWidgetIssued?(data: data)
    }

    internal func handleClose() {
        onClose?()
        delegate?.bootpayWidgetClose?()
    }
}
