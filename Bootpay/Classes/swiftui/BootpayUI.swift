//
//  BootpayUI.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2021/11/12.
//
import SwiftUI


#if os(macOS)
public typealias BTViewRepresentable = NSViewRepresentable
#elseif os(iOS)
@available(iOS 13.0, *)
public typealias BTViewRepresentable = UIViewRepresentable
#endif

@available(iOS 13.0, *)
public struct BootpayUI: BTViewRepresentable {
    public var payload: Payload

    public init(payload: Payload, requestType: Int, userToken: String? = nil) {
        self.payload = payload
        Bootpay.shared.payload = payload

        if(requestType == BootpayConstant.REQUEST_TYPE_PAYMENT) {
            Bootpay.shared.requestType = BootpayConstant.REQUEST_TYPE_PAYMENT
        } else if(requestType == BootpayConstant.REQUEST_TYPE_SUBSCRIPT) {
            Bootpay.shared.requestType = BootpayConstant.REQUEST_TYPE_SUBSCRIPT
        } else if(requestType == BootpayConstant.REQUEST_TYPE_AUTH) {
            Bootpay.shared.requestType = BootpayConstant.REQUEST_TYPE_AUTH
        }  else if(requestType == BootpayConstant.REQUEST_TYPE_PASSWORD) {
            Bootpay.shared.requestType = BootpayConstant.REQUEST_TYPE_PASSWORD
        }

        if(userToken != nil) {
            Bootpay.shared.payload?.userToken = userToken
        }
    }



    #if os(macOS)
    public func makeNSView(context: Context) -> BootpayWebView {
        let webView = BootpayWebView()
        webView.startBootpay()
        Bootpay.shared.webview = webView.webview
       return webView
    }

    public func updateNSView(_ webView: BootpayWebView, context: Context) {
    }
    #elseif os(iOS)
    public func makeUIView(context: Context) -> BootpayWebView {
       let webView = BootpayWebView()
        webView.startBootpay()
        Bootpay.shared.webview = webView.webview
       return webView
    }


    public func updateUIView(_ view: BootpayWebView, context: Context) {
    }
    #endif

    func resizeWebview() {

    }

}

@available(iOS 13.0, *)
extension BootpayUI {

    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.error = action
        return self
    }

    public func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.issued = action
        return self
    }

    public func onClose(_ action: @escaping () -> Void) -> BootpayUI {
        Bootpay.shared.close = action
        return self
    }

    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayUI {
        Bootpay.shared.confirm = action
        return self
    }

    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.cancel = action
        return self
    }

    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.done = action
        return self
    }
}
