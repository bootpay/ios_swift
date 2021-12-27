//
//  BootpayWebView.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//
 
import WebKit


@objc public class BootpayWebView: BTView {
    @objc public var webview: WKWebView!
    
    var beforeUrl = ""
    var isFirstLoadFinish = false
    var isStartBootpay = false
    var topBlindView: BTView?
    var topBlindButton: UIButton?
     
    @objc public init() {
        
        #if os(macOS)
        super.init(frame: NSScreen.main!.frame)
        #elseif os(iOS)
        super.init(frame: UIScreen.main.bounds)
        #endif
        
        initComponent()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func initComponent() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always  // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: BootpayConstantV2.BRIDGE_NAME)
        
        
        
        #if os(macOS)
            webview = WKWebView(frame: self.bounds, configuration: configuration)
        
//            webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         
        #elseif os(iOS)
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                webview = WKWebView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width,
                                                  height: UIScreen.main.bounds.height - (window?.safeAreaInsets.bottom ?? UIScreen.main.bounds.height) - (window?.safeAreaInsets.top ?? 0)),
                                    configuration: configuration)
            } else {
                webview = WKWebView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width,
                                                  height: UIScreen.main.bounds.height),
                                    configuration: configuration)
            }
        
        #endif
        
//        if(DeviceHelper.nativeMac == DeviceHelper.currentDevice) {
//            webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        }
        
        webview.uiDelegate = self
        webview.navigationDelegate = self
        self.addSubview(webview)
        Bootpay.shared.webview = webview
    }
    
    func updateBlindViewIfNaverLogin(_ url: String) {
        if(url.starts(with: "https://nid.naver.com/")) { //show
            if topBlindView == nil { topBlindView = UIView() }
            else { topBlindView?.removeFromSuperview() }
            if topBlindButton == nil { topBlindButton = UIButton() }
            else { topBlindButton?.removeFromSuperview() }
            
            topBlindView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
            topBlindView?.backgroundColor = .white
            self.addSubview(topBlindView!)
            
            topBlindButton?.frame = CGRect(x: self.frame.width - 50, y: 0, width: 50, height: 50)
            topBlindButton?.setTitle("X", for: .normal)
            topBlindButton?.setTitleColor(.black, for: .normal)
            topBlindButton?.addTarget(self, action: #selector(closeView), for: .touchUpInside)
            self.addSubview(topBlindButton!)
            
        } else { //hide
            topBlindView?.removeFromSuperview()
            topBlindView = nil
            topBlindButton?.removeFromSuperview()
            topBlindButton = nil
        }
    }    
    
    @objc public func closeView() {
        
        var params = [String: Any]()
        params["code"] = -102
        params["action"] = "BootpayCancel"
        params["message"] = "사용자가 창을 닫았습니다."
        
        Bootpay.shared.cancel?(params)
        removePaymentWindow()
    }
    
    @objc public func startBootpay() {
        if let url = URL(string: BootpayConstantV2.CDN_URL) {
            webview.load(URLRequest(url: url))
            self.isStartBootpay = true
        }
    }
     
    @objc public func goBack() {
        webview.goBack()
    }
     
    @objc public func confirm(data: [String: Any]) {
        Bootpay.confirm(data: data)
    }
     
    @objc public func removePaymentWindow() {
        Bootpay.removePaymentWindow()
    }
     
    @objc public func setPayload(_ data: [String: Any]) {
        let payload = Payload(JSON: data)
        Bootpay.shared.payload = payload
    }
    
}

extension BootpayWebView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let payload = Bootpay.shared.payload else { return }
        if isFirstLoadFinish == false && self.isStartBootpay == true  {
            isFirstLoadFinish = true            
//            let quickPopup = payload.extra?.quickPopup ?? false
            
            let scriptList = BootpayConstantV2.getJSBeforePayStart()
            for script in scriptList {
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
            let scriptPay = BootpayConstantV2.getJSPay(payload: payload, requestType: Bootpay.shared.request_type)
            
            webView.evaluateJavaScript(scriptPay, completionHandler: nil)
//            print(scriptPay);
//            webView.evaluateJavaScript(scriptPay, completionHandler:{(result, error) in
//                if let error = error {
//                    print(error)
//                }
//            })
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        Bootpay.shared.webview = webView
        
        guard let url =  navigationAction.request.url else { return decisionHandler(.allow) }
        beforeUrl = url.absoluteString
       
        updateBlindViewIfNaverLogin(url.absoluteString)         
        
        if(isItunesURL(url.absoluteString)) {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else if(url.absoluteString.starts(with: "about:blank")) {
            decisionHandler(.allow)
        } else if(!url.absoluteString.starts(with: "http")) {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
//        guard let serverTrust = challenge.protectionSpace.serverTrust else {
//                completionHandler(.cancelAuthenticationChallenge, nil)
//                return
//            }
//        let exceptions = SecTrustCopyExceptions(serverTrust)
//        SecTrustSetExceptions(serverTrust, exceptions)
//        completionHandler(.useCredential, URLCredential(trust: serverTrust));
        
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let popupView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), configuration: configuration)
        #if os(iOS)
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        popupView.navigationDelegate = self
        popupView.uiDelegate = self

        self.addSubview(popupView)
        return popupView
    }
        
    public func webViewDidClose(_ webView: WKWebView) {
      webView.removeFromSuperview() 
    }
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == BootpayConstantV2.BRIDGE_NAME) {
            print(message.body)
            
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "bootpayclose" {
                    Bootpay.shared.close?()
                    Bootpay.removePaymentWindow()
                }
                return
            }
            guard let event = body["event"] as? String else { return }
            
            if event == "cancel" {
                Bootpay.shared.cancel?(body)
            } else if event == "error" {
                Bootpay.shared.error?(body)
            } else if event == "issued" {
                Bootpay.shared.ready?(body) 
            } else if event == "confirm" {
                if let confirm = Bootpay.shared.confirm {
                    if(confirm(body)) {
                        Bootpay.confirm(data: body)
                    } else {
                        Bootpay.removePaymentWindow()
                    }
                }
            } else if event == "done" {
                Bootpay.shared.done?(body)
//                Bootpay.removePaymentWindow()
            }  
        }
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler()
        }
        let cancelAction = UIAlertAction(title: "닫기", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
     
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "닫기", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension BootpayWebView {
    open func doJavascript(_ script: String) {
        webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
    internal func loadUrl(_ urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            let request = URLRequest(url: url)
            webview.load(request)
        }
    }
    
    func naverLoginBugFix() {
        //네아로 로그인일 경우 요청
//        naversearchthirdlogin://access.naver.com?version=3&session=NkfmtANmdsIcnOBwGv4jm2TwpT98XfR1&callbackurl=
        if(beforeUrl.starts(with: "naversearchthirdlogin://")) {
            //방법1. 네아로 로그인을 부트페이가 중간에서 개입할 수 없기때문에, 중간에서 강제로 호출
            if let value = getQueryStringParameter(url: beforeUrl, param: "session") {
                if let url = URL(string: "https://nid.naver.com/login/scheme.redirect?session=\(value)") {
                    self.webview.load(URLRequest(url: url))
                }
            }
            
            //방법2. 네아로 로그인을 부트페이가 중간에서 개입할 수 없기때문에, 대안으로 브라우저에 노출된 이벤트를 실행시킨다
//            self.popupWV?.evaluateJavaScript("document.getElementById('appschemeLogin_again').click()", completionHandler: nil)
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func startAppToApp(_ url: URL) {
        #if os(iOS)
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        #endif
    }
     
    func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return result.count > 0
    }
    
    func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
}
