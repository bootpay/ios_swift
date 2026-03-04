//
//  BootpayCommerce.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import Foundation
import WebKit

@objc public class BootpayCommerce: NSObject {
    @objc public static let shared = BootpayCommerce()

    /// 환경 설정 (development, stage, production)
    public var environmentMode = "production"

    /// 현재 Payload
    @objc public var payload: CommercePayload?

    /// WebView 참조
    public var webview: WKWebView?

    /// 부모 ViewController
    var parentController: UIViewController?

    /// 모달 표시 여부
    var isPresentModal = false

    // MARK: - 콜백
    @objc public var done: (([String: Any]) -> Void)?
    @objc public var issued: (([String: Any]) -> Void)?
    @objc public var error: (([String: Any]) -> Void)?
    @objc public var cancel: (([String: Any]) -> Void)?
    @objc public var close: (() -> Void)?

    public override init() {
        super.init()
    }

    public func debounceClose() {
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) { [] in
            BootpayCommerce.shared.close?()

            BootpayCommerce.shared.done = nil
            BootpayCommerce.shared.issued = nil
            BootpayCommerce.shared.error = nil
            BootpayCommerce.shared.cancel = nil
            BootpayCommerce.shared.close = nil
        }
    }

    // MARK: - Static Methods

    /// 환경 모드 설정 (development, stage, production)
    @objc public static func setEnvironmentMode(_ mode: String) {
        shared.environmentMode = mode
    }

    /// Commerce 결제 요청 (requestCheckout)
    @objc(requestCheckout:::::)
    public static func requestCheckout(
        viewController: UIViewController,
        payload: CommercePayload,
        isModal: Bool = true,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
        animated: Bool = true
    ) -> BootpayCommerce.Type {
        shared.parentController = viewController
        shared.payload = payload
        shared.isPresentModal = isModal

        if isModal {
            let vc = CommerceController()
            vc.modalPresentationStyle = modalPresentationStyle
            viewController.present(vc, animated: animated, completion: nil)
        } else {
            let vc = CommerceController()
            viewController.navigationController?.pushViewController(vc, animated: animated)
        }

        return self
    }

    /// 결제 창 닫기
    @objc(removePaymentWindow)
    public static func removePaymentWindow() {
        if shared.parentController != nil {
            if shared.isPresentModal {
                shared.parentController?.dismiss(animated: true, completion: nil)
            } else {
                shared.parentController?.navigationController?.popViewController(animated: true)
            }
            shared.parentController = nil
        }
        shared.webview = nil
        shared.payload = nil
    }
}

// MARK: - Chaining Callbacks
extension BootpayCommerce {
    @objc public static func onDone(_ action: @escaping ([String: Any]) -> Void) -> BootpayCommerce.Type {
        shared.done = action
        return self
    }

    @objc public static func onIssued(_ action: @escaping ([String: Any]) -> Void) -> BootpayCommerce.Type {
        shared.issued = action
        return self
    }

    @objc public static func onError(_ action: @escaping ([String: Any]) -> Void) -> BootpayCommerce.Type {
        shared.error = action
        return self
    }

    @objc public static func onCancel(_ action: @escaping ([String: Any]) -> Void) -> BootpayCommerce.Type {
        shared.cancel = action
        return self
    }

    @objc public static func onClose(_ action: @escaping () -> Void) {
        shared.close = action
    }
}

// MARK: - JavaScript Generation
extension BootpayCommerce {
    /// Commerce SDK 결제 요청 JavaScript 생성 (WebView 페이지 로드 후 주입용)
    static func getJSCommerceCheckout(payload: CommercePayload) -> String {
        var scripts = [String]()

        // 로그 레벨 설정 (개발 환경에서만)
        if shared.environmentMode == "development" {
            scripts.append("BootpayCommerce.setLogLevel(1);")
        }

        // close 이벤트 리스너 등록
        scripts.append("document.addEventListener('bootpayclose', function(e) { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage('close'); });")

        // payload JSON 로그
        let payloadJSON = payload.toJSONString()
        print("[BootpayCommerce] Payload JSON: \(payloadJSON)")

        // requestCheckout 호출
        scripts.append("BootpayCommerce.requestCheckout(")
        scripts.append(payloadJSON)
        scripts.append(")")
        scripts.append(".then(function(res) {")
        scripts.append("  webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res);")
        scripts.append("}).catch(function(err) {")
        scripts.append("  webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage({event: 'error', data: err});")
        scripts.append("});")

        let fullScript = scripts.joined(separator: "")
        print("[BootpayCommerce] Full JS Script: \(fullScript)")

        return fullScript
    }
}
