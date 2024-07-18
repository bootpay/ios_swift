//
//  Bootpay.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/07.
//

import Foundation
import WebKit

@objc public class Bootpay: NSObject {
    @objc public static let shared = Bootpay()
    public var uuid = ""
    let ver = BootpayBuild.VERSION
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    var key = ""
    var iv = ""
    var application_id: String? // 통계를 위한 파라미터
//    public var ENV_TYPE = BootpayConstant.ENV_SWIFT
//    public var requestType = BootpayConstant.REQUEST_TYPE_PAYMENT
        
//    public var webview: WKWebView?
    @objc public var payload: Payload? = Payload()
//    var isPresentModal = false
//    var parentController: BTViewController?
    
    @objc public var error: (([String : Any]) -> Void)?
    @objc public var issued: (([String : Any]) -> Void)?
    @objc public var confirm: (([String : Any]) -> Bool)?
    @objc public var cancel: (([String : Any]) -> Void)?
    @objc public var done: (([String : Any]) -> Void)?
    @objc public var easyCancel: (([String : Any]) -> Void)?
    @objc public var easyError: (([String : Any]) -> Void)?
    @objc public var easySuccess: (([String : Any]) -> Void)?
    @objc public var close: (() -> Void)?
    
    public override init() {
        super.init()
        self.key = getRandomKey(32)
        self.iv = getRandomKey(16)
    }
    
//    public func debounceClose() {
//        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
//            Bootpay.shared.close?()
//            Bootpay.shared.resetHandlers()
//        }
//    }
    
    #if os(macOS)
    @objc(requestPayment::)
    public static func requestPayment(viewController: BTViewController, payload: Payload) {
        shared.parentController = viewController
        shared.payload = payload
        
        loadSessionValues()
        
        let vc = BootpayController()
        viewController.presentAsSheet(vc)
    }
    #elseif os(iOS)
    
    @objc(requestPayment::)
    public static func requestPayment(payload: Payload,
                                      rootController: UIViewController? = nil) -> Bootpay.Type {
        BootpayWebViewHandler.setRequestType(.payment)
        presentBootpayController(payload: payload, rootController: rootController)
//        BootpayWebViewHandler.
//        shared.requestType = BootpayConstant.REQUEST_TYPE_PAYMENT
//        presentBootpayController(viewController: viewController, payload: payload, isModal: isModal, animated: animated, modalPresentationStyle: modalPresentationStyle)
        return self
    }
    
    @objc(requestSubscription::)
    public static func requestSubscription(payload: Payload,
                                           rootController: UIViewController? = nil) -> Bootpay.Type {
        if payload.subscriptionId == nil { payload.subscriptionId = payload.orderId }
        BootpayWebViewHandler.setRequestType(.subscription)
        presentBootpayController(payload: payload, rootController: rootController)
        
//        shared.requestType = BootpayConstant.REQUEST_TYPE_SUBSCRIPT
//        presentBootpayController(viewController: viewController, payload: payload, isModal: isModal, animated: animated, modalPresentationStyle: modalPresentationStyle)
        return self
    }
    
    @objc(requestAuthentication::)
    public static func requestAuthentication(payload: Payload,
                                             rootController: UIViewController? = nil) -> Bootpay.Type {
        if payload.authenticationId == nil { payload.authenticationId = payload.orderId }
        BootpayWebViewHandler.setRequestType(.auth)
        presentBootpayController(payload: payload, rootController: rootController)
        
        
//        shared.requestType = BootpayConstant.REQUEST_TYPE_AUTH
//        presentBootpayController(viewController: viewController, payload: payload, isModal: isModal, animated: animated, modalPresentationStyle: modalPresentationStyle)
        return self
    }
    
    @objc(requestPassword::)
    public static func requestPassword(payload: Payload,
                                       rootController: UIViewController? = nil) -> Bootpay.Type {
        BootpayWebViewHandler.setRequestType(.password)
        presentBootpayController(payload: payload, rootController: rootController)
        
//        shared.requestType = BootpayConstant.REQUEST_TYPE_PASSWORD
//        presentBootpayController(viewController: viewController, payload: payload, isModal: isModal, animated: animated, modalPresentationStyle: modalPresentationStyle)
        return self
    }
    
    private static func presentBootpayController(payload: Payload,
                                                 rootController: UIViewController? = nil) {
        shared.payload = payload
        loadSessionValues()
        BootpayWebViewHandler.showWidgetController(rootController)
        
//        shared.parentController = viewController
        
//        shared.isPresentModal = isModal
        
        
        
//        let vc = BootpayController()
//        if isModal {
//            vc.modalPresentationStyle = modalPresentationStyle
//            viewController.present(vc, animated: animated, completion: nil)
//        } else {
//            viewController.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    #endif
    
    @objc(transactionConfirm)
    public static func transactionConfirm() {
        BootpayWebViewHandler.transactionConfirm()
    }
    
    @objc(confirm)
    public static func confirm() {
        transactionConfirm()
    } 
    
    @objc(removePaymentWindow)
    public static func removePaymentWindow() { 
        BootpayWebViewHandler.dismissController()
    }
    
    @objc(dismiss)
    public static func dismiss() {
        removePaymentWindow()
    }
}

extension Bootpay {
    
    @objc public static func onClose(_ action: @escaping () -> Void) {
        shared.close = action
    }
    
    @objc public static func onError(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.error = action
        return self
    }

    @objc public static func onIssued(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.issued = action
        return self
    }
    
    @objc public static func onConfirm(_ action: @escaping ([String : Any]) -> Bool) -> Bootpay.Type {
        shared.confirm = action
        return self
    }
    
    @objc public static func onCancel(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.cancel = action
        return self
    }
    
    @objc public static func onDone(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.done = action
        return self
    }
}

//bio 생체인증 결제
extension Bootpay {
    @objc public static func onEasyError(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.easyError = action
        return self
    }
    
    @objc public static func onEasyCancel(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.easyCancel = action
        return self
    }
    
    @objc public static func onEasySuccess(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.easySuccess = action
        return self
    }
}

extension Bootpay {
    public static func getUUId() -> String {
        if shared.uuid.isEmpty { shared.uuid = BootpayDefaultHelper.getString(key: "uuid") }
        return shared.uuid
    }
    
    public static func getSk() -> String {
        if shared.sk.isEmpty { return BootpayDefaultHelper.getString(key: "sk") }
        return shared.sk
    }
    
    public static func getSkTime() -> Int {
        if shared.sk_time == 0 { return BootpayDefaultHelper.getInt(key: "sk_time") }
        return shared.sk_time
    }
    
    public static func loadSessionValues() {
        loadUuid()
        loadSkTime()
    }
    
    @objc public static func getUUID() -> String {
        var uuid = BootpayDefaultHelper.getString(key: "uuid")
        if uuid.isEmpty {
            uuid = UUID().uuidString
            BootpayDefaultHelper.setValue("uuid", value: uuid)
        }
        return uuid
    }
    
    fileprivate static func loadUuid() {
        shared.uuid = BootpayDefaultHelper.getString(key: "uuid")
        if shared.uuid.isEmpty {
            shared.uuid = UUID().uuidString
            BootpayDefaultHelper.setValue("uuid", value: shared.uuid)
        }
    }
    
    fileprivate static func loadLastTime() {
        shared.last_time = BootpayDefaultHelper.getInt(key: "last_time")
    }
    
    fileprivate static func loadSkTime() {
        func updateSkTime(time: Int) {
            shared.sk_time = time
            shared.sk = "\(shared.uuid)_\(shared.sk_time)"
            BootpayDefaultHelper.setValue("sk", value: shared.sk)
            BootpayDefaultHelper.setValue("sk_time", value: shared.sk_time)
        }
        
        loadLastTime()
        let currentTime = currentTimeInMilliseconds()
        if shared.last_time != 0 && abs(shared.last_time - currentTime) >= 30 * 60 * 1000 {
            shared.time = currentTime - shared.last_time
            shared.last_time = currentTime
            BootpayDefaultHelper.setValue("time", value: shared.time)
            BootpayDefaultHelper.setValue("last_time", value: shared.last_time)
            updateSkTime(time: currentTime)
        } else if shared.sk_time == 0 {
            updateSkTime(time: currentTime)
        }
    }
    
    fileprivate static func currentTimeInMilliseconds() -> Int {
        return Int(Date().timeIntervalSince1970 * 1000)
    }
    
    fileprivate func getRandomKey(_ size: Int) -> String {
        let keys = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<size).compactMap { _ in keys.randomElement() })
    }
    
    static func getSessionKey() -> String {
        return "\(shared.key.toBase64())##\(shared.iv.toBase64())"
    }
    
    static func stringify(_ json: Any, prettyPrinted: Bool = false) -> String {
        let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
        
        if let data = try? JSONSerialization.data(withJSONObject: json, options: options),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        
        return ""
    }
}

extension Bootpay {
    public func dispose() {
        print("dispose")
        
        error = nil
        issued = nil
        confirm = nil
        done = nil
        cancel = nil
        close = nil
        
        payload = Payload()
        BootpayWebViewHandler.dispose()
    }
    
//    func resetHandlers() {
//        error = nil
//        issued = nil
//        confirm = nil
//        done = nil
//        cancel = nil
//        close = nil
//    }
//    
//    func resetWebViewAndPayload() {
//        print("resetWebViewAndPayload")
////        webview = nil
//        payload = Payload()
//        BootpayWebViewHandler.dispose()
//    }
}
