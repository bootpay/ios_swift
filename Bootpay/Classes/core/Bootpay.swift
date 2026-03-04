//
//  Bootpay.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/07.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import Foundation
import WebKit

@objc public class Bootpay: NSObject {

    // MARK: - WebView 프리워밍

    /// 프리워밍용 WebView
    private static var prewarmedWebView: WKWebView?

    /// 프리워밍 완료 여부
    private static var _isWarmUpComplete = false

    /// 내부 ProcessPool (lazy 초기화)
    private static let _sharedProcessPool = WKProcessPool()

    /// WKProcessPool을 공유하여 WebContent 프로세스 재사용
    public static var sharedProcessPool: WKProcessPool {
        return _sharedProcessPool
    }

    /// shared 접근 시 자동으로 프리워밍 시작
    @objc public static let shared: Bootpay = {
        return Bootpay()
    }()

    /// 캐싱된 WKWebViewConfiguration
    public static var sharedConfiguration: WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.processPool = sharedProcessPool
        return config
    }

    public var uuid = ""
    let ver = BootpayBuildConfig.VERSION
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    var key = ""
    var iv = ""
    var application_id: String? // 통계를 위한 파라미터
    public var ENV_TYPE = BootpayConstant.ENV_SWIFT
    public var requestType = BootpayConstant.REQUEST_TYPE_PAYMENT
        
    public var webview: WKWebView?
    @objc public var payload: Payload? = Payload()
    var isPresentModal = false
    var parentController: BTViewController?
    
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

    /// 프리워밍된 WebView 리소스를 해제합니다.
    /// 메모리가 부족할 때 호출할 수 있습니다.
    @objc public static func releaseWarmUp() {
        prewarmedWebView = nil
        _isWarmUpComplete = false
    }

    // MARK: - 명시적 프리워밍 API

    /// 프리워밍용 최소 HTML (GPU/WebContent/Networking 프로세스 초기화 트리거)
    private static let warmUpHTML = """
    <!DOCTYPE html>
    <html>
    <head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
    <body><canvas id="c" width="1" height="1"></canvas>
    <script>
    var c=document.getElementById('c').getContext('2d');
    c.fillRect(0,0,1,1);
    fetch('https://webview.bootpay.co.kr/health',{mode:'no-cors'}).catch(function(){});
    </script>
    </body>
    </html>
    """

    /// WebView 프로세스를 미리 초기화합니다.
    /// AppDelegate의 didFinishLaunchingWithOptions에서 호출하면
    /// 첫 결제 화면 로딩 시간을 크게 단축할 수 있습니다.
    ///
    /// - Parameter delay: 프리워밍 시작 전 대기 시간 (초). 기본값 0.1초.
    ///                    UI가 느려지면 0.5~1.0으로 늘려보세요.
    /// - 소요 시간: 백그라운드에서 4-6초 (GPU, WebContent, Networking 프로세스 초기화)
    /// - 메모리: 약 50-100MB 추가 사용
    ///
    /// ```swift
    /// // AppDelegate.swift
    /// Bootpay.warmUp()        // 기본 0.1초 후 시작
    /// Bootpay.warmUp(delay: 0.5)  // UI 버벅임 시 딜레이 증가
    /// ```
    @objc public static func warmUp(delay: Double = 0.1) {
        // 이미 프리워밍 중이면 스킵
        guard prewarmedWebView == nil else { return }

        // UI 초기화 완료 후 실행 (UI 블로킹 방지)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            startWarmUp()
        }
    }

    private static func startWarmUp() {
        guard prewarmedWebView == nil else { return }

        let config = WKWebViewConfiguration()
        config.processPool = _sharedProcessPool

        // WebView 생성 - 이때 GPU/WebContent 프로세스 시작
        prewarmedWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: config)

        // 실제 렌더링 + 네트워크 요청으로 모든 프로세스 초기화
        prewarmedWebView?.loadHTMLString(warmUpHTML, baseURL: URL(string: BootpayConstant.CDN_URL))

        _isWarmUpComplete = true

        #if DEBUG
        print("[Bootpay] warmUp started - WebView processes initializing...")
        #endif
    }

    /// 프리워밍 완료 여부를 확인합니다.
    @objc public static var isWarmedUp: Bool {
        return _isWarmUpComplete && prewarmedWebView != nil
    }

    public func debounceClose() {
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) { [] in

            Bootpay.shared.close?()

            Bootpay.shared.error = nil
            Bootpay.shared.issued = nil
            Bootpay.shared.close = nil
            Bootpay.shared.confirm = nil
            Bootpay.shared.done = nil
            Bootpay.shared.cancel = nil
        }
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
    
    @objc(requestPayment:::::)
    public static func requestPayment(viewController: UIViewController,
                                      payload: Payload,
                                      isModal: Bool = false,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
                                      animated: Bool = true) -> Bootpay.Type {
        shared.requestType = BootpayConstant.REQUEST_TYPE_PAYMENT
        presentBootpayController(viewController: viewController,
                                 payload: payload,
                                 isModal: isModal,
                                 animated: animated,
                                 modalPresentationStyle: modalPresentationStyle
        )
        return self
    }
    
    @objc(requestSubscription:::::)
    public static func requestSubscription(viewController: UIViewController,
                                      payload: Payload,
                                      isModal: Bool = false,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Bootpay.Type {
        if(payload.subscriptionId.isEmpty) {
            payload.subscriptionId = payload.orderId
        }
        
        shared.requestType = BootpayConstant.REQUEST_TYPE_SUBSCRIPT
        presentBootpayController(viewController: viewController,
                                 payload: payload,
                                 isModal: isModal,
                                 animated: animated,
                                 modalPresentationStyle: modalPresentationStyle
        )
        return self
    }
    
    @objc(requestAuthentication:::::)
    public static func requestAuthentication(viewController: UIViewController,
                                      payload: Payload,
                                      isModal: Bool = false,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Bootpay.Type {
        if(payload.authenticationId.isEmpty) {
            payload.authenticationId = payload.orderId
        }
        
        shared.requestType = BootpayConstant.REQUEST_TYPE_AUTH
        presentBootpayController(viewController: viewController,
                                 payload: payload,
                                 isModal: isModal,
                                 animated: animated,
                                 modalPresentationStyle: modalPresentationStyle
        )
        return self
    }
    
    @objc(requestPassword:::::)
    public static func requestPassword(viewController: UIViewController,
                                      payload: Payload,
                                      isModal: Bool = false,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> Bootpay.Type {
        shared.requestType = BootpayConstant.REQUEST_TYPE_PASSWORD
        presentBootpayController(viewController: viewController,
                                 payload: payload,
                                 isModal: isModal,
                                 animated: animated,
                                 modalPresentationStyle: modalPresentationStyle
        )
        return self
    }
    
    private static func presentBootpayController(viewController: UIViewController,
                                                 payload: Payload,
                                                 isModal: Bool = false,
                                                 animated: Bool = true,
                                                 modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        shared.parentController = viewController
        shared.payload = payload
        shared.isPresentModal = isModal
        
        loadSessionValues()
        
        if(isModal == false) {
            let vc = BootpayController()
            viewController.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = BootpayController()
            vc.modalPresentationStyle = modalPresentationStyle //or .overFullScreen for transparency
            viewController.present(vc, animated: animated, completion: nil)
        }
    }
    
    #endif
    
    @objc(transactionConfirm)
    public static func transactionConfirm() {
        if let webView = shared.webview {
            let script = [
                "window.Bootpay.confirm()",
                ".then( function (res) {",
                BootpayConstant.confirm(),
                BootpayConstant.issued(),
                BootpayConstant.done(),
                "}, function (res) {",
                BootpayConstant.error(),
                BootpayConstant.cancel(),
                "})"
            ].reduce("", +)
            
            webView.evaluateJavaScript(script)
        }
    }
    
    @objc(removePaymentWindow)
    public static func removePaymentWindow() {
        if shared.parentController != nil {
        #if os(macOS)
        if(shared.isPresentModal == true) {
            shared.parentController?.dismiss(nil)
        } else {
            shared.parentController?.navigationController?.popViewController(animated: true)
        }
        
        #elseif os(iOS)
        if(shared.isPresentModal == true) {
            shared.parentController?.dismiss(animated: true, completion: nil)
        } else {
            shared.parentController?.navigationController?.popViewController(animated: true)
        }
        #endif
            shared.parentController = nil
        } else if shared.ENV_TYPE == BootpayConstant.ENV_SWIFT_UI {
            // SwiftUI에서는 close 이벤트로 처리
        }
        shared.webview = nil
        shared.payload = Payload()
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
        let keys = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var result = ""
        for _ in 0..<size {
            let ran = Int.random(in: 0..<keys.count)
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
