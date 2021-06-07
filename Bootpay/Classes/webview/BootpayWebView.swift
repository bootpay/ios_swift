//
//  BootpayWebView.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//
 
import WebKit


@objc public class BootpayWebView: UIView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    @objc public var webview: WKWebView!
    
    var beforeUrl = ""
    var isFirstLoadFinish = false
     
    init() {
        super.init(frame: UIScreen.main.bounds)
        initComponent()
        bootpayConnect()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func initComponent() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always  // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: BootpayConstants.BRIDGE_NAME)
        webview = WKWebView(frame: self.bounds, configuration: configuration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        self.addSubview(webview)
    }
    
    @objc func bootpayConnect() {
        if let url = URL(string: BootpayConstants.CDN_URL) {
            webview.load(URLRequest(url: url))
        }
    }
    
    //Flutter에서 Webview direct 연결시 필요한 함수
    @objc public func setPayload(_ payload: Payload) {
        Bootpay.shared.payload = payload
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let payload = Bootpay.shared.payload else { return }
        Bootpay.shared.webview = webView
        if isFirstLoadFinish == false {
            isFirstLoadFinish = true
            
            let quickPopup = payload.extra?.quickPopup ?? 0
            
            let scriptList = BootpayConstants.getJSBeforePayStart(quickPopup == 1)
            for script in scriptList {
                print(script)
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
            let scriptPay = BootpayConstants.getJSPay(payload: payload)
            print(scriptPay)
            webView.evaluateJavaScript(scriptPay, completionHandler: nil)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        Bootpay.shared.webview = webView
        
        guard let url =  navigationAction.request.url else { return decisionHandler(.allow) }
        beforeUrl = url.absoluteString
        
        if(isItunesURL(url.absoluteString)) {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else if(!url.absoluteString.starts(with: "http")) {
            startAppToApp(url)
            decisionHandler(.allow)
//            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let popupView = WKWebView(frame: webView.bounds, configuration: configuration)
        #if os(iOS)
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        popupView.navigationDelegate = self
        popupView.uiDelegate = self

        webView.addSubview(popupView)
        return popupView
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == BootpayConstants.BRIDGE_NAME) {
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    Bootpay.shared.close?()
                    Bootpay.removePaymentWindow()
                }
                return
            }
            guard let action = body["action"] as? String else { return }
            
            if action == "BootpayCancel" {
                Bootpay.shared.cancel?(body)
            } else if action == "BootpayError" {
                Bootpay.shared.error?(body)
            } else if action == "BootpayBankReady" {
                Bootpay.shared.ready?(body)
            } else if action == "BootpayConfirm" {
                if let confirm = Bootpay.shared.confirm {
                    if(confirm(body)) {
                        Bootpay.transactionConfirm(data: body)
                    } else {
                        Bootpay.removePaymentWindow()
                    }
                }
            } else if action == "BootpayDone" {
                Bootpay.shared.done?(body)
            }
        }
    }
}

extension BootpayWebView {
    internal func doJavascript(_ script: String) {
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
