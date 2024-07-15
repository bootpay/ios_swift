//
//  BootpayWidget.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/8/24.
//

import Foundation
import WebKit

@objc public class BootpayWidget: NSObject {
    @objc public static let shared = BootpayWidget()
    @objc public var payload: Payload? = Payload()
    
    
    @objc public var error: (([String : Any]) -> Void)?
    @objc public var issued: (([String : Any]) -> Void)?
    @objc public var confirm: (([String : Any]) -> Bool)?
    @objc public var cancel: (([String : Any]) -> Void)?
    @objc public var done: (([String : Any]) -> Void)?
    @objc public var close: (() -> Void)?
//    
    @objc public var onWidgetResize: ((Double) -> Void)?
    @objc public var onWidgetReady: (() -> Void)?
    @objc public var onWidgetChangePayment: ((WidgetData) -> Void)?
    @objc public var onWidgetChangeAgreeTerm: ((WidgetData) -> Void)?
    @objc public var needReloadWidget: (() -> Void)?
    
    
    public override init() {
        super.init()
         
    }
    
//    public func debounceClose() {
//        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
//            BootpayWidget.shared.needReloadWidget?()
//            BootpayWidget.widgetStatusReset()
//        }
//    }
    

    public static func render(
        payload: Payload,
        onWidgetResize: ((Double) -> Void)? = nil,
        onWidgetReady: (() -> Void)? = nil,
        onWidgetChangePayment: ((WidgetData) -> Void)? = nil,
        onWidgetChangeAgreeTerm: ((WidgetData) -> Void)? = nil,
        needReloadWidget: (() -> Void)? = nil
    ) -> UIView? {
        shared.payload = payload
        shared.onWidgetReady = onWidgetReady
        shared.onWidgetResize = onWidgetResize
        shared.onWidgetChangePayment = onWidgetChangePayment
        shared.onWidgetChangeAgreeTerm = onWidgetChangeAgreeTerm
        shared.needReloadWidget = needReloadWidget
        
//        let bootpayWebView = BootpayWebView22()
//        bootpayWebView.startWidget()
//        shared.bootpayWebView = bootpayWebView
//        return bootpayWebView
        return BootpayWebViewHandler.renderWidget()
    }
    
    public static func requestPayment(
        payload: Payload,
        rootViewController: UIViewController? = nil
    ) -> BootpayWidget.Type {
        BootpayWebViewHandler.requestWidgetPayment(payload, rootViewController: rootViewController)
        return self
    }
    
//    public static func widgetStatusReset() {
//        shared.bootpayWebView?.startWidget()
//        if shared.paymentResult == .none {
//            let params: [String: Any] = [
//                "code": -102,
//                "action": "BootpayCancel",
//                "message": "사용자가 창을 닫았습니다."
//            ]
//            BootpayWidget.shared.cancel?(params)
//        }
//        shared.paymentResult = .none
//    }
}

extension BootpayWidget {
    
    @objc public static func onClose(_ action: @escaping () -> Void) {
        shared.close = action
    }
    
    @objc public static func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayWidget.Type {
        shared.error = action
        return self
    }

    @objc public static func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayWidget.Type {
        shared.issued = action
        return self
    }
    
    @objc public static func onConfirm(_ action: @escaping ([String : Any]) -> Bool) -> BootpayWidget.Type {
        shared.confirm = action
        return self
    }
    
    @objc public static func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayWidget.Type {
        shared.cancel = action
        return self
    }
    
    @objc public static func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayWidget.Type {
        shared.done = action
        return self
    }
}


extension BootpayWidget {
    @objc public static func onWidgetResize(_ action: @escaping (Double) -> Void) -> BootpayWidget.Type {
        shared.onWidgetResize = action
        return self
    }
    
    @objc public static func onWidgetReady(_ action: @escaping () -> Void) -> BootpayWidget.Type {
        shared.onWidgetReady = action
        return self
    }
    
    @objc public static func onWidgetChangePayment(_ action: @escaping (WidgetData) -> Void) -> BootpayWidget.Type {
        shared.onWidgetChangePayment = action
        return self
    }
    
    @objc public static func onWidgetChangeAgreeTerm(_ action: @escaping (WidgetData) -> Void) -> BootpayWidget.Type {
        shared.onWidgetChangeAgreeTerm = action
        return self
    }
}


private extension BootpayWidget {
    func resetHandlers() {
        error = nil
        issued = nil
        confirm = nil
        done = nil
        cancel = nil
        close = nil
        
        onWidgetResize = nil
        onWidgetReady = nil
        onWidgetChangePayment = nil
        onWidgetChangeAgreeTerm = nil
    }
    
//    func resetWebViewAndPayload() {
//        bootpayWebView = nil
//        payload = Payload()
//    }
}
