//
//  BootpayWebView.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//
 
import WebKit


@objc open class BootpayWebView: BTView {
    @objc public var webview: WKWebView!
    
    var beforeUrl = ""
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
        configuration.userContentController.add(self, name: BootpayConstant.BRIDGE_NAME)
//        configuration.userContentController.add(self, name: "postMessageListener")
        
        
        
        #if os(macOS)
            webview = WKWebView(frame: self.bounds, configuration: configuration)
        
//            webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         
        #elseif os(iOS)
//            if #available(iOS 11.0, *) {
//                let window = UIApplication.shared.keyWindow
//                webview = WKWebView(frame: CGRect(x: 0,
//                                                  y: 0,
//                                                  width: UIScreen.main.bounds.width,
//                                                  height: UIScreen.main.bounds.height - (window?.safeAreaInsets.bottom ?? UIScreen.main.bounds.height) - (window?.safeAreaInsets.top ?? 0)),
//                                    configuration: configuration)
//            } else {
//                webview = WKWebView(frame: CGRect(x: 0,
//                                                  y: 0,
//                                                  width: UIScreen.main.bounds.width,
//                                                  height: UIScreen.main.bounds.height),
//                                    configuration: configuration)
//            }
        
        webview = WKWebView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: UIScreen.main.bounds.width,
                                          height: UIScreen.main.bounds.height),
                            configuration: configuration)
        
        #endif
        
//        if(DeviceHelper.nativeMac == DeviceHelper.currentDevice) {
//            webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        }
        
        webview.uiDelegate = self
        webview.navigationDelegate = self
        self.addSubview(webview)
        Bootpay.shared.webview = webview
    }
    
    func updateBlindViewIfNaverLogin(_ webView: WKWebView, _ url: String) {
        if(url.starts(with: "https://nid.naver.com")) { //show
            webView.evaluateJavaScript("document.getElementById('back').remove();")
        }
//        if(url.starts(with: "https://nid.naver.com/")) { //show
//            if topBlindView == nil { topBlindView = UIView() }
//            else { topBlindView?.removeFromSuperview() }
//            topBlindView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 100)
//            topBlindView?.backgroundColor = .red
//            webView.superview?.addSubview(topBlindView!)
//
////            topBlindButton?.frame = CGRect(x: self.frame.width - 50, y: 0, width: 50, height: 50)
////            topBlindButton?.setTitle("X", for: .normal)
////            topBlindButton?.setTitleColor(.black, for: .normal)
////            topBlindButton?.addTarget(self, action: #selector(closeView), for: .touchUpInside)
////            self.addSubview(topBlindButton!)
//
//        } else { //hide
//            topBlindView?.removeFromSuperview()
//            topBlindView = nil
////            topBlindButton?.removeFromSuperview()
////            topBlindButton = nil
//        }
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
        if let url = URL(string: BootpayConstant.CDN_URL) {
            webview.load(URLRequest(url: url))
        }
    }
     
    @objc public func goBack() {
        webview.goBack()
    }
     
    @objc public func transactionConfirm() {
        Bootpay.transactionConfirm()
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
        
        guard let url = webView.url?.absoluteString else { return; }
        if(url.contains("webview.bootpay.co.kr")) {
            let scriptList = BootpayConstant.getJSBeforePayStart()
            for script in scriptList {
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
            let scriptPay = BootpayConstant.getJSPay(payload: payload, requestType: Bootpay.shared.request_type) 

            webView.evaluateJavaScript(scriptPay, completionHandler: nil)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        Bootpay.shared.webview = webView
        
        guard let url =  navigationAction.request.url else { return decisionHandler(.allow) }
        beforeUrl = url.absoluteString
         
       
        updateBlindViewIfNaverLogin(webView, url.absoluteString)
        
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
              
        if(message.name == BootpayConstant.BRIDGE_NAME) {
            
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    Bootpay.shared.close?()
                    Bootpay.removePaymentWindow()
                } else {
                    let dic = convertStringToDictionary(text: message.body as! String)
                    guard let dic = dic else { return }
                    parseBootpayEvent(data: dic, isRedirect: true)
                }
                return
            }
            parseBootpayEvent(data: body, isRedirect: false)
        }
    }
    
    func parseBootpayEvent(data: [String: Any], isRedirect: Bool) {
        guard let event = data["event"] as? String else { return }
        
        if event == "cancel" {
            Bootpay.shared.cancel?(data)
            if(isRedirect) {
                //redirect는 닫기 이벤트를 안줘서 처리해야함
                Bootpay.shared.close?()
                Bootpay.removePaymentWindow()
            }
        } else if event == "error" {
            Bootpay.shared.error?(data)
            
            //결과를 보는 설정이면 남겨두어야 함
            //redirect는 닫기 이벤트를 안줘서 처리해야함
            if(Bootpay.shared.payload?.extra?.displayErrorResult != true && isRedirect) {
                Bootpay.shared.close?()
                Bootpay.removePaymentWindow()
            }
        } else if event == "issued" {
            Bootpay.shared.issued?(data)
            if(Bootpay.shared.payload?.extra?.displaySuccessResult != true && isRedirect) {
                //redirect는 닫기 이벤트를 안줘서 처리해야함
                Bootpay.shared.close?()
                Bootpay.removePaymentWindow()
            }
        } else if event == "confirm" {
            if let confirm = Bootpay.shared.confirm {
                if(confirm(data)) {
                    Bootpay.transactionConfirm()
                }
            }
        } else if event == "done" {
            Bootpay.shared.done?(data)
            if(Bootpay.shared.payload?.extra?.displaySuccessResult != true && isRedirect) {
                //redirect는 닫기 이벤트를 안줘서 처리해야함
                Bootpay.shared.close?()
                Bootpay.removePaymentWindow()
            }
        } else if event == "close" {
            //결과페이지에서 닫기 버튼 클릭시 
            Bootpay.shared.close?()
            Bootpay.removePaymentWindow()
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
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
    
    
    func startItunesToInstall(_ url: URL) {
        let sUrl = url.absoluteString
        var itunesUrl = ""
         
        if(sUrl.starts(with: "kfc-bankpay")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
        } else if(sUrl.starts(with: "ispmobile")) {
            itunesUrl = "https://apps.apple.com/kr/app/isp/id369125087"
        } else if(sUrl.starts(with: "hdcardappcardansimclick") || sUrl.starts(with: "smhyundaiansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
        } else if(sUrl.starts(with: "shinhan-sr-ansimclick") || sUrl.starts(with: "smshinhanansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
        } else if(sUrl.starts(with: "kb-acp")) {
            itunesUrl = "https://apps.apple.com/kr/app/kb-pay/id695436326"
        } else if(sUrl.starts(with: "liivbank")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
        } else if(sUrl.starts(with: "mpocket.online.ansimclick") || sUrl.starts(with: "ansimclickscard") || sUrl.starts(with: "ansimclickipcollect") || sUrl.starts(with: "samsungpay") || sUrl.starts(with: "scardcertiapp")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
        } else if(sUrl.starts(with: "lottesmartpay")) {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
        } else if(sUrl.starts(with: "lotteappcard")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
        } else if(sUrl.starts(with: "newsmartpib")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
        } else if(sUrl.starts(with: "com.wooricard.wcard")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
        } else if(sUrl.starts(with: "citispay") || sUrl.starts(with: "citicardappkr") || sUrl.starts(with: "citimobileapp")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
        } else if(sUrl.starts(with: "shinsegaeeasypayment")) {
            itunesUrl = "https://apps.apple.com/kr/app/ssgpay/id666237916"
        } else if(sUrl.starts(with: "cloudpay")) {
        
            itunesUrl = "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
        } else if(sUrl.starts(with: "hanawalletmembers")) {
            itunesUrl = "https://apps.apple.com/kr/app/n-wallet/id492190784"
        } else if(sUrl.starts(with: "nhappvardansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        } else if(sUrl.starts(with: "nhallonepayansimclick") || sUrl.starts(with: "nhappcardansimclick") || sUrl.starts(with: "nhallonepayansimclick") || sUrl.starts(with: "nonghyupcardansimclick")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        } else if(sUrl.starts(with: "payco")) {
            itunesUrl = "https://apps.apple.com/kr/app/payco/id924292102"
        } else if(sUrl.starts(with: "lpayapp") || sUrl.starts(with: "lmslpay")) {
            itunesUrl = "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
        } else if(sUrl.starts(with: "naversearchapp")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
        } else if(sUrl.starts(with: "tauthlink")) {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-skt/id1141258007"
        } else if(sUrl.starts(with: "uplusauth") || sUrl.starts(with: "upluscorporation")) {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-u/id1147394645"
        } else if(sUrl.starts(with: "ktauthexternalcall")) {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-kt/id1134371550"
        } else if(sUrl.starts(with: "supertoss")) {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328"
        } else if(sUrl.starts(with: "kakaotalk")) {
            itunesUrl = "https://apps.apple.com/kr/app/kakaotalk/id362057947"
        } else if(sUrl.starts(with: "chaipayment")) {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272"
        }
        
        if(itunesUrl.count > 0) {
            if let appstore = URL(string: itunesUrl) {
                startAppToApp(appstore)
            }
        }
    }
    
    func startAppToApp(_ url: URL) {
//        #if os(iOS)
//        if #available(iOS 10, *) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        } else {
//            UIApplication.shared.openURL(url)
//        }
//        #endif
        
        #if os(iOS)
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { result in
                if(result == false) {
                    self.startItunesToInstall(url)
                }
            })
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
