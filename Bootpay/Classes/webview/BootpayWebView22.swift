////
////  BootpayWebView.swift
////  SwiftBootpay
////
////  Created by Taesup Yoon on 2021/05/12.
////
//
//import WebKit
//import NVActivityIndicatorView
//
//@objc open class BootpayWebView22: BTView {
//    @objc public var webview: WKWebView!
//    var circleView: NVActivityIndicatorView?
//    var circleBG: BTView?
//    
//    var beforeUrl = ""
//    
//    var isWidget = false
//    
//    
//    @objc public var onWidgetResize: ((Double) -> Void)?
//    @objc public var onWidgetReady: (() -> Void)?
//    @objc public var onWidgetChangePayment: ((WidgetData) -> Void)?
//    @objc public var onWidgetChangeAgreeTerm: ((WidgetData) -> Void)?
//    
//    public var updatedHeight: CGFloat = 400 {
//        didSet {
//            guard oldValue != updatedHeight else { return }
//            print("updatedHeight : \(updatedHeight)")
////            self.onWidgetResize?(updatedHeight)
//            invalidateIntrinsicContentSize()
//        }
//    }
//    
//    public override var intrinsicContentSize: CGSize {
//        var size = UIScreen.main.bounds.size
//        size.height = self.updatedHeight
//        return size
//    }
//     
//    @objc public init() {
//        #if os(macOS)
//        super.init(frame: NSScreen.main!.frame)
//        #elseif os(iOS)
//        super.init(frame: UIScreen.main.bounds)
//        #endif
//        
//        initComponent()
//        self.backgroundColor = .white
//    }
//    
//    required public init(coder: NSCoder) {
//        super.init(coder: coder)!
//    }
//    
//    func addPaymentEventListener() {
////        let contentController = webview.configuration.userContentController
////        if !isEventHandlerAlreadyAdded(eventName: BootpayConstant.DEFAULT_BRIDGE_NAME, contentController: contentController) {
////            contentController.add(self, name: BootpayConstant.DEFAULT_BRIDGE_NAME)
////        }
//    }
//    
//    func addWidgetEventListener() {
////          let contentController = webview.configuration.userContentController
////          let eventNames = [
////              BootpayConstant.DEFAULT_BRIDGE_NAME,
////              BootpayConstant.BOOTPAY_WIDGET_READY,
////              BootpayConstant.BOOTPAY_WIDGET_RESIZE,
////              BootpayConstant.BOOTPAY_WIDGET_CHANGE_PAYMENT,
////              BootpayConstant.BOOTPAY_WIDGET_CHANGE_TERMS_WATCH
////          ]
////          
////          for eventName in eventNames {
////              if !isEventHandlerAlreadyAdded(eventName: eventName, contentController: contentController) {
////                  contentController.add(self, name: eventName)
////              }
////          }
//        
//    }
//     
//    private func initComponent() {
//        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
//        
//        
//        configureWebView()
//        configureCircleView()
//        
//        setupConstraints()
//        Bootpay.shared.webview = webview
//        showProgressBar(false)
//    }
//    
//    private func configureWebView() {
//        let configuration = WKWebViewConfiguration()
//        
//        #if os(macOS)
//        webview = WKWebView(frame: self.bounds, configuration: configuration)
//        #elseif os(iOS)
//        webview = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
//        #endif
//        
//        if(BootpayBuild.DEBUG) {
//            if #available(iOS 16.4, *) {
//                webview.isInspectable = true
//            }
//        }
//        
//        webview.uiDelegate = self
//        webview.navigationDelegate = self
//        self.addSubview(webview)
//    }
//    
//    private func configureCircleView() {
//        circleBG = BTView()
//        circleBG?.frame = UIScreen.main.bounds
//        circleBG?.backgroundColor = .black.withAlphaComponent(0.25)
//        if let circleBG = circleBG {
//            self.addSubview(circleBG)
//        }
//        
//        circleView = NVActivityIndicatorView(
//            frame: CGRect(x: (UIScreen.main.bounds.width - 40) / 2,
//                          y: (UIScreen.main.bounds.height - 40) / 2 - 60,
//                          width: 40,
//                          height: 40))
//        
//        if let circleView = circleView {
//            circleBG?.addSubview(circleView)
//            circleView.startAnimating()
//        }
//    }
//    
//    private func setupConstraints() {
//        webview.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            webview.topAnchor.constraint(equalTo: self.safeTopAnchor),
//            webview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            webview.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
//            webview.trailingAnchor.constraint(equalTo: self.trailingAnchor)
//        ])
//    }
//    
//    func showProgressBar(_ isShow: Bool) {
//        circleBG?.isHidden = !isShow
//        isShow ? circleView?.startAnimating() : circleView?.stopAnimating()
//    }
//    
//    @objc public func closeView() {
//        let params: [String: Any] = [
//            "code": -102,
//            "action": "BootpayCancel",
//            "message": "사용자가 창을 닫았습니다."
//        ]
//        Bootpay.shared.cancel?(params)
//        removePaymentWindow()
//    }
//    
//    @objc public func startPayment() {
//        isWidget = false
//        if let url = URL(string: BootpayConstant.CDN_URL) {
//            webview.load(URLRequest(url: url))
//        }
//        self.updatedHeight = UIScreen.main.bounds.size.height
//    }
//    
//    @objc public func startWidget() {
//        isWidget = true
//        if let url = URL(string: BootpayConstant.WIDGET_URL) {
//            webview.load(URLRequest(url: url))
//        }
//        self.updatedHeight = 400.0
//    }
//    
//    @objc public func requestPayment() {
//        guard let payload = BootpayWidget.shared.payload else { return }
//        let updateScript = BootpayConstant.getWidgetUpdateScript(payload: payload)
//        let paymentScript = BootpayConstant.getWidgetPaymentScript(payload: payload)
//        
//        print("updateScript: \(updateScript)")
//        print("paymentScript: \(paymentScript)")
//        
//        DispatchQueue.main.async {
//            self.webview.evaluateJavaScript(updateScript, completionHandler: { (result, error) in
//                if let error = error {
//                    print("JavaScript evaluation error: \(error.localizedDescription)\nscript: \(updateScript)")
//                } else {
//                    self.webview.evaluateJavaScript(paymentScript)
//                }
//            })
//        }
//        
//    }
//     
//    @objc public func goBack() {
//        webview.goBack()
//    }
//     
//    @objc public func transactionConfirm() {
//        Bootpay.transactionConfirm()
//    }
//     
//    @objc public func removePaymentWindow() {
//        Bootpay.removePaymentWindow()
//    }
//     
//    @objc public func setPayload(_ data: [String: Any]) {
//        let payload = Payload(JSON: data)
//        Bootpay.shared.payload = payload
//    }
//    
//    private func updateBlindViewIfNaverLogin(_ url: String) {
//        if url.starts(with: "https://nid.naver.com") {
//            webview.evaluateJavaScript("document.getElementById('back').remove();")
//        }
//    }
//    
//    public func showWidgetController() {
//        let viewController = BootpayWidgetController()
//        if var topController = UIApplication.shared.keyWindow?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//            topController.present(viewController, animated: true, completion: nil)
//        }
//        BootpayWidget.shared.widgetController = viewController
//    }
//    
//    public func dismissWidgetController() {
//        BootpayWidget.shared.widgetController?.dismiss(animated: true)
//    }
//    
//    private func parseBootpayEvent(data: [String: Any]) {
//        guard let event = data["event"] as? String else { return }
//        let isRedirect = Bootpay.shared.payload?.extra?.openType == "redirect" ? true : false
//        
////        print(event)
//        
//        switch event {
//        case "cancel":
//            BootpayWidget.shared.paymentResult = .cancel
//            handleCancelEvent(data, isRedirect)
//        case "error":
//            BootpayWidget.shared.paymentResult = .error
//            handleErrorEvent(data, isRedirect)
//        case "issued":
//            handleIssuedEvent(data, isRedirect)
//        case "confirm":
//            showProgressBar(true)
//            if isWidget == true {
//                if let confirm = BootpayWidget.shared.confirm, confirm(data) {
//                    print("BootpayWidget confirm : \(confirm)")
//                    Bootpay.transactionConfirm()
//                }
//            } else {
//                if let confirm = Bootpay.shared.confirm, confirm(data) {
//                    Bootpay.transactionConfirm()
//                }
//            }
//            
//        case "done":
//            BootpayWidget.shared.paymentResult = .done
//            handleDoneEvent(data, isRedirect)
//        case "close":
//            if isWidget == true {
//                handleWidgetCloseEvent()
//            } else {
//                handleCloseEvent()
//            }
//            
//        case "bootpayWidgetFullSizeScreen":
//            print("bootpayWidgetFullSizeScreen")
//            showWidgetController()
//        case "bootpayWidgetRevertScreen":
//            print("bootpayWidgetRevertScreen")
//            BootpayWidget.shared.widgetController?.dismiss(animated: true)
//            BootpayWidget.shared.widgetController = nil
//            BootpayWidget.shared.needReloadWidget?()
//            guard let payload = BootpayWidget.shared.payload else { return }
//            let renderScript = BootpayConstant.getWidgetRenderScript(payload: payload)
//            if !renderScript.isEmpty {
//                DispatchQueue.main.async {
//                    self.webview.evaluateJavaScript(renderScript, completionHandler: nil)
//                }
//            }
//        default:
//            break
//        }
//    }
//    
//    private func handleCancelEvent(_ data: [String: Any], _ isRedirect: Bool) {
//        showProgressBar(false)
//        Bootpay.shared.cancel?(data)
//        if isRedirect {
//            Bootpay.shared.debounceClose()
//            Bootpay.removePaymentWindow()
//        }
//    }
//    
//    private func handleErrorEvent(_ data: [String: Any], _ isRedirect: Bool) {
//        showProgressBar(false)
//        Bootpay.shared.error?(data)
//        if Bootpay.shared.payload?.extra?.displayErrorResult != true && isRedirect {
//            Bootpay.shared.debounceClose()
//            Bootpay.removePaymentWindow()
//        }
//    }
//    
//    private func handleIssuedEvent(_ data: [String: Any], _ isRedirect: Bool) {
//        showProgressBar(false)
//        Bootpay.shared.issued?(data)
//        if Bootpay.shared.payload?.extra?.displaySuccessResult != true && isRedirect {
//            Bootpay.shared.debounceClose()
//            Bootpay.removePaymentWindow()
//        }
//    }
//    
//    private func handleDoneEvent(_ data: [String: Any], _ isRedirect: Bool) {
//        showProgressBar(false)
//        Bootpay.shared.done?(data)
//        if Bootpay.shared.payload?.extra?.displaySuccessResult != true && isRedirect {
//            Bootpay.shared.debounceClose()
//            Bootpay.removePaymentWindow()
//        } else {
//            guard let content = data["data"] as? [String: Any],
//                  let methodOriginSymbol = content["method_origin_symbol"] as? String else { return }
//            if methodOriginSymbol == "card_rebill_rest" {
//                Bootpay.shared.debounceClose()
//                Bootpay.removePaymentWindow()
//            }
//        }
//    }
//    
//    private func handleWidgetCloseEvent() {
//        dismissWidgetController()
//    }
//    
//    private func handleCloseEvent() {
//        doJavascript("Bootpay.destroy();")
//        showProgressBar(false)
//        Bootpay.shared.debounceClose()
//        Bootpay.removePaymentWindow()
//    }
//    
//    private func doJavascript(_ script: String) {
//        webview.evaluateJavaScript(script, completionHandler: nil)
//    }
//    
//    private func loadUrl(_ urlString: String) {
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            webview.load(request)
//        }
//    }
//    
//    private func naverLoginBugFix() {
//        if beforeUrl.starts(with: "naversearchthirdlogin://") {
//            if let session = getQueryStringParameter(url: beforeUrl, param: "session"),
//               let url = URL(string: "https://nid.naver.com/login/scheme.redirect?session=\(session)") {
//                webview.load(URLRequest(url: url))
//            }
//        }
//    }
//    
//    private func getQueryStringParameter(url: String, param: String) -> String? {
//        URLComponents(string: url)?.queryItems?.first(where: { $0.name == param })?.value
//    }
//    
//    private func startItunesToInstall(_ url: URL) {
//        guard let itunesUrl = getItunesUrl(from: url.absoluteString) else { return }
//        if let appstoreUrl = URL(string: itunesUrl) {
//            startAppToApp(appstoreUrl)
//        }
//    }
//    
//    private func getItunesUrl(from urlString: String) -> String? {
//        switch urlString {
//        case let s where s.starts(with: "kfc-bankpay"):
//            return "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
//        case let s where s.starts(with: "ispmobile"):
//            return "https://apps.apple.com/kr/app/isp/id369125087"
//        case let s where s.starts(with: "hdcardappcardansimclick") || s.starts(with: "smhyundaiansimclick"):
//            return "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
//        case let s where s.starts(with: "shinhan-sr-ansimclick") || s.starts(with: "smshinhanansimclick"):
//            return "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
//        case let s where s.starts(with: "kb-acp"):
//            return "https://apps.apple.com/kr/app/kb-pay/id695436326"
//        case let s where s.starts(with: "liivbank"):
//            return "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
//        case let s where s.starts(with: "mpocket.online.ansimclick") || s.starts(with: "ansimclickscard") || s.starts(with: "ansimclickipcollect") || s.starts(with: "samsungpay") || s.starts(with: "scardcertiapp"):
//            return "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
//        case let s where s.starts(with: "lottesmartpay"):
//            return "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
//        case let s where s.starts(with: "lotteappcard"):
//            return "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
//        case let s where s.starts(with: "newsmartpib"):
//            return "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
//        case let s where s.starts(with: "com.wooricard.wcard"):
//            return "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
//        case let s where s.starts(with: "citispay") || s.starts(with: "citicardappkr") || s.starts(with: "citimobileapp"):
//            return "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
//        case let s where s.starts(with: "shinsegaeeasypayment"):
//            return "https://apps.apple.com/kr/app/ssgpay/id666237916"
//        case let s where s.starts(with: "cloudpay"):
//            return "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
//        case let s where s.starts(with: "hanawalletmembers"):
//            return "https://apps.apple.com/kr/app/n-wallet/id492190784"
//        case let s where s.starts(with: "nhappvardansimclick"):
//            return "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
//        case let s where s.starts(with: "nhallonepayansimclick") || s.starts(with: "nhappcardansimclick") || s.starts(with: "nhallonepayansimclick") || s.starts(with: "nonghyupcardansimclick"):
//            return "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
//        case let s where s.starts(with: "payco"):
//            return "https://apps.apple.com/kr/app/payco/id924292102"
//        case let s where s.starts(with: "lpayapp") || s.starts(with: "lmslpay"):
//            return "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
//        case let s where s.starts(with: "naversearchapp"):
//            return "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
//        case let s where s.starts(with: "tauthlink"):
//            return "https://apps.apple.com/kr/app/pass-by-skt/id1141258007"
//        case let s where s.starts(with: "uplusauth") || s.starts(with: "upluscorporation"):
//            return "https://apps.apple.com/kr/app/pass-by-u/id1147394645"
//        case let s where s.starts(with: "ktauthexternalcall"):
//            return "https://apps.apple.com/kr/app/pass-by-kt/id1134371550"
//        case let s where s.starts(with: "supertoss"):
//            return "https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328"
//        case let s where s.starts(with: "kakaotalk"):
//            return "https://apps.apple.com/kr/app/kakaotalk/id362057947"
//        case let s where s.starts(with: "chaipayment"):
//            return "https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272"
//        case let s where s.starts(with: "ukbanksmartbanknonloginpay"):
//            return "https://itunes.apple.com/kr/developer/%EC%BC%80%EC%9D%B4%EB%B1%85%ED%81%AC/id1178872626?mt=8"
//        case let s where s.starts(with: "newliiv"):
//            return "https://apps.apple.com/us/app/%EB%A6%AC%EB%B8%8C-next/id1573528126"
//        case let s where s.starts(with: "kbbank"):
//            return "https://apps.apple.com/kr/app/kb%EC%8A%A4%ED%83%80%EB%B1%85%ED%82%B9/id373742138"
//        default:
//            return nil
//        }
//    }
//    
//    private func startAppToApp(_ url: URL) {
//        #if os(iOS)
//        if #available(iOS 10, *) {
//            UIApplication.shared.open(url, options: [:]) { result in
//                if !result {
//                    self.startItunesToInstall(url)
//                }
//            }
//        } else {
//            UIApplication.shared.openURL(url)
//        }
//        #endif
//    }
//    
//    private func isMatch(_ urlString: String, _ pattern: String) -> Bool {
//        let regex = try! NSRegularExpression(pattern: pattern, options: [])
//        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
//        return !result.isEmpty
//    }
//    
//    private func isItunesURL(_ urlString: String) -> Bool {
//        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
//    }
//    
//    public func loadWidgetScript(_ webView: WKWebView) {
//        guard let payload = BootpayWidget.shared.payload else { return }
//        DispatchQueue.main.async {
//            BootpayConstant.getJSBWidgetRenderefore().forEach {
//                print($0)
//                webView.evaluateJavaScript($0, completionHandler: nil)
//            }
//            let renderScript = BootpayConstant.getWidgetRenderScript(payload: payload)
//            print(renderScript)
//            if !renderScript.isEmpty {
//                self.addWidgetEventListener()
//                webView.evaluateJavaScript(renderScript, completionHandler: nil)
//            }
//        }
//    }
//}
//
//extension BootpayWebView22: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//    
//    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
////        guard let payload = Bootpay.shared.payload else { return }
//        guard let url = webView.url?.absoluteString else { return }
//        
//        if url.contains("webview.bootpay.co.kr") {
//            self.isWidget == true ? loadWidgetScript(webView) : loadPaymentScript(webView)
//        }
//    }
//    
//    private func loadPaymentScript(_ webView: WKWebView) {
//        guard let payload = Bootpay.shared.payload else { return }
//        DispatchQueue.main.async {
//            BootpayConstant.getJSBeforePayStart().forEach {
//                webView.evaluateJavaScript($0, completionHandler: nil)
//            }
//            let scriptPay = BootpayConstant.getPaymentScript(payload: payload, requestType: Bootpay.shared.requestType)
//            if !scriptPay.isEmpty {
//                self.addPaymentEventListener()
//                webView.evaluateJavaScript(scriptPay, completionHandler: nil)
//            }
//        }
//        
//    }
//    
//    
//    
//    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        guard let url = navigationAction.request.url else {
//            decisionHandler(.allow)
//            return
//        }
//        beforeUrl = url.absoluteString
//        updateBlindViewIfNaverLogin(url.absoluteString)
//        
//        if isItunesURL(url.absoluteString) {
//            startAppToApp(url)
//            decisionHandler(.cancel)
//        } else if url.absoluteString.starts(with: "about:blank") {
//            decisionHandler(.allow)
//        } else if !url.absoluteString.starts(with: "http") {
//            startAppToApp(url)
//            decisionHandler(.cancel)
//        } else {
//            decisionHandler(.allow)
//        }
//    }
//    
//    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
//            completionHandler(.useCredential, credential)
//        } else {
//            completionHandler(.performDefaultHandling, nil)
//        }
//    }
//    
//    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
//        let popupView = WKWebView(frame: self.bounds, configuration: configuration)
//        #if os(iOS)
//        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        #endif
//        popupView.navigationDelegate = self
//        popupView.uiDelegate = self
//
//        self.addSubview(popupView)
//        return popupView
//    }
//        
//    public func webViewDidClose(_ webView: WKWebView) {
//        webView.removeFromSuperview()
//    }
//    
//    
//    
//     
//    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        if message.name == BootpayConstant.DEFAULT_BRIDGE_NAME {
//            guard let body = message.body as? [String: Any] else {
//                if let bodyString = message.body as? String, bodyString == "close" {
//                    Bootpay.shared.debounceClose()
//                    Bootpay.removePaymentWindow()
//                } else if let bodyString = message.body as? String, let dic = convertStringToDictionary(text: bodyString) {
//                    parseBootpayEvent(data: dic)
//                }
//                return
//            }
//            parseBootpayEvent(
//        } else if message.name == BootpayConstant.BOOTPAY_WIDGET_READY {
//            BootpayWidget.shared.onWidgetReady?()
//        } else if message.name == BootpayConstant.BOOTPAY_WIDGET_RESIZE {
//            guard let body = message.body as? [String: Any] else { return }
//            guard let height = body["height"] as? Double else {return}
//            if(updatedHeight == height) { return }
// 
//                
//            
//            updatedHeight = height
//            BootpayWidget.shared.onWidgetResize?(height)
//        } else if message.name == BootpayConstant.BOOTPAY_WIDGET_CHANGE_PAYMENT {
//            guard let body = message.body as? [String: Any] else { return }
//            if let data = WidgetData(JSON: body) {
//                BootpayWidget.shared.onWidgetChangePayment?(data)
//            }
//        } else if message.name == BootpayConstant.BOOTPAY_WIDGET_CHANGE_TERMS_WATCH {
//            guard let body = message.body as? [String: Any] else { return }
//            if let data = WidgetData(JSON: body) {
//                BootpayWidget.shared.onWidgetChangeAgreeTerm?(data)
//            }
//        }
//    }
//    
//    private func convertStringToDictionary(text: String) -> [String: Any]? {
//        if let data = text.data(using: .utf8) {
//            do {
//                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
//            } catch {
//                print("Something went wrong")
//            }
//        }
//        return nil
//    }
//    
//    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
//        presentAlertController(with: message, completionHandler: completionHandler)
//    }
//    
//    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
//        presentConfirmAlertController(with: message, completionHandler: completionHandler)
//    }
//    
//    private func presentAlertController(with message: String, completionHandler: @escaping () -> Void) {
//        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in completionHandler() })
//        alertController.addAction(UIAlertAction(title: "닫기", style: .default) { _ in completionHandler() })
//        DispatchQueue.main.async {
//            if var topController = UIApplication.shared.keyWindow?.rootViewController {
//                while let presentedViewController = topController.presentedViewController {
//                    topController = presentedViewController
//                }
//                topController.present(alertController, animated: true, completion: nil)
//            }
//        }
//    }
//    
//    private func presentConfirmAlertController(with message: String, completionHandler: @escaping (Bool) -> Void) {
//        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in completionHandler(true) })
//        alertController.addAction(UIAlertAction(title: "닫기", style: .default) { _ in completionHandler(false) })
//        DispatchQueue.main.async {
//            if var topController = UIApplication.shared.keyWindow?.rootViewController {
//                while let presentedViewController = topController.presentedViewController {
//                    topController = presentedViewController
//                }
//                topController.present(alertController, animated: true, completion: nil)
//            }
//        }
//    }
//    
//}
