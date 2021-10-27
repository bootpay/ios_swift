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
     
    @objc public init() {
        
        #if os(macOS)
        super.init(frame: NSScreen.main!.frame)
        #elseif os(iOS)
        super.init(frame: UIScreen.main.bounds)
        #endif
        
        initComponent()
        startBootpay()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    func initComponent() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always  // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: BootpayConstants.BRIDGE_NAME)
        
        var topPadding = CGFloat(0)
        var bottomPadding = CGFloat(0)
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top ?? CGFloat(0)
            bottomPadding = window?.safeAreaInsets.bottom ?? CGFloat(0)
        }
        
        webview = WKWebView(frame: CGRect(x: 0,
                                          y: topPadding,
                                          width: UIScreen.main.bounds.width,
                                          height: UIScreen.main.bounds.height - topPadding - bottomPadding),
                            configuration: configuration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        self.addSubview(webview)
        Bootpay.shared.webview = webview
    }
    
    @objc public func startBootpay() {
        if let url = URL(string: BootpayConstants.CDN_URL) {
            webview.load(URLRequest(url: url))
        }
    }
    
    //flutter 에서 호출되는 함수
    @objc public func goBack() {
        webview.goBack()
    }
    
    //flutter 에서 호출되는 함수
    @objc public func transactionConfirm(data: [String: Any]) {
        Bootpay.transactionConfirm(data: data)
    }
    
    //flutter 에서 호출되는 함수
    @objc public func removePaymentWindow() {
        Bootpay.removePaymentWindow()
    }
    
    //flutter 에서 호출되는 함수
    @objc public func setPayload(_ data: [String: Any]) {
        let payload = Payload(JSON: data)
        Bootpay.shared.payload = payload
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let payload = Bootpay.shared.payload else { return }
//        Bootpay.shared.webview = webView
        if isFirstLoadFinish == false {
            isFirstLoadFinish = true
            
            let quickPopup = payload.extra?.quickPopup ?? 0
            
            let scriptList = BootpayConstants.getJSBeforePayStart(quickPopup == 1)
            for script in scriptList {
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
            let scriptPay = BootpayConstants.getJSPay(payload: payload)
            webView.evaluateJavaScript(scriptPay, completionHandler: nil)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        Bootpay.shared.webview = webView
        
        guard let url =  navigationAction.request.url else { return decisionHandler(.allow) }
        beforeUrl = url.absoluteString
         
        
        if(isItunesURL(url.absoluteString)) {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else if(url.absoluteString.starts(with: "about:blank")) {
            decisionHandler(.allow)
        } else if(!url.absoluteString.starts(with: "http")) {
//            if(UIApplication.shared.canOpenURL(url)) {
//                startAppToApp(url)
//            } else {
//                startItunesToInstall(url)
//            }
            startAppToApp(url)
//            decisionHandler(.allow)
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
        
        let popupView = WKWebView(frame: self.bounds, configuration: configuration)
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
    
    func startItunesToInstall(_ url: URL) {
        let sUrl = url.absoluteString
        var itunesUrl = ""
        if(sUrl.starts(with: "kfc-bankpay")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
        } else if(sUrl.starts(with: "ispmobile")) {
            itunesUrl = "https://apps.apple.com/kr/app/isp-%ED%8E%98%EC%9D%B4%EB%B6%81/id369125087"
        } else if(sUrl.starts(with: "hdcardappcardansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
        } else if(sUrl.starts(with: "shinhan-sr-ansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
        } else if(sUrl.starts(with: "kb-acp")) {
            itunesUrl = "https://apps.apple.com/kr/app/kb-pay/id695436326"
        } else if(sUrl.starts(with: "mpocket.online.ansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
        } else if(sUrl.starts(with: "lottesmartpay")) {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
        } else if(sUrl.starts(with: "lotteappcard")) {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
        } else if(sUrl.starts(with: "cloudpay")) {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%9B%90%ED%81%90-%EC%B9%B4%EB%93%9C-%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C/id427543371"
        } else if(sUrl.starts(with: "nhappvardansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        } else if(sUrl.starts(with: "nhallonepayansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        } else if(sUrl.starts(with: "citispay")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
        } else if(sUrl.starts(with: "payco")) {
            itunesUrl = "https://apps.apple.com/kr/app/payco-%ED%8E%98%EC%9D%B4%EC%BD%94-%ED%98%9C%ED%83%9D%EA%B9%8C%EC%A7%80-%EB%98%91%EB%98%91%ED%95%9C-%EA%B0%84%ED%8E%B8%EA%B2%B0%EC%A0%9C/id924292102"
        } else if(sUrl.starts(with: "naversearchapp")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
        }
        
        if(itunesUrl.count > 0) {
            if let appstore = URL(string: itunesUrl) {
                startAppToApp(appstore)
            }
        }
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
