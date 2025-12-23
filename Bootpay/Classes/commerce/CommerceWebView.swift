//
//  CommerceWebView.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

import UIKit
import WebKit

@objc open class CommerceWebView: UIView {
    @objc public var webview: WKWebView!
    var circleView: UIActivityIndicatorView?
    var circleBG: UIView?
    var beforeUrl = ""
    var topBlindView: UIView?
    var topBlindButton: UIButton?

    @objc public init() {
        super.init(frame: UIScreen.main.bounds)
        initComponent()
        self.backgroundColor = .white
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initComponent()
    }

    func addBootpayEventListener() {
        webview.configuration.userContentController.add(self, name: BootpayConstant.BRIDGE_NAME)
    }

    func initComponent() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always

        let configuration = WKWebViewConfiguration()

        // JavaScript 설정
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences

        // 웹페이지 설정 (iOS 13+)
        if #available(iOS 13.0, *) {
            let webpagePreferences = WKWebpagePreferences()
            webpagePreferences.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = webpagePreferences
        }

        // 인라인 미디어 재생 허용
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        webview = WKWebView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            ),
            configuration: configuration
        )

        // iOS 16.4+ Web Inspector 활성화 (디버깅용)
        if #available(iOS 16.4, *) {
            webview.isInspectable = true
        }

        webview.uiDelegate = self
        webview.navigationDelegate = self
        self.addSubview(webview)

        // 로딩 인디케이터
        circleBG = UIView()
        if let circleBG = circleBG {
            circleBG.frame = CGRect(
                x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
            circleBG.backgroundColor = .black.withAlphaComponent(0.25)
            self.addSubview(circleBG)
        }

        circleView = UIActivityIndicatorView(style: .large)
        circleView?.color = .white
        circleView?.center = CGPoint(
            x: UIScreen.main.bounds.width / 2,
            y: UIScreen.main.bounds.height / 2 - 60
        )

        if let circleView = circleView {
            circleBG?.addSubview(circleView)
            circleView.startAnimating()
        }

        webview.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            webview.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            webview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webview.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            webview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)

        BootpayCommerce.shared.webview = webview
        showProgressBar(true)
    }

    func showProgressBar(_ isShow: Bool) {
        circleBG?.isHidden = !isShow
        if isShow {
            circleView?.startAnimating()
        } else {
            circleView?.stopAnimating()
        }
    }

    func updateBlindViewIfNaverLogin(_ webView: WKWebView, _ url: String) {
        if url.starts(with: "https://nid.naver.com") {
            webView.evaluateJavaScript("document.getElementById('back').remove();")
        }
    }

    @objc public func startCommerce() {
        // Commerce CDN URL 로드 (기존 BootpayWebView 패턴과 동일)
        if let url = URL(string: BootpayConstant.COMMERCE_URL) {
            webview.load(URLRequest(url: url))
            print("[CommerceWebView] Loading URL: \(url)")
        }
    }

    @objc public func closeView() {
        var params = [String: Any]()
        params["code"] = -102
        params["action"] = "BootpayCancel"
        params["message"] = "사용자가 창을 닫았습니다."

        BootpayCommerce.shared.cancel?(params)
        BootpayCommerce.removePaymentWindow()
    }

    @objc public func goBack() {
        webview.goBack()
    }
}

// MARK: - WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler
extension CommerceWebView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let payload = BootpayCommerce.shared.payload else { return }
        guard let url = webView.url?.absoluteString else { return }

        // Commerce 페이지 로드 완료 시 JavaScript 주입
        if url.contains("webview.bootpay.co.kr/commerce") {
            // 환경 설정
            let envScript = "BootpayCommerce.setEnvironmentMode('\(BootpayCommerce.shared.environmentMode)');"
            webView.evaluateJavaScript(envScript, completionHandler: nil)
            print("[CommerceWebView] setEnvironmentMode: \(BootpayCommerce.shared.environmentMode)")

            // 이벤트 리스너 등록
            self.addBootpayEventListener()

            // 결제 요청 JavaScript 실행
            let checkoutScript = BootpayCommerce.getJSCommerceCheckout(payload: payload)
            webView.evaluateJavaScript(checkoutScript, completionHandler: nil)
            print("[CommerceWebView] requestCheckout executed")
        }

        showProgressBar(false)
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            print("[CommerceWebView] decidePolicyFor: URL is nil, allowing")
            return decisionHandler(.allow)
        }

        let urlString = url.absoluteString
        print("[CommerceWebView] decidePolicyFor: \(urlString)")
        print("[CommerceWebView] navigationType: \(navigationAction.navigationType.rawValue)")

        beforeUrl = urlString

        updateBlindViewIfNaverLogin(webView, urlString)

        // redirect_url 콜백 처리 (api.bootpay.co.kr/v2/callback)
        if urlString.contains("api.bootpay.co.kr/v2/callback") {
            print("[CommerceWebView] -> Callback URL detected, handling...")
            handleCallbackURL(url)
            decisionHandler(.cancel)
            return
        }

        if isItunesURL(urlString) {
            print("[CommerceWebView] -> iTunes URL, cancel & appToApp")
            startAppToApp(url)
            decisionHandler(.cancel)
        } else if urlString.starts(with: "about:blank") {
            print("[CommerceWebView] -> about:blank, allow")
            decisionHandler(.allow)
        } else if !urlString.starts(with: "http") {
            print("[CommerceWebView] -> Non-http scheme, cancel & appToApp")
            startAppToApp(url)
            decisionHandler(.cancel)
        } else {
            print("[CommerceWebView] -> HTTP URL, allow")
            decisionHandler(.allow)
        }
    }

    /// redirect_url 콜백 처리
    private func handleCallbackURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("[CommerceWebView] Failed to parse callback URL")
            return
        }

        var data: [String: Any] = [:]

        // Query parameters 파싱
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value {
                    // metadata는 JSON 문자열이므로 파싱 시도
                    if item.name == "metadata", let jsonData = value.data(using: .utf8) {
                        if let metadata = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                            data["metadata"] = metadata
                        } else {
                            data[item.name] = value
                        }
                    } else {
                        data[item.name] = value
                    }
                }
            }
        }

        print("[CommerceWebView] Callback data: \(data)")

        // event에 따라 콜백 호출
        let event = data["event"] as? String ?? ""

        showProgressBar(false)

        switch event {
        case "done":
            BootpayCommerce.shared.done?(data)
        case "cancel":
            BootpayCommerce.shared.cancel?(data)
        case "error":
            BootpayCommerce.shared.error?(data)
        default:
            // event가 없으면 receipt_id로 판단
            if data["receipt_id"] != nil {
                BootpayCommerce.shared.done?(data)
            } else {
                BootpayCommerce.shared.cancel?(data)
            }
        }

        BootpayCommerce.shared.debounceClose()
        BootpayCommerce.removePaymentWindow()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("[CommerceWebView] didFail: \(error.localizedDescription)")
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("[CommerceWebView] didFailProvisionalNavigation: \(error.localizedDescription)")
    }

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height),
            configuration: configuration
        )
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView.navigationDelegate = self
        popupView.uiDelegate = self
        self.addSubview(popupView)
        return popupView
    }

    public func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == BootpayConstant.BRIDGE_NAME {
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    BootpayCommerce.shared.debounceClose()
                    BootpayCommerce.removePaymentWindow()
                } else if let bodyString = message.body as? String {
                    let dic = convertStringToDictionary(text: bodyString)
                    if let dic = dic {
                        parseCommerceEvent(data: dic)
                    }
                }
                return
            }
            parseCommerceEvent(data: body)
        }
    }

    func parseCommerceEvent(data: [String: Any]) {
        guard let event = data["event"] as? String else {
            // event가 없으면 done 이벤트로 처리 (receipt_id가 있는 경우)
            if data["receipt_id"] != nil {
                showProgressBar(false)
                BootpayCommerce.shared.done?(data)
                BootpayCommerce.shared.debounceClose()
                BootpayCommerce.removePaymentWindow()
            }
            return
        }

        switch event {
        case "cancel":
            showProgressBar(false)
            BootpayCommerce.shared.cancel?(data)
            BootpayCommerce.shared.debounceClose()
            BootpayCommerce.removePaymentWindow()

        case "error":
            showProgressBar(false)
            BootpayCommerce.shared.error?(data)
            BootpayCommerce.shared.debounceClose()
            BootpayCommerce.removePaymentWindow()

        case "done":
            showProgressBar(false)
            BootpayCommerce.shared.done?(data)
            BootpayCommerce.shared.debounceClose()
            BootpayCommerce.removePaymentWindow()

        case "close":
            doJavascript("BootpayCommerce.destroy();")
            showProgressBar(false)
            BootpayCommerce.shared.debounceClose()
            BootpayCommerce.removePaymentWindow()

        default:
            print("[CommerceWebView] Unknown event: \(event)")
        }
    }

    func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                print("[CommerceWebView] JSON parse error: \(error)")
            }
        }
        return nil
    }

    // MARK: - Alert Handlers

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
            if var topController = self.getKeyWindow()?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        })
        alertController.addAction(UIAlertAction(title: "닫기", style: .default) { _ in
            completionHandler(false)
        })
        DispatchQueue.main.async {
            if var topController = self.getKeyWindow()?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

// MARK: - JavaScript & URL Helpers
extension CommerceWebView {
    public func doJavascript(_ script: String) {
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
        // 네아로 로그인일 경우 요청
        if beforeUrl.starts(with: "naversearchthirdlogin://") {
            if let value = getQueryStringParameter(url: beforeUrl, param: "session") {
                if let url = URL(string: "https://nid.naver.com/login/scheme.redirect?session=\(value)") {
                    self.webview.load(URLRequest(url: url))
                }
            }
        }
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}

// MARK: - App to App (앱스키마 처리)
extension CommerceWebView {
    func startAppToApp(_ url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:]) { result in
                if !result {
                    self.startItunesToInstall(url)
                }
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    func startItunesToInstall(_ url: URL) {
        let sUrl = url.absoluteString
        var itunesUrl = ""

        // 뱅크페이
        if sUrl.starts(with: "kfc-bankpay") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
        }
        // ISP
        else if sUrl.starts(with: "ispmobile") {
            itunesUrl = "https://apps.apple.com/kr/app/isp/id369125087"
        }
        // 현대카드
        else if sUrl.starts(with: "hdcardappcardansimclick") || sUrl.starts(with: "smhyundaiansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
        }
        // 신한카드
        else if sUrl.starts(with: "shinhan-sr-ansimclick") || sUrl.starts(with: "smshinhanansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
        }
        // KB페이
        else if sUrl.starts(with: "kb-acp") {
            itunesUrl = "https://apps.apple.com/kr/app/kb-pay/id695436326"
        }
        // 리브
        else if sUrl.starts(with: "liivbank") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
        }
        // 삼성카드
        else if sUrl.starts(with: "mpocket.online.ansimclick") || sUrl.starts(with: "ansimclickscard") || sUrl.starts(with: "ansimclickipcollect") || sUrl.starts(with: "samsungpay") || sUrl.starts(with: "scardcertiapp") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
        }
        // 롯데카드
        else if sUrl.starts(with: "lottesmartpay") {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
        }
        else if sUrl.starts(with: "lotteappcard") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
        }
        // 우리은행
        else if sUrl.starts(with: "newsmartpib") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
        }
        // 우리카드
        else if sUrl.starts(with: "com.wooricard.wcard") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
        }
        // 씨티카드
        else if sUrl.starts(with: "citispay") || sUrl.starts(with: "citicardappkr") || sUrl.starts(with: "citimobileapp") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
        }
        // SSG페이
        else if sUrl.starts(with: "shinsegaeeasypayment") {
            itunesUrl = "https://apps.apple.com/kr/app/ssgpay/id666237916"
        }
        // 하나카드
        else if sUrl.starts(with: "cloudpay") {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
        }
        else if sUrl.starts(with: "hanawalletmembers") {
            itunesUrl = "https://apps.apple.com/kr/app/n-wallet/id492190784"
        }
        // NH앱카드
        else if sUrl.starts(with: "nhappvardansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        }
        else if sUrl.starts(with: "nhallonepayansimclick") || sUrl.starts(with: "nhappcardansimclick") || sUrl.starts(with: "nhallonepayansimclick") || sUrl.starts(with: "nonghyupcardansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        }
        // 페이코
        else if sUrl.starts(with: "payco") {
            itunesUrl = "https://apps.apple.com/kr/app/payco/id924292102"
        }
        // L.pay
        else if sUrl.starts(with: "lpayapp") || sUrl.starts(with: "lmslpay") {
            itunesUrl = "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
        }
        // 네이버
        else if sUrl.starts(with: "naversearchapp") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
        }
        // PASS (SKT)
        else if sUrl.starts(with: "tauthlink") {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-skt/id1141258007"
        }
        // PASS (LGU+)
        else if sUrl.starts(with: "uplusauth") || sUrl.starts(with: "upluscorporation") {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-u/id1147394645"
        }
        // PASS (KT)
        else if sUrl.starts(with: "ktauthexternalcall") {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-kt/id1134371550"
        }
        // 토스
        else if sUrl.starts(with: "supertoss") {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328"
        }
        // 카카오톡
        else if sUrl.starts(with: "kakaotalk") {
            itunesUrl = "https://apps.apple.com/kr/app/kakaotalk/id362057947"
        }
        // 차이
        else if sUrl.starts(with: "chaipayment") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272"
        }
        // 케이뱅크
        else if sUrl.starts(with: "ukbanksmartbanknonloginpay") {
            itunesUrl = "https://itunes.apple.com/kr/developer/%EC%BC%80%EC%9D%B4%EB%B1%85%ED%81%AC/id1178872626?mt=8"
        }
        // 리브 Next
        else if sUrl.starts(with: "newliiv") {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A6%AC%EB%B8%8C-next/id1573528126"
        }
        // KB스타뱅킹
        else if sUrl.starts(with: "kbbank") {
            itunesUrl = "https://apps.apple.com/kr/app/kb%EC%8A%A4%ED%83%80%EB%B1%85%ED%82%B9/id373742138"
        }

        if !itunesUrl.isEmpty {
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
