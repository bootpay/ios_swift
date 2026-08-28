//
//  BootpayWidgetView.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/10.
//

import UIKit
import WebKit

/// 부트페이 위젯 뷰 (UIKit 기반)
/// 앱 화면 내에 삽입 가능한 결제 컴포넌트입니다.
@objc open class BootpayWidgetView: UIView {

    // MARK: - Properties

    /// 웹뷰
    @objc public private(set) var webview: WKWebView!

    /// 위젯 컨트롤러
    @objc public var controller: BootpayWidgetController? {
        didSet {
            controller?.widgetView = self
        }
    }

    /// 결제 페이로드
    @objc public var payload: Payload?

    /// 이전 URL
    private var beforeUrl = ""

    /// 위젯 준비 완료 여부
    private var isWidgetReady = false

    // MARK: - Fullscreen Expansion Properties

    /// 전체화면 확장 여부
    private var isExpanded = false

    /// 원래 부모 뷰
    private weak var originalSuperview: UIView?

    /// 원래 프레임
    private var originalFrame: CGRect = .zero

    /// 원래 constraint들
    private var originalConstraints: [NSLayoutConstraint] = []

    /// 원래 translatesAutoresizingMaskIntoConstraints 값
    private var originalTranslatesAutoresizing: Bool = true

    /// 전체화면용 배경 뷰
    private var backgroundView: UIView?

    /// 전체화면용 constraint들
    private var fullscreenConstraints: [NSLayoutConstraint] = []

    /// 원래 height constraint (외부에서 설정된 것)
    private weak var originalHeightConstraint: NSLayoutConstraint?

    /// 원래 ViewController (전체화면 확장 전 저장)
    private weak var originalViewController: UIViewController?

    /// close 처리 완료 여부 (중복 호출 방지)
    private var isCloseHandled = false

    // MARK: - Initialization

    @objc public override init(frame: CGRect) {
        super.init(frame: frame)
        initComponent()
    }

    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initComponent()
    }

    @objc public convenience init() {
        self.init(frame: .zero)
    }

    // MARK: - Setup

    private func initComponent() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always

        let configuration = WKWebViewConfiguration()

        // JavaScript 활성화
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences

        // 인라인 미디어 재생 허용
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }

        // 메시지 핸들러를 미리 등록 (웹뷰 생성 전)
        configuration.userContentController.add(self, name: BootpayConstant.BRIDGE_NAME)

        webview = WKWebView(frame: bounds, configuration: configuration)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.scrollView.isScrollEnabled = false
        webview.scrollView.bounces = false
        webview.isOpaque = false
        webview.backgroundColor = .white

        addSubview(webview)

        webview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: topAnchor),
            webview.leadingAnchor.constraint(equalTo: leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        self.backgroundColor = .white
    }

    // MARK: - Public Methods

    /// 위젯을 시작합니다.
    @objc public func startWidget() {
        guard let payload = payload else {
            print("[BootpayWidget] payload is nil")
            return
        }

        Bootpay.loadSessionValues()

        if let url = URL(string: BootpayConstant.WIDGET_URL) {
            webview.load(URLRequest(url: url))
        }
    }

    /// 위젯을 재렌더링합니다. (취소 후 초기 상태로 복원)
    @objc public func reloadWidget() {
        guard payload != nil else {
            print("[BootpayWidget] reloadWidget - payload is nil")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            print("[BootpayWidget] Reloading widget URL...")

            // 위젯 URL 다시 로드 (didFinish에서 자동으로 렌더링됨)
            if let url = URL(string: BootpayConstant.WIDGET_URL) {
                self.webview.load(URLRequest(url: url))
            }
        }
    }

    /// 위젯을 업데이트합니다.
    @objc public func widgetUpdate(payload: Payload, refresh: Bool) {
        self.payload = payload
        let script = BootpayConstant.getJSWidgetUpdate(payload: payload, refresh: refresh)
        doJavascript(script)
    }

    /// 위젯에서 결제를 요청합니다.
    @objc public func widgetRequestPayment(payload: Payload?) {
        if let payload = payload {
            self.payload = payload
        }
        guard let currentPayload = self.payload else {
            print("[BootpayWidget] widgetRequestPayment - payload is nil")
            return
        }

        // 플래그 리셋
        isCloseHandled = false

        // 결제 요청 시 전체화면으로 확장
        expandToFullscreen(animated: true)

        let script = BootpayConstant.getJSWidgetRequestPayment(payload: currentPayload)
        print("[BootpayWidget] ===== Request Payment Script START =====")
        print(script)
        print("[BootpayWidget] ===== Request Payment Script END =====")

        // 약간의 딜레이 후 JS 실행 (애니메이션 완료 후)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.webview.evaluateJavaScript(script) { result, error in
                if let error = error {
                    print("[BootpayWidget] RequestPayment JS Error: \(error)")
                } else {
                    print("[BootpayWidget] RequestPayment executed, result: \(String(describing: result))")
                }
            }
        }
    }

    /// 결제를 확인합니다.
    @objc public func transactionConfirm() {
        let script = [
            "window.Bootpay.confirm()",
            ".then( function (res) {",
            BootpayConstant.widgetConfirm(),
            BootpayConstant.widgetIssued(),
            BootpayConstant.widgetDone(),
            "}, function (res) {",
            BootpayConstant.widgetError(),
            BootpayConstant.widgetCancel(),
            "})"
        ].reduce("", +)

        doJavascript(script)
    }

    /// JavaScript를 실행합니다.
    @objc public func doJavascript(_ script: String) {
        webview.evaluateJavaScript(script, completionHandler: nil)
    }

    // MARK: - Fullscreen Expansion

    /// 전체화면으로 확장합니다.
    @objc public func expandToFullscreen(animated: Bool = true) {
        guard !isExpanded else { return }
        guard let window = getKeyWindow() else { return }

        isExpanded = true

        // 원래 상태 저장
        originalSuperview = superview
        originalFrame = frame
        originalTranslatesAutoresizing = translatesAutoresizingMaskIntoConstraints
        originalViewController = findViewController() // ViewController 저장
        print("[BootpayWidget] expandToFullscreen - saved originalViewController: \(String(describing: originalViewController))")

        // 원래 constraint 저장 (이 뷰와 관련된 것들) 및 비활성화
        if let superview = superview {
            originalConstraints = superview.constraints.filter { constraint in
                constraint.firstItem as? UIView == self || constraint.secondItem as? UIView == self
            }
            // 원래 constraint 비활성화
            NSLayoutConstraint.deactivate(originalConstraints)
        }

        // 자체 constraint도 저장 및 비활성화 (height 등)
        let selfConstraints = constraints.filter { constraint in
            constraint.firstItem as? UIView == self && constraint.secondItem == nil
        }
        for constraint in selfConstraints {
            if constraint.firstAttribute == .height {
                originalHeightConstraint = constraint
                constraint.isActive = false
            }
        }

        // 현재 위치를 window 좌표로 변환
        let frameInWindow = convert(bounds, to: window)

        // 배경 뷰 생성 (반투명 검정)
        let bgView = UIView(frame: window.bounds)
        bgView.backgroundColor = UIColor.black.withAlphaComponent(0)
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(bgView)
        backgroundView = bgView

        // 뷰를 window로 이동
        removeFromSuperview()
        window.addSubview(self)

        // 초기 위치 설정 (원래 위치)
        translatesAutoresizingMaskIntoConstraints = true
        frame = frameInWindow

        // 스크롤 활성화 (전체화면에서는 스크롤 필요)
        webview.scrollView.isScrollEnabled = true

        // Safe Area 적용된 전체화면 프레임 계산
        let safeAreaInsets = window.safeAreaInsets
        let safeFrame = CGRect(
            x: safeAreaInsets.left,
            y: safeAreaInsets.top,
            width: window.bounds.width - safeAreaInsets.left - safeAreaInsets.right,
            height: window.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
        )

        // 애니메이션으로 전체화면 확장
        let duration = animated ? 0.35 : 0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.frame = safeFrame
        } completion: { _ in
            // 완료 후에는 frame 기반으로 유지 (constraint 충돌 방지)
        }
    }

    /// 원래 크기로 복원합니다.
    @objc public func collapseToOriginal(animated: Bool = true) {
        collapseToOriginal(animated: animated, reloadWidget: false)
    }

    /// 원래 크기로 복원하면서 위젯을 재로드합니다.
    /// - Parameters:
    ///   - animated: 애니메이션 여부
    ///   - reloadWidget: 축소 시작 전에 위젯 URL을 먼저 로드할지 여부.
    ///                   true로 설정하면 축소 애니메이션 중에 위젯이 렌더링되어 자연스러운 전환이 됩니다.
    @objc public func collapseToOriginal(animated: Bool, reloadWidget: Bool) {
        guard isExpanded else { return }
        guard let window = getKeyWindow(), let originalSuperview = originalSuperview else { return }

        isExpanded = false

        // 전체화면 constraint 제거
        NSLayoutConstraint.deactivate(fullscreenConstraints)
        fullscreenConstraints.removeAll()

        // 원래 위치 (window 좌표로)
        let targetFrame = originalSuperview.convert(originalFrame, to: window)

        translatesAutoresizingMaskIntoConstraints = true
        frame = window.bounds

        // 스크롤 비활성화 (위젯 모드에서는 스크롤 불필요)
        webview.scrollView.isScrollEnabled = false

        // 축소 시작 전에 위젯 URL을 먼저 로드 (Android collapseAndReload와 동일)
        // 이렇게 하면 축소 애니메이션 중에 위젯이 렌더링되어 자연스러운 전환이 됩니다.
        if reloadWidget, let url = URL(string: BootpayConstant.WIDGET_URL) {
            print("[BootpayWidget] collapseToOriginal - reloading widget URL before collapse animation")
            webview.load(URLRequest(url: url))
        }

        // 애니메이션으로 원래 크기로 축소
        let duration = animated ? 0.35 : 0
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseInOut) {
            self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.frame = targetFrame
        } completion: { _ in
            // 배경 뷰 제거
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil

            // 원래 superview로 복원
            self.removeFromSuperview()
            originalSuperview.addSubview(self)

            // 원래 상태로 복원
            self.translatesAutoresizingMaskIntoConstraints = self.originalTranslatesAutoresizing
            self.frame = self.originalFrame

            // 원래 constraint 복원
            if !self.originalTranslatesAutoresizing {
                NSLayoutConstraint.activate(self.originalConstraints)
            }

            // height constraint 복원
            self.originalHeightConstraint?.isActive = true
        }
    }

    /// 전체화면 축소 후 위젯 재로드 (결제 취소/에러 시)
    /// Android의 BootpayWidget.collapseAndReload()와 동일한 동작
    /// 축소 시작 전에 위젯 URL을 먼저 로드하여 자연스러운 전환
    @objc public func collapseAndReload(animated: Bool = true) {
        guard isExpanded else { return }
        print("[BootpayWidget] collapseAndReload called")
        collapseToOriginal(animated: animated, reloadWidget: true)
    }

    /// 전체화면 토글
    @objc public func toggleFullscreen(animated: Bool = true) {
        if isExpanded {
            collapseToOriginal(animated: animated)
        } else {
            expandToFullscreen(animated: animated)
        }
    }

    /// 현재 전체화면 상태인지 확인
    @objc public var isFullscreen: Bool {
        return isExpanded
    }

    // MARK: - Close Action

    /// closeAction에 따른 화면 전환 수행
    private func performCloseAction() {
        guard let closeAction = controller?.closeAction else {
            print("[BootpayWidget] performCloseAction - controller or closeAction is nil")
            return
        }

        print("[BootpayWidget] performCloseAction: \(closeAction)")

        // 저장된 ViewController 또는 현재 찾은 ViewController 사용
        print("[BootpayWidget] performCloseAction - originalViewController: \(String(describing: originalViewController))")
        let viewController = originalViewController ?? findViewController()

        switch closeAction {
        case .popViewController:
            // NavigationController에서 pop
            if let vc = viewController {
                print("[BootpayWidget] Found ViewController: \(vc)")
                if let nav = vc.navigationController {
                    print("[BootpayWidget] NavigationController viewControllers: \(nav.viewControllers)")
                    print("[BootpayWidget] Popping from NavigationController")
                    DispatchQueue.main.async {
                        nav.popViewController(animated: true)
                    }
                } else {
                    print("[BootpayWidget] No NavigationController found, trying dismiss")
                    DispatchQueue.main.async {
                        vc.dismiss(animated: true)
                    }
                }
            } else {
                print("[BootpayWidget] ViewController not found")
            }

        case .dismissViewController:
            // Modal dismiss
            if let vc = viewController {
                print("[BootpayWidget] Dismissing ViewController")
                vc.dismiss(animated: true)
            }

        case .none:
            // 가맹점이 onClose에서 직접 처리
            print("[BootpayWidget] closeAction is none, skipping")
            break
        }
    }

    /// 현재 뷰가 속한 ViewController 찾기
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}

// MARK: - WKNavigationDelegate, WKUIDelegate

extension BootpayWidgetView: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let payload = payload else {
            print("[BootpayWidget] didFinish - payload is nil")
            return
        }
        guard let url = webView.url?.absoluteString else {
            print("[BootpayWidget] didFinish - url is nil")
            return
        }

        print("[BootpayWidget] didFinish - url: \(url)")

        if url.contains("webview.bootpay.co.kr") && url.contains("widget.html") {
            // 위젯 렌더링 스크립트 (이벤트 리스너 + 렌더가 모두 포함됨)
            let scriptWidget = BootpayConstant.getJSWidgetRender(payload: payload)

            // 전체 스크립트 로그 출력
            print("[BootpayWidget] ===== Widget render script START =====")
            print(scriptWidget)
            print("[BootpayWidget] ===== Widget render script END =====")

            if scriptWidget.count > 0 {
                webView.evaluateJavaScript(scriptWidget) { result, error in
                    if let error = error {
                        print("[BootpayWidget] Widget JS Error: \(error)")
                    } else {
                        print("[BootpayWidget] Widget render success")
                    }
                }
            }
        }
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.allow)
        }
        beforeUrl = url.absoluteString

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

    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let popupView = WKWebView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), configuration: configuration)
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView.navigationDelegate = self
        popupView.uiDelegate = self
        addSubview(popupView)
        return popupView
    }

    public func webViewDidClose(_ webView: WKWebView) {
        // 팝업만 제거한다. 본체 webview 를 떼어내면 위젯 화면이 비어버린다.
        if webView != self.webview {
            webView.removeFromSuperview()
            return
        }
        // 본체가 닫히는 경우에만 close 를 통지한다.
        controller?.handleClose()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == BootpayConstant.BRIDGE_NAME {
            if let body = message.body as? [String: Any] {
                parseWidgetEvent(data: body)
            } else if let bodyString = message.body as? String {
                if bodyString == "close" {
                    controller?.handleClose()
                } else if let dic = convertStringToDictionary(text: bodyString) {
                    parseWidgetEvent(data: dic)
                }
            }
        }
    }

    // MARK: - Event Parsing

    private func parseWidgetEvent(data: [String: Any]) {
        guard let event = data["event"] as? String else { return }

        switch event {
        case "widget_ready":
            isWidgetReady = true
            controller?.handleReady()

        case "widget_resize":
            if let height = data["height"] as? CGFloat {
                controller?.handleResize(height: height)
            } else if let heightDouble = data["height"] as? Double {
                controller?.handleResize(height: CGFloat(heightDouble))
            }

        case "widget_change_payment":
            if let widgetData = parseWidgetData(from: data) {
                controller?.handleChangePayment(data: widgetData)
            }

        case "widget_change_agree_term":
            if let widgetData = parseWidgetData(from: data) {
                controller?.handleChangeAgreeTerm(data: widgetData)
            }

        case "error":
            controller?.handleError(data: data)

            // displayErrorResult = false 일 때: 위젯 URL 먼저 로드 후 축소 (Android collapseAndReload와 동일)
            let displayErrorResult = payload?.extra?.displayErrorResult == true
            if !displayErrorResult && isExpanded {
                // 위젯 URL 먼저 로드 후 축소 (자연스러운 UX)
                collapseAndReload(animated: true)
                isCloseHandled = true // close 이벤트 중복 방지
            }

        case "cancel":
            // 취소 시: 위젯 URL 먼저 로드 후 축소 (Android collapseAndReload와 동일)
            // 이렇게 하면 축소되면서 이미 위젯이 렌더링되어 자연스러운 UX
            controller?.handleCancel(data: data)
            collapseAndReload(animated: true)

        case "done":
            controller?.handleDone(data: data)

            // displaySuccessResult = false 일 때: 바로 축소 + closeAction 수행
            let displaySuccessResult = payload?.extra?.displaySuccessResult == true
            if !displaySuccessResult && isExpanded {
                // 웹뷰를 window에서 제거하고 closeAction 수행
                backgroundView?.removeFromSuperview()
                backgroundView = nil
                self.removeFromSuperview()
                isExpanded = false
                isCloseHandled = true // close 이벤트 중복 방지

                // 메인 스레드에서 약간의 딜레이 후 pop (UI 업데이트 완료 후)
                DispatchQueue.main.async { [weak self] in
                    self?.performCloseAction()
                }
            }

        case "confirm":
            if let shouldConfirm = controller?.handleConfirm(data: data), shouldConfirm {
                transactionConfirm()
            }

        case "issued":
            controller?.handleIssued(data: data)

        case "close":
            // 중복 호출 방지
            guard !isCloseHandled else {
                print("[BootpayWidget] close already handled, skipping")
                return
            }
            isCloseHandled = true

            controller?.handleClose()

            // display_success_result 또는 display_error_result 옵션 사용 시
            // 이미 결과를 봤으므로 축소 애니메이션 생략하고 바로 closeAction 수행
            let displayResult = payload?.extra?.displaySuccessResult == true || payload?.extra?.displayErrorResult == true

            if displayResult && isExpanded {
                // 웹뷰를 window에서 제거하고 바로 closeAction 수행
                backgroundView?.removeFromSuperview()
                backgroundView = nil
                self.removeFromSuperview()
                isExpanded = false
                performCloseAction()
            } else {
                // 일반적인 경우: 축소 애니메이션 후 closeAction 처리
                collapseToOriginal(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                    self?.performCloseAction()
                }
            }

        default:
            break
        }
    }

    private func parseWidgetData(from data: [String: Any]) -> WidgetData? {
        if let widgetDataDict = data["data"] as? [String: Any] {
            return WidgetData(JSON: widgetDataDict)
        }
        return WidgetData(JSON: data)
    }

    private func convertStringToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                print("Something went wrong")
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
        alertController.addAction(confirmAction)
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
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "닫기", style: .default, handler: { _ in
            completionHandler(false)
        }))
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

    // MARK: - App to App

    private func startAppToApp(_ url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { result in
                if result == false {
                    self.startItunesToInstall(url)
                }
            })
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    private func startItunesToInstall(_ url: URL) {
        let sUrl = url.absoluteString
        var itunesUrl = ""

        if sUrl.starts(with: "kfc-bankpay") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%B1%85%ED%81%AC%ED%8E%98%EC%9D%B4-%EA%B8%88%EC%9C%B5%EA%B8%B0%EA%B4%80-%EA%B3%B5%EB%8F%99-%EA%B3%84%EC%A2%8C%EC%9D%B4%EC%B2%B4-%EA%B2%B0%EC%A0%9C-%EC%A0%9C%EB%A1%9C%ED%8E%98%EC%9D%B4/id398456030"
        } else if sUrl.starts(with: "ispmobile") {
            itunesUrl = "https://apps.apple.com/kr/app/isp/id369125087"
        } else if sUrl.starts(with: "hdcardappcardansimclick") || sUrl.starts(with: "smhyundaiansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%98%84%EB%8C%80%EC%B9%B4%EB%93%9C/id702653088"
        } else if sUrl.starts(with: "shinhan-sr-ansimclick") || sUrl.starts(with: "smshinhanansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%8B%A0%ED%95%9C%ED%8E%98%EC%9D%B4%ED%8C%90/id572462317"
        } else if sUrl.starts(with: "kb-acp") {
            itunesUrl = "https://apps.apple.com/kr/app/kb-pay/id695436326"
        } else if sUrl.starts(with: "liivbank") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%A6%AC%EB%B8%8C/id1126232922"
        } else if sUrl.starts(with: "mpocket.online.ansimclick") || sUrl.starts(with: "ansimclickscard") || sUrl.starts(with: "ansimclickipcollect") || sUrl.starts(with: "samsungpay") || sUrl.starts(with: "scardcertiapp") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%82%BC%EC%84%B1%EC%B9%B4%EB%93%9C/id535125356"
        } else if sUrl.starts(with: "lottesmartpay") {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C-%EC%95%B1%EC%B9%B4%EB%93%9C/id688047200"
        } else if sUrl.starts(with: "lotteappcard") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%94%94%EC%A7%80%EB%A1%9C%EC%B9%B4-%EB%A1%AF%EB%8D%B0%EC%B9%B4%EB%93%9C/id688047200"
        } else if sUrl.starts(with: "newsmartpib") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%AC-won-%EB%B1%85%ED%82%B9/id1470181651"
        } else if sUrl.starts(with: "com.wooricard.wcard") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%9A%B0%EB%A6%ACwon%EC%B9%B4%EB%93%9C/id1499598869"
        } else if sUrl.starts(with: "citispay") || sUrl.starts(with: "citicardappkr") || sUrl.starts(with: "citimobileapp") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%94%A8%ED%8B%B0%EB%AA%A8%EB%B0%94%EC%9D%BC/id1179759666"
        } else if sUrl.starts(with: "shinsegaeeasypayment") {
            itunesUrl = "https://apps.apple.com/kr/app/ssgpay/id666237916"
        } else if sUrl.starts(with: "cloudpay") {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%95%98%EB%82%98%EC%B9%B4%EB%93%9C-%EC%9B%90%ED%81%90%ED%8E%98%EC%9D%B4/id847268987"
        } else if sUrl.starts(with: "hanawalletmembers") {
            itunesUrl = "https://apps.apple.com/kr/app/n-wallet/id492190784"
        } else if sUrl.starts(with: "nhappvardansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        } else if sUrl.starts(with: "nhallonepayansimclick") || sUrl.starts(with: "nhappcardansimclick") || sUrl.starts(with: "nhallonepayansimclick") || sUrl.starts(with: "nonghyupcardansimclick") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%98%AC%EC%9B%90%ED%8E%98%EC%9D%B4-nh%EC%95%B1%EC%B9%B4%EB%93%9C/id1177889176"
        } else if sUrl.starts(with: "payco") {
            itunesUrl = "https://apps.apple.com/kr/app/payco/id924292102"
        } else if sUrl.starts(with: "lpayapp") || sUrl.starts(with: "lmslpay") {
            itunesUrl = "https://apps.apple.com/kr/app/l-point-with-l-pay/id473250588"
        } else if sUrl.starts(with: "naversearchapp") {
            itunesUrl = "https://apps.apple.com/kr/app/%EB%84%A4%EC%9D%B4%EB%B2%84-naver/id393499958"
        } else if sUrl.starts(with: "tauthlink") {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-skt/id1141258007"
        } else if sUrl.starts(with: "uplusauth") || sUrl.starts(with: "upluscorporation") {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-u/id1147394645"
        } else if sUrl.starts(with: "ktauthexternalcall") {
            itunesUrl = "https://apps.apple.com/kr/app/pass-by-kt/id1134371550"
        } else if sUrl.starts(with: "supertoss") {
            itunesUrl = "https://apps.apple.com/kr/app/%ED%86%A0%EC%8A%A4/id839333328"
        } else if sUrl.starts(with: "kakaotalk") {
            itunesUrl = "https://apps.apple.com/kr/app/kakaotalk/id362057947"
        } else if sUrl.starts(with: "chaipayment") {
            itunesUrl = "https://apps.apple.com/kr/app/%EC%B0%A8%EC%9D%B4/id1459979272"
        } else if sUrl.starts(with: "ukbanksmartbanknonloginpay") {
            itunesUrl = "https://itunes.apple.com/kr/developer/%EC%BC%80%EC%9D%B4%EB%B1%85%ED%81%AC/id1178872626?mt=8"
        } else if sUrl.starts(with: "newliiv") {
            itunesUrl = "https://apps.apple.com/us/app/%EB%A6%AC%EB%B8%8C-next/id1573528126"
        } else if sUrl.starts(with: "kbbank") {
            itunesUrl = "https://apps.apple.com/kr/app/kb%EC%8A%A4%ED%83%80%EB%B1%85%ED%82%B9/id373742138"
        }

        if itunesUrl.count > 0 {
            if let appstore = URL(string: itunesUrl) {
                startAppToApp(appstore)
            }
        }
    }

    private func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return result.count > 0
    }

    private func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
}
