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
    let ver = BootpayBuildConfig.VERSION
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    var key = ""
    var iv = ""
    var application_id: String? // 통계를 위한 파라미터
    public var ENV_TYPE = BootpayConstants.ENV_SWIFT
        
    public var webview: WKWebView?
    @objc public var payload: Payload? = Payload()
    var parentController: UIViewController?
    
    @objc public var error: (([String : Any]) -> Void)?
    @objc public var ready: (([String : Any]) -> Void)?
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
    
    
    #if os(macOS)
    @objc(requestPayment::)
    public static func requestPayment(viewController: BTViewController,
                                      payload: Payload) {
        
        shared.parentController = viewController
        shared.payload = payload
        
        loadSessionValues()
        
        let vc = BootpayController()
        viewController.presentAsSheet(vc)
    }
    #elseif os(iOS)
    
    @objc(requestPayment::::)
    public static func requestPayment(viewController: UIViewController,
                                      payload: Payload,
                                      _ animated: Bool = true,
                                      _ modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Bootpay.Type {
        shared.parentController = viewController
        shared.payload = payload
        
        loadSessionValues()
        
        let vc = BootpayController()
        vc.modalPresentationStyle = modalPresentationStyle //or .overFullScreen for transparency
        viewController.present(vc, animated: animated, completion: nil)
        return self
    }
    
    @objc(requestPaymentStr::::)
    public static func requestPaymentStr(viewController: UIViewController,
                                      payload: String,
                                      _ animated: Bool = true,
                                      _ modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Bootpay.Type {
        guard let payload = Payload(JSONString: payload) else { return self }
        
        shared.parentController = viewController
        shared.payload = payload
        
        loadSessionValues()
        
        let vc = BootpayController()
        vc.modalPresentationStyle = modalPresentationStyle //or .overFullScreen for transparency
        viewController.present(vc, animated: animated, completion: nil)
        return self
    }
    
    #endif
    
    @objc(transactionConfirm:)
    public static func transactionConfirm(data: [String: Any]) {
        if let webView = shared.webview {
            let json = BootpayConstants.dicToJsonString(data).replace(target: "'", withString: "\\'")
            webView.evaluateJavaScript("window.BootPay.transactionConfirm(\(json));")
        }
    }
    
    @objc(removePaymentWindow)
    public static func removePaymentWindow() {
        if shared.parentController != nil {
        #if os(macOS)
        shared.parentController?.dismiss(nil)
        #elseif os(iOS)
        shared.parentController?.dismiss(animated: true, completion: nil)
        #endif
            
//            shared.parentController?.dismiss(animated: true, completion: nil)
            shared.parentController = nil
        } else if shared.ENV_TYPE == BootpayConstants.ENV_SWIFT_UI {
            shared.close?()
        }
        shared.webview = nil
        shared.payload = Payload()
        
        shared.error = nil
        shared.ready = nil
        shared.close = nil
        shared.confirm = nil
        shared.done = nil
        shared.cancel = nil
    }
    
    
    public static func goConfirm(_ data: [String : Any]) {
        if let confirm = shared.confirm {
            if(confirm(data)) {
                transactionConfirm(data: data)
            } else {
                removePaymentWindow()
            }
        }
    }
}

extension Bootpay {
    @objc public static func onError(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.error = action
        return self
    }

    @objc public static func onReady(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
        shared.ready = action
        return self
    }
    
    @objc public static func onClose(_ action: @escaping () -> Void) -> Void {
        shared.close = action
    }
    
    @objc public static func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> Bootpay.Type {
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
        if shared.uuid == "" { shared.uuid = BootpayDefaultHelper.getString(key: "uuid") }
        return shared.uuid
    }
    
    public static func getSk() -> String {
        if shared.sk == "" { return BootpayDefaultHelper.getString(key: "sk") }
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
        if uuid == "" {
            uuid = UUID().uuidString
            BootpayDefaultHelper.setValue("uuid", value: uuid)
        }
        return uuid
    }
     
    
    fileprivate static func loadUuid() {
        shared.uuid = BootpayDefaultHelper.getString(key: "uuid")
        if shared.uuid == "" {
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
        let currentTime = currentTimeInMiliseconds()
        if shared.last_time != 0 && Swift.abs(shared.last_time - currentTime) >= 30 * 60 * 1000 {
            shared.time = currentTime - shared.last_time
            shared.last_time = currentTime
            BootpayDefaultHelper.setValue("time", value: shared.time)
            BootpayDefaultHelper.setValue("last_time", value: shared.last_time)
            updateSkTime(time: currentTime)
        } else if shared.sk_time == 0 {
            updateSkTime(time: currentTime)
        }
    }
    
    fileprivate static func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    fileprivate func getRandomKey(_ size: Int) -> String {
        let keys = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var result = ""
        for _ in 0..<size {
            let ran = Int(arc4random_uniform(UInt32(keys.count)))
            let index = keys.index(keys.startIndex, offsetBy: ran)
            result += String(keys[index])
        }
        return result
    }
        
    static func getSessionKey() -> String {
        return "\(shared.key.toBase64())##\(shared.iv.toBase64())"
    }
    
    static func stringify(_ json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
}
