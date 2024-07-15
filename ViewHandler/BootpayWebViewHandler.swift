//
//  BootpayWebViewHandler.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

import WebKit

class BootpayWebViewHandler {
    public static let shared = BootpayWebViewHandler()
    
    private var isWidget = false
    public var requestType: RequestType = .payment
    private var paymentStatus: PaymentStatus = .none

    public var bootpayView: BootpayView?
    private var viewController: BootpayController?
    
    static public func initWebView() {
        print("initWebView : \(shared.bootpayView == nil)")
        if shared.isWidget == true {
            if shared.bootpayView == nil { shared.bootpayView = BootpayView() }
        } else {
            shared.bootpayView = BootpayView()
        }
    }
    
    static public func removePaymentWindow() {
//        guard let webView = shared.bootpayView?.webView else { return }
//        print("removePaymentWindow")
//        executeJavaScript(webView, [BootpayScript.getRemovePaymentWindowScript(), BootpayScript.removeCloseEvent()])
        dismissController()
        dispose()
    }
    
    static public func dispose() {
        shared.bootpayView?.webView = nil
        shared.bootpayView = nil
    }
    
    static public func loadBootpayUrl() {
        guard let webView = shared.bootpayView?.webView else { return }
        shared.isWidget ? loadWidgetUrl() : loadPaymentUrl()
    }
    
    static public func loadBootpayScript() {
        guard let webView = shared.bootpayView?.webView else { return }
        shared.isWidget ? loadWidgetScript(webView) : loadPaymentScript(webView)
    }
    
//    static public func didFinish() {
//        guard let webView = shared.bootpayView?.webView else { return }
//        shared.isWidget ? loadWidgetHtml(webView) : loadPaymentHtml(webView)
//    }

    static public func renderWidget() -> UIView? {
        initWebView()
        shared.isWidget = true
        loadBootpayUrl()
        return shared.bootpayView
    }

    static public func updatePaymentState(_ state: PaymentStatus) {
        shared.paymentStatus = state
    }

    static public func requestWidgetPayment(_ payload: Payload, rootViewController: UIViewController? = nil) {
        guard let webView = shared.bootpayView?.webView else { return }
        shared.requestType = .widgetPayment
        addPaymentEventListener(webView)
        requestWidgetPaymentScript(payload)
        showWidgetController(rootViewController)
    }

    static public func showWidgetController(_ rootViewController: BTViewController? = nil) {
        let viewController = BootpayController()
        if let rootViewController = rootViewController {
            rootViewController.present(viewController, animated: true, completion: nil)
        } else {
            presentOnTopViewController(viewController)
        }
        shared.viewController = viewController
    }

    static public func dismissController() {
        shared.viewController?.dismiss(animated: true)
    }

    static public func debounceClose() {
        shared.isWidget ? debounceWidgetClose() : debouncePaymentClose()
    }
    
    static public func setRequestType(_ type: RequestType) {
        shared.requestType = type
    }

    static public func widgetStatusReset() {
        loadWidgetUrl()
        if shared.paymentStatus == .none {
            BootpayWidget.shared.cancel?([
                "code": -102,
                "action": "BootpayCancel",
                "message": "사용자가 창을 닫았습니다."
            ])
        }
        shared.paymentStatus = .none
    }
     
    static public func didReceiveEvent(_ webView: BootpayWebView, _ message: WKScriptMessage) {
        switch message.name {
        case BootpayEvent.close.rawValue:
            handleEvent(message, with: handleCloseEvent)
        case BootpayEvent.done.rawValue:
            handleEvent(message, with: handleDoneEvent)
        case BootpayEvent.cancel.rawValue:
            handleEvent(message, with: handleCancelEvent)
        case BootpayEvent.error.rawValue:
            handleEvent(message, with: handleErrorEvent)
        case BootpayEvent.issued.rawValue:
            handleEvent(message, with: handleIssuedEvent)
        case BootpayEvent.confirm.rawValue:
            handleEvent(message, with: handleConfirmEvent)
        case BootpayWidgetEvent.ready.rawValue:
            handleEvent(message, with: handleWidgetReadyEvent)
        case BootpayWidgetEvent.resize.rawValue:
            handleEvent(message, with: handleWidgetResizeEvent)
        case BootpayWidgetEvent.changePayment.rawValue:
            handleEvent(message, with: handleWidgetChangePaymentEvent)
        case BootpayWidgetEvent.changeTermsWatch.rawValue:
            handleEvent(message, with: handleWidgetChangeTermsEvent)
        default:
            print("handleDefaultEvent")
            handleEvent(message, with: handleDefaultEvent)
        }
    }
    
    static public func transactionConfirm() {
        guard let webView = shared.bootpayView?.webView else { return }
//        webView.ex
        webView.evaluateJavaScript(BootpayScript.getTransactionConfirmScript())
    }
}

//private extension BootpayWebViewHandler {
//    static private func initWebView() {
//        if shared.bootpayView == nil { shared.bootpayView = BootpayView() }
//    }
//    
//}

private extension BootpayWebViewHandler {
    static func handleEvent(_ message: WKScriptMessage, with handler: (WKScriptMessage) -> Void) {
        handler(message)
    }

    static func handleCloseEvent(_ message: WKScriptMessage) {
        print("handleCloseEvent")
        debouncePaymentClose()
    }

    static func handleDoneEvent(_ message: WKScriptMessage) {
        updatePaymentState(.done)
        shared.bootpayView?.showProgressBar(false)
        guard let data = messageBodyToDictionary(message) else { return }
        let isRedirect = Bootpay.shared.payload?.extra?.openType == "redirect"
        Bootpay.shared.done?(data)
        if shouldClosePaymentWindow(isRedirect: isRedirect, data: data) {
            debouncePaymentClose()
            Bootpay.removePaymentWindow()
        }
    }

    static func handleCancelEvent(_ message: WKScriptMessage) {
        updatePaymentState(.cancel)
        guard let data = messageBodyToDictionary(message) else { return }
        Bootpay.shared.cancel?(data)
        if Bootpay.shared.payload?.extra?.openType == "redirect" {
            debouncePaymentClose()
            Bootpay.removePaymentWindow()
        }
    }

    static func handleIssuedEvent(_ message: WKScriptMessage) {
        updatePaymentState(.issued)
        shared.bootpayView?.showProgressBar(false)
        guard let data = messageBodyToDictionary(message) else { return }
        Bootpay.shared.issued?(data)
        if Bootpay.shared.payload?.extra?.openType == "redirect" {
            debouncePaymentClose()
            Bootpay.removePaymentWindow()
        }
    }

    static func handleErrorEvent(_ message: WKScriptMessage) {
        updatePaymentState(.error)
        shared.bootpayView?.showProgressBar(false)
        guard let data = messageBodyToDictionary(message) else { return }
        Bootpay.shared.error?(data)
        if Bootpay.shared.payload?.extra?.openType == "redirect" {
            debouncePaymentClose()
            Bootpay.removePaymentWindow()
        }
    }

    static func handleConfirmEvent(_ message: WKScriptMessage) {
        shared.bootpayView?.showProgressBar(false)
        print(message.body)
        guard let data = messageBodyToDictionary(message) else { return }
        if shared.isWidget {
//            BootpayWidget.shared.confirm?(data) == true ? transactionConfirm() : nil
            if let confirm = BootpayWidget.shared.confirm, confirm(data) {
                transactionConfirm()
            }
        } else {
//            Bootpay.shared.confirm?(data) == true ? transactionConfirm() : nil
            if let confirm = Bootpay.shared.confirm, confirm(data) {
                transactionConfirm()
            }
        }
    }

    static func handleWidgetReadyEvent(_ message: WKScriptMessage) {
        BootpayWidget.shared.onWidgetReady?()
    }

    static func handleWidgetResizeEvent(_ message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let height = body["height"] as? CGFloat else { return }
        if shared.bootpayView?.webView?.updateHeight != height {
            shared.bootpayView?.webView?.updateHeight = height
            BootpayWidget.shared.onWidgetResize?(height)
        }
    }

    static func handleWidgetChangePaymentEvent(_ message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let data = WidgetData(JSON: body) else { return }
        BootpayWidget.shared.onWidgetChangePayment?(data)
    }

    static func handleWidgetChangeTermsEvent(_ message: WKScriptMessage) {
        guard let body = message.body as? [String: Any], let data = WidgetData(JSON: body) else { return }
        BootpayWidget.shared.onWidgetChangeAgreeTerm?(data)
    }

    static func handleDefaultEvent(_ message: WKScriptMessage) {
        guard let data = messageBodyToDictionary(message), let event = data["event"] as? String else { return }
        switch event {
        case "bootpayWidgetFullSizeScreen":
            showWidgetController()
        case "bootpayWidgetRevertScreen":
            dismissController()
            BootpayWidget.shared.needReloadWidget?()
            if let webView = shared.bootpayView?.webView {
                reloadWidgetScript(webView)
            }
        case "cancel":
            handleCancelEvent(message)
            break
        case "confirm": //redirect
            handleConfirmEvent(message)
            break
        case "issued":
            handleIssuedEvent(message)
            break
        case "done":
            handleDoneEvent(message)
            break
        case "close":
            handleCloseEvent(message)
            break
        default:
            break
        }
    }

    static func messageBodyToDictionary(_ message: WKScriptMessage) -> [String: Any]? {
        guard let bodyDic = message.body as? [String: Any] else {
            guard let bodyString = message.body as? String, let data = bodyString.data(using: .utf8) else { return nil }
            return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) as? [String: Any]
        }
        return bodyDic
    }

    static func presentOnTopViewController(_ viewController: UIViewController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(viewController, animated: true, completion: nil)
        }
    }

    static func shouldClosePaymentWindow(isRedirect: Bool, data: [String: Any]) -> Bool {
        if Bootpay.shared.payload?.extra?.displaySuccessResult == true { return false }
        if isRedirect { return true }
        if let content = data["data"] as? [String: Any], let methodOriginSymbol = content["method_origin_symbol"] as? String {
            return methodOriginSymbol == "card_rebill_rest"
        }
        return false
    }
    
    
}

private extension BootpayWebViewHandler {
    static func loadWidgetUrl() {
//        shared.isWidget = true
        shared.bootpayView?.webView?.loadUrl(BootpayConstant.WIDGET_URL)
        shared.bootpayView?.webView?.updateHeight = 400.0
    }

    static func loadPaymentUrl() {
//        shared.isWidget = false
        shared.bootpayView?.webView?.loadUrl(BootpayConstant.CDN_URL)
        shared.bootpayView?.webView?.updateHeight = UIScreen.main.bounds.size.height
    }

    static func loadWidgetScript(_ webView: BootpayWebView) {
        if BootpayWidget.shared.payload == nil { return }
        addWidgetEventListener(webView)
        executeJavaScript(webView, BootpayScript.getJSBWidgetRenderefore())
        reloadWidgetScript(webView)
        
//        executeJavaScript(webView, BootpayScript.getJSBWidgetRenderefore(), completion: {
//            reloadWidgetScript(webView)
//        })
    }

    static func reloadWidgetScript(_ webView: BootpayWebView) {
        guard let payload = BootpayWidget.shared.payload else { return }
        let scriptPay = BootpayScript.getWidgetRenderScript(payload: payload)
        executeJavaScript(webView, [scriptPay])
    }

    static func loadPaymentScript(_ webView: BootpayWebView) {
        guard let payload = Bootpay.shared.payload else { return }
        payload.user?.setEncodedValueAll()
        BootpayScript.bindAppScheme(payload)
        addPaymentEventListener(webView)
         
        executeJavaScript(webView, BootpayScript.getJSBeforePayStart())
        let scriptPay = BootpayScript.getPaymentScript(payload: payload, requestType: shared.requestType)
        executeJavaScript(webView, [scriptPay])
         
    }

    static func debounceWidgetClose() {
        BootpayWidget.shared.needReloadWidget?()
        DispatchQueue.main.async {
            widgetStatusReset()
        }
        
//        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
//            
//            widgetStatusReset()
//        }
    }

    static func debouncePaymentClose() {
        Bootpay.shared.close?()
        removePaymentWindow()
    }

    static func requestWidgetPaymentScript(_ payload: Payload) {
        guard let webView = shared.bootpayView?.webView else { return }
        let updateScript = BootpayScript.getWidgetUpdateScript(payload: payload)
        let paymentScript = BootpayScript.getWidgetPaymentScript(payload: payload)
//        executeJavaScript(webView, [updateScript], completion: {
//            executeJavaScript(webView, [paymentScript])
//        })
        executeJavaScript(webView, [updateScript])
        executeJavaScript(webView, [paymentScript])
    }

//    static func executeJavaScript(_ webView: BootpayWebView, _ scripts: [String], completion: (() -> Void)? = nil) {
    static func executeJavaScript(_ webView: BootpayWebView, _ scripts: [String]) {
        for script in scripts {
            
            print("executeJavaScript : \(script)")
            
            webView.evaluateJavaScript("(function() { \(script) })();") { result, error in
                if let error = error {
                    print("JavaScript evaluation error: \(error.localizedDescription)\nscript: \(script)")
                }
            }
        }
        
//        DispatchQueue.main.async {
//            for script in scripts {
////                print("executeJavaScript : \(script)")
//                webView.evaluateJavaScript("(function() { \(script) })();") { result, error in
//                    if let error = error {
//                        print("JavaScript evaluation error: \(error.localizedDescription)\nscript: \(script)")
//                    }
//                }
//            }
//        }
        
        
//        DispatchQueue.main.async {
//            for script in scripts {
//                webView.evaluateJavaScript(script) { result, error in
//                    if let error = error {
//                        print("JavaScript evaluation error: \(error.localizedDescription)\nscript: \(script)")
//                    } else {
//                        completion?()
//                    }
//                }
//            }
//        }
//        DispatchQueue.main.async {
//                let dispatchGroup = DispatchGroup()
//                
//                for script in scripts {
//                    dispatchGroup.enter()
//                    webView.evaluateJavaScript(script) { result, error in
//                        if let error = error {
//                            print("JavaScript evaluation error: \(error.localizedDescription)\nscript: \(script)")
//                        }
//                        dispatchGroup.leave()
//                    }
//                }
//                
//                dispatchGroup.notify(queue: .main) {
//                    completion?()
//                }
//            }
    }
}

private extension BootpayWebViewHandler {
    static func addPaymentEventListener(_ webView: BootpayWebView) {
        addEventListener(webView, eventNames: [
            BootpayEvent.defaultEvent.rawValue,
            BootpayEvent.done.rawValue,
            BootpayEvent.confirm.rawValue,
            BootpayEvent.error.rawValue,
            BootpayEvent.cancel.rawValue,
            BootpayEvent.issued.rawValue,
            BootpayEvent.close.rawValue
        ])
    }

    static func addWidgetEventListener(_ webView: BootpayWebView) {
        addEventListener(webView, eventNames: [
            BootpayWidgetEvent.ready.rawValue,
            BootpayWidgetEvent.resize.rawValue,
            BootpayWidgetEvent.changePayment.rawValue,
            BootpayWidgetEvent.changeTermsWatch.rawValue
        ])
    }

    static func addEventListener(_ webView: BootpayWebView, eventNames: [String]) {
        let contentController = webView.configuration.userContentController
        for eventName in eventNames {
            contentController.addUniqueScriptMessageHandler(webView, name: eventName)
        }
    }
}


//class BootpayWebViewHandler {
//    public static let shared = BootpayWebViewHandler()
//    
//    private var isWidget = false
//    private var requestType: RequestType = .payment
//    private var paymentStatus: PaymentStatus = .none
//    
//
//    public var bootpayView: BootpayView?
//    private var widgetController: BootpayWidgetController?
//    
//    
//    static public func didFinish() {
//        guard let webView = shared.bootpayView?.webView else { return }
//        shared.isWidget == true ? loadWidgetHtml(webView) : loadPaymentHtml(webView)
//    }
//    
//    
//    
//    static public func renderWidget() -> UIView? {
//        let bootpayWebView = BootpayWebView()
////        bootpayWebView.star
//        return bootpayWebView
//    }
//    
//    static public func updatePaymentState(_ state: PaymentStatus) {
//        shared.paymentStatus = state
//    }
//    
//    static public func requestWidgetPayment(_ payload: Payload, rootViewController: UIViewController? = nil) {
//        requestWidgetPaymentScript(payload)
//        showWidgetController(rootViewController)
//    }
//    
//    static public func showWidgetController(_ rootViewController: BTViewController? = nil) {
//        let viewController = BootpayWidgetController()
//        if rootViewController != nil {
//            rootViewController?.present(viewController, animated: true, completion: nil)
//            shared.widgetController = viewController
//        } else {
//            if var topController = UIApplication.shared.keyWindow?.rootViewController {
//                while let presentedViewController = topController.presentedViewController {
//                    topController = presentedViewController
//                }
//                topController.present(viewController, animated: true, completion: nil)
//                shared.widgetController = viewController
//            }
//        }
//    }
//    
//    static public func dismissController() {
//        shared.widgetController?.dismiss(animated: true)
//    }
//    
//    static func debounceClose() {
//        shared.isWidget == true ? debounceWidgetClose() : debouncePaymentClose()
//    }
//    
//    static public func widgetStatusReset() {
//        loadWidgetUrl()
//        if shared.paymentStatus == .none {
//            let params: [String: Any] = [
//                "code": -102,
//                "action": "BootpayCancel",
//                "message": "사용자가 창을 닫았습니다."
//            ]
//            BootpayWidget.shared.cancel?(params)
//        }
//        shared.paymentStatus = .none
//    }
//    
//    static public func didReceiveEvent(_ webView: BootpayWebView, _ message: WKScriptMessage) {
//        switch message.name {
//        case BootpayEvent.close.rawValue:
//            handleCloseEvent(message)
//            break
//        case BootpayEvent.done.rawValue:
//            handleDoneEvent(message)
//            break
//        case BootpayEvent.cancel.rawValue:
//            handleCancelEvent(message)
//            break
//        case BootpayEvent.error.rawValue:
//            handleErrorEvent(message)
//            break
//        case BootpayEvent.issued.rawValue:
//            handleIssuedEvent(message)
//            break
//        case BootpayEvent.confirm.rawValue:
//            handleConfirmEvent(message)
//            break
//        case BootpayWidgetEvent.ready.rawValue:
//            handleWidgetReadyEvent(message)
//            break
//        case BootpayWidgetEvent.resize.rawValue:
//            handleWidgetResizeEvent(message)
//            break
//        case BootpayWidgetEvent.changePayment.rawValue:
//            handleWidgetChangePaymentEvent(message)
//            break
//        case BootpayWidgetEvent.changeTermsWatch.rawValue:
//            handleWidgetChangeTermsEvent(message)
//            break
//        default:
//            handleDefaultEvent(message)
//            break
//        }
//    }
//}
//
//extension BootpayWebViewHandler {
//    static private func handleCloseEvent(_ message: WKScriptMessage) {
//        debouncePaymentClose()
//        Bootpay.removePaymentWindow()
//    }
//    
//    static private func handleDoneEvent(_ message: WKScriptMessage) {
//        BootpayWebViewHandler.updatePaymentState(.done)
//        shared.bootpayView?.showProgressBar(false)
//        guard let bodyString = message.body as? String, let data = convertStringToDictionary(text: bodyString) else { return }
//        let isRedirect = Bootpay.shared.payload?.extra?.openType == "redirect" ? true : false
//        Bootpay.shared.done?(data)
//        if Bootpay.shared.payload?.extra?.displaySuccessResult != true && isRedirect {
//            debouncePaymentClose()
//            Bootpay.removePaymentWindow()
//        } else {
//            guard let content = data["data"] as? [String: Any], let methodOriginSymbol = content["method_origin_symbol"] as? String else { return }
//            if methodOriginSymbol == "card_rebill_rest" {
//                debouncePaymentClose()
//                Bootpay.removePaymentWindow()
//            }
//        }
//        
//    }
//    
//    static private func handleCancelEvent(_ message: WKScriptMessage) {
//        BootpayWebViewHandler.updatePaymentState(.cancel)
//        guard let bodyString = message.body as? String, let data = convertStringToDictionary(text: bodyString) else { return }
//        let isRedirect = Bootpay.shared.payload?.extra?.openType == "redirect" ? true : false
//        Bootpay.shared.cancel?(data)
//        if isRedirect {
//            debouncePaymentClose()
//            Bootpay.removePaymentWindow()
//        }
//        
//    }
//    
//    static private func handleIssuedEvent(_ message: WKScriptMessage) {
//        BootpayWebViewHandler.updatePaymentState(.issued)
//        guard let bodyString = message.body as? String, let data = convertStringToDictionary(text: bodyString) else { return }
//        let isRedirect = Bootpay.shared.payload?.extra?.openType == "redirect" ? true : false
//        shared.bootpayView?.showProgressBar(false)
//        Bootpay.shared.issued?(data)
//        if Bootpay.shared.payload?.extra?.displaySuccessResult != true && isRedirect {
//            debouncePaymentClose()
//            Bootpay.removePaymentWindow()
//        }
//    }
//    
//    static private func handleErrorEvent(_ message: WKScriptMessage) {
//        BootpayWebViewHandler.updatePaymentState(.error)
//        guard let bodyString = message.body as? String, let data = convertStringToDictionary(text: bodyString) else { return }
//        let isRedirect = Bootpay.shared.payload?.extra?.openType == "redirect" ? true : false
//        shared.bootpayView?.showProgressBar(false)
//        Bootpay.shared.error?(data)
//        if Bootpay.shared.payload?.extra?.displayErrorResult != true && isRedirect {
//            debouncePaymentClose()
//            Bootpay.removePaymentWindow()
//        }
//    }
//    
//    static private func handleConfirmEvent(_ message: WKScriptMessage) {
//        shared.bootpayView?.showProgressBar(false)
//        guard let bodyString = message.body as? String, let data = convertStringToDictionary(text: bodyString) else { return }
//        if shared.isWidget == true {
//            if let confirm = BootpayWidget.shared.confirm, confirm(data) {
//                Bootpay.transactionConfirm()
//            }
//        } else {
//            if let confirm = Bootpay.shared.confirm, confirm(data) {
//                Bootpay.transactionConfirm()
//            }
//        }
//    }
//    
//    static private func handleWidgetReadyEvent(_ message: WKScriptMessage) {
//        BootpayWidget.shared.onWidgetReady?()
//    }
//    
//    static private func handleWidgetResizeEvent(_ message: WKScriptMessage) {
//        guard let body = message.body as? [String: Any] else { return }
//        guard let height = body["height"] as? CGFloat else {return}
//        if(shared.bootpayView?.webView?.updateHeight == height) { return }
//        shared.bootpayView?.webView?.updateHeight = height
//        BootpayWidget.shared.onWidgetResize?(height)
//    }
//    
//    static private func handleWidgetChangePaymentEvent(_ message: WKScriptMessage) {
//        guard let body = message.body as? [String: Any] else { return }
//        if let data = WidgetData(JSON: body) {
//            BootpayWidget.shared.onWidgetChangePayment?(data)
//        }
//    }
//    
//    static private func handleWidgetChangeTermsEvent(_ message: WKScriptMessage) {
//        guard let body = message.body as? [String: Any] else { return }
//        if let data = WidgetData(JSON: body) {
//            BootpayWidget.shared.onWidgetChangeAgreeTerm?(data)
//        }
//    }
//    
//    static private func handleDefaultEvent(_ message: WKScriptMessage) {
//        guard let bodyString = message.body as? String, let data = convertStringToDictionary(text: bodyString) else { return }
//        guard let event = data["event"] as? String else { return }
//        switch event {
//        case "bootpayWidgetFullSizeScreen":
//            showWidgetController()
//        case "bootpayWidgetRevertScreen":
//            dismissController()
//            BootpayWidget.shared.needReloadWidget?()
//            guard let payload = BootpayWidget.shared.payload else { return }
//            if let webView = shared.bootpayView?.webView {
//                loadWidgetScript(webView)
//            }
//        default:
//            break
//        }
//    }
//    
//    static private func convertStringToDictionary(text: String) -> [String: Any]? {
//        if let data = text.data(using: .utf8) {
//            do {
//                return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
//            } catch {
//                print("Something went wrong")
//            }
//        }
//        return nil
//    }
//}
//
//
//extension BootpayWebViewHandler {
//    static private func loadWidgetUrl() {
//        shared.isWidget = true
//        shared.bootpayView?.webView?.loadUrl(BootpayConstant.WIDGET_URL)
//        shared.bootpayView?.webView?.updateHeight = 400.0
//    }
//    
//    static private func loadPaymenttUrl() {
//        shared.isWidget = false
//        shared.bootpayView?.webView?.loadUrl(BootpayConstant.CDN_URL)
//        shared.bootpayView?.webView?.updateHeight = UIScreen.main.bounds.size.height
//    }
//    
//    
//    
//    static private func loadWidgetHtml(_ webView: BootpayWebView) {
//        guard let payload = Bootpay.shared.payload else { return }
//        addWidgetEventListener(webView)
//        
//        DispatchQueue.main.async {
//            BootpayScript.getJSBWidgetRenderefore().forEach {
//                webView.evaluateJavaScript($0, completionHandler: { (result, error) in
//                    loadWidgetScript(webView)
//                })
//            }
//        }
//    }
//    
//    static private func loadWidgetScript(_ webView: BootpayWebView) {
//        guard let payload = Bootpay.shared.payload else { return }
//        let scriptPay = BootpayScript.getWidgetRenderScript(payload: payload)
//        if !scriptPay.isEmpty {
//            DispatchQueue.main.async {
//                webView.evaluateJavaScript(scriptPay, completionHandler: nil)
//            }
//        }
//    }
//    
//    static private func loadPaymentHtml(_ webView: BootpayWebView) {
//        guard let payload = Bootpay.shared.payload else { return }
//        payload.user?.setEncodedValueAll()
//        BootpayScript.bindAppScheme(payload)
//        addPaymentEventListener(webView)
//        
//        DispatchQueue.main.async {
//            BootpayScript.getJSBeforePayStart().forEach {
//                webView.evaluateJavaScript($0, completionHandler: nil)
//            }
//            let scriptPay = BootpayScript.getPaymentScript(payload: payload, requestType: shared.requestType)
//            if !scriptPay.isEmpty { 
//                webView.evaluateJavaScript(scriptPay, completionHandler: nil)
//            }
//        }
//    }
//    
//    static private func debounceWidgetClose() {
//        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
//            BootpayWidget.shared.needReloadWidget?()
//            widgetStatusReset()
//        }
//    }
//    
//    static private func debouncePaymentClose() {
//        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) {
//            Bootpay.shared.close?()
////            Bootpay.shared.resetHandlers()
//        }
//    }
//     
//    
//    static private func requestWidgetPaymentScript(_ payload: Payload) {
//        guard let webView = shared.bootpayView?.webView else { return }
//        
//        let updateScript = BootpayScript.getWidgetUpdateScript(payload: payload)
//        let paymentScript = BootpayScript.getWidgetPaymentScript(payload: payload)
//        
////        print("updateScript: \(updateScript)")
////        print("paymentScript: \(paymentScript)")
//        
//        DispatchQueue.main.async {
//            webView.evaluateJavaScript(updateScript, completionHandler: { (result, error) in
//                if let error = error {
//                    print("JavaScript evaluation error: \(error.localizedDescription)\nscript: \(updateScript)")
//                } else {
//                    webView.evaluateJavaScript(paymentScript)
//                }
//            })
//        }
//    }
//}
//
//extension BootpayWebViewHandler {
//    
//    static private func addPaymentEventListener(_ webView: BootpayWebView) {
//        let contentController = webView.configuration.userContentController
//        let eventNames = [
//            BootpayEvent.done.rawValue,
//            BootpayEvent.confirm.rawValue,
//            BootpayEvent.error.rawValue,
//            BootpayEvent.cancel.rawValue,
//            BootpayEvent.issued.rawValue,
//            BootpayEvent.close.rawValue,
//        ]
//        
//        for eventName in eventNames {
//            contentController.addUniqueScriptMessageHandler(webView, name: eventName)
//        }
//    }
//    
//    static private func addWidgetEventListener(_ webView: BootpayWebView) {
//        let contentController = webView.configuration.userContentController
//        let eventNames = [
//            BootpayWidgetEvent.ready.rawValue,
//            BootpayWidgetEvent.resize.rawValue,
//            BootpayWidgetEvent.changePayment.rawValue,
//            BootpayWidgetEvent.changeTermsWatch.rawValue
//        ]
//        
//        for eventName in eventNames {
//            contentController.addUniqueScriptMessageHandler(webView, name: eventName)
//        }
//    }
//}
