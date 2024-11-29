//
//  BootpayWebView.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

import WebKit

@objc open class BootpayWebView: WKWebView {
    public var updateHeight: CGFloat = 400 {
        didSet {
            guard oldValue != self.updateHeight else { return }
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = UIScreen.main.bounds.size
        size.height = self.updateHeight
        return size
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)! 
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        initWebView()
    }
    
    private func initWebView() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        if #available(iOS 16.4, *) {
            self.isInspectable = BootpayBuild.DEBUG
        }
        self.uiDelegate = self
        self.navigationDelegate = self
    }
    
    public func loadUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            self.load(request)
        }
    }
}

extension BootpayWebView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url?.absoluteString else { return }
        
        if url.contains("webview.bootpay.co.kr") {
            print("didFinish : \(url)")
            BootpayWebViewHandler.loadBootpayScript()
        }
    }
    
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("didReceive : \(message.name) : \(message.body)")
        BootpayWebViewHandler.didReceiveEvent(self, message)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        updateBlindViewIfNaverLogin(url.absoluteString)
        
        if isItunesURL(url.absoluteString) {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else if url.absoluteString.starts(with: "about:blank") {
            decisionHandler(.allow)
        } else if !url.absoluteString.starts(with: "http") {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
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
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        presentAlertController(with: message, completionHandler: completionHandler)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        presentConfirmAlertController(with: message, completionHandler: completionHandler)
    }
}


//nvaer back button hide
extension BootpayWebView {
    private func updateBlindViewIfNaverLogin(_ url: String) {
        if url.starts(with: "https://nid.naver.com") {
            self.evaluateJavaScript("document.getElementById('back').remove();")
        }
    }
}

extension BootpayWebView {
    private func startItunesToInstall(_ url: URL) {
        guard let itunesUrl = getItunesUrl(from: url.absoluteString) else { return }
        if let appstoreUrl = URL(string: itunesUrl) {
            startAppToApp(appstoreUrl)
        }
    }
    
    private func getItunesUrl(from urlString: String) -> String? {
        switch urlString {
        case let s where s.starts(with: "kfc-bankpay"):
            return "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
        case let s where s.starts(with: "ispmobile"):
            return "https://apps.apple.com/kr/app/isp/id369125087"
        case let s where s.starts(with: "hdcardappcardansimclick") || s.starts(with: "smhyundaiansimclick"):
            return "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
        case let s where s.starts(with: "shinhan-sr-ansimclick") || s.starts(with: "smshinhanansimclick"):
            return "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
        case let s where s.starts(with: "kb-acp"):
            return "https://apps.apple.com/kr/app/kb-pay/id695436326"
        case let s where s.starts(with: "liivbank"):
            return "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
        case let s where s.starts(with: "mpocket.online.ansimclick") || s.starts(with: "ansimclickscard") || s.starts(with: "ansimclickipcollect") || s.starts(with: "samsungpay") || s.starts(with: "scardcertiapp"):
            return "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
        case let s where s.starts(with: "lottesmartpay"):
            return "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
        case let s where s.starts(with: "lotteappcard"):
            return "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
        case let s where s.starts(with: "newsmartpib"):
            return "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
        case let s where s.starts(with: "com.wooricard.wcard"):
            return "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
        case let s where s.starts(with: "citispay") || s.starts(with: "citicardappkr") || s.starts(with: "citimobileapp"):
            return "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
        case let s where s.starts(with: "shinsegaeeasypayment"):
            return "https://apps.apple.com/kr/app/ssgpay/id666237916"
        case let s where s.starts(with: "cloudpay"):
            return "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
        case let s where s.starts(with: "hanawalletmembers"):
            return "https://apps.apple.com/kr/app/n-wallet/id492190784"
        case let s where s.starts(with: "nhappvardansimclick"):
            return "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        case let s where s.starts(with: "nhallonepayansimclick") || s.starts(with: "nhappcardansimclick") || s.starts(with: "nhallonepayansimclick") || s.starts(with: "nonghyupcardansimclick"):
            return "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        case let s where s.starts(with: "payco"):
            return "https://apps.apple.com/kr/app/payco/id924292102"
        case let s where s.starts(with: "lpayapp") || s.starts(with: "lmslpay"):
            return "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
        case let s where s.starts(with: "naversearchapp"):
            return "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
        case let s where s.starts(with: "tauthlink"):
            return "https://apps.apple.com/kr/app/pass-by-skt/id1141258007"
        case let s where s.starts(with: "uplusauth") || s.starts(with: "upluscorporation"):
            return "https://apps.apple.com/kr/app/pass-by-u/id1147394645"
        case let s where s.starts(with: "ktauthexternalcall"):
            return "https://apps.apple.com/kr/app/pass-by-kt/id1134371550"
        case let s where s.starts(with: "supertoss"):
            return "https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328"
        case let s where s.starts(with: "kakaotalk"):
            return "https://apps.apple.com/kr/app/kakaotalk/id362057947"
        case let s where s.starts(with: "chaipayment"):
            return "https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272"
        case let s where s.starts(with: "ukbanksmartbanknonloginpay"):
            return "https://itunes.apple.com/kr/developer/%EC%BC%80%EC%9D%B4%EB%B1%85%ED%81%AC/id1178872626?mt=8"
        case let s where s.starts(with: "newliiv"):
            return "https://apps.apple.com/us/app/%EB%A6%AC%EB%B8%8C-next/id1573528126"
        case let s where s.starts(with: "kbbank"):
            return "https://apps.apple.com/kr/app/kb%EC%8A%A4%ED%83%80%EB%B1%85%ED%82%B9/id373742138"
        default:
            return nil
        }
    }
    
    private func startAppToApp(_ url: URL) {
        #if os(iOS)
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:]) { result in
                if !result {
                    self.startItunesToInstall(url)
                }
            }
        } else {
            UIApplication.shared.openURL(url)
        }
        #endif
    }
    
    private func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return !result.isEmpty
    }
    
    private func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
    
    private func presentAlertController(with message: String, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in completionHandler() })
        alertController.addAction(UIAlertAction(title: "닫기", style: .default) { _ in completionHandler() })
        DispatchQueue.main.async {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func presentConfirmAlertController(with message: String, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default) { _ in completionHandler(true) })
        alertController.addAction(UIAlertAction(title: "닫기", style: .default) { _ in completionHandler(false) })
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
