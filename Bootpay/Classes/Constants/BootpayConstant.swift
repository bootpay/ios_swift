//
//  BootpayConstantV2.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2021/12/22.
//

import Foundation

public class BootpayConstant {
    
    public static let CDN_URL = "https://webview.bootpay.co.kr/5.0.0-rc.14"
    public static let WIDGET_URL = "\(CDN_URL)/widget.html"
    
//    public static let DEFAULT_BRIDGE_NAME = "Bootpay" //default event name
//    public static let BOOTPAY_DONE = "BootpayDone"
//    public static let BOOTPAY_CONFIRM = "BootpayConfirm"
//    public static let BOOTPAY_ISSUED = "BootpayIssued"
//    public static let BOOTPAY_CANCEL = "BootpayCancel"
//    public static let BOOTPAY_ERROR = "BootpayError"
//    public static let BOOTPAY_CLOSE = "BootpayClose"
    
//    public static let BOOTPAY_WIDGET_READY = "BootpayWidgetReady"
//    public static let BOOTPAY_WIDGET_RESIZE = "BootpayWidgetResize"
//    public static let BOOTPAY_WIDGET_CHANGE_PAYMENT = "BootpayWidgetChangePayment"
//    public static let BOOTPAY_WIDGET_CHANGE_TERMS_WATCH = "BootpayWidgetChangeTermsWatch"
    
//    public static let ENV_SWIFT = 0
//    public static let ENV_SWIFT_UI = 1
    
//    public static let REQUEST_TYPE_PAYMENT = 1
//    public static let REQUEST_TYPE_SUBSCRIPT = 2
//    public static let REQUEST_TYPE_AUTH = 3
//    public static let REQUEST_TYPE_PASSWORD = 4
    
//    static func dicToJsonString(_ data: [String: Any]) -> String {
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
//            return String(data: jsonData, encoding: .utf8) ?? ""
//        } catch {
//            print(error.localizedDescription)
//            return ""
//        }
//    }
//    
//    public static func getJSBeforePayStart() -> [String] {
//        var scripts = [String]()
//        #if os(iOS)
//        scripts.append("Bootpay.setDevice('IOS');")
//        scripts.append("Bootpay.setVersion('\(BootpayBuild.VERSION)', 'ios')")
//        scripts.append("BootpaySDK.setDevice('IOS');")
//        scripts.append("BootpaySDK.setUUID('\(Bootpay.getUUID())');")
//        #endif
//        scripts.append(getAnalyticsData())
//        if BootpayBuild.DEBUG {
//            scripts.append("Bootpay.setEnvironmentMode('development');")
//            scripts.append("BootpaySDK.setEnvironmentMode('development');")
//        }
//        scripts.append(addCloseEvent())
//        return scripts
//    }
//    
//    static func getAnalyticsData() -> String {
//        return """
//        window.Bootpay.setAnalyticsData({
//            sk: '\(Bootpay.getSk())',
//            sk_time: \(Bootpay.getSkTime()),
//            uuid: '\(Bootpay.getUUID())'
//        });
//        """
//    }
//    
//    private static func getURLSchema() -> String {
//        guard
//            let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
//            let schema = schemas.first,
//            let urlSchemas = schema["CFBundleURLSchemes"] as? [String],
//            let urlSchema = urlSchemas.first
//        else {
//            return ""
//        }
//        return urlSchema
//    }
//    
//    public static func getPaymentScript(payload: Payload, requestType: Int) -> String {
//        updatePayloadExtra(payload)
//        payload.user?.setEncodedValueAll()
//        
//        let requestMethod = getRequestMethod(for: requestType, with: payload)
//        
//        return """
//        Bootpay.\(requestMethod)(
//            \(getPayloadJson(payload))
//        ).then(function (res) {
//            \(confirm())
//            \(issued())
//            \(done())
//        }, function (res) {
//            \(error())
//            \(cancel())
//        })
//        """
//    }
//    
//    public static func getJSBWidgetRenderefore() -> [String] {
//        var scripts = [String]()
//        
//        if BootpayBuild.DEBUG {
//            scripts.append("BootpayWidget.setEnvironmentMode('development');")
//        }
//        
//        scripts.append(BootpayConstant.readyWatch())
//        scripts.append(BootpayConstant.resizeWatch())
//        scripts.append(BootpayConstant.changeMethodWatch())
//        scripts.append(BootpayConstant.changeTermsWatch())
//        scripts.append(BootpayConstant.addCloseEvent())
//         
//        return scripts
//        
//    }
//    
//    public static func getWidgetRenderScript(payload: Payload) -> String {
//        return """
//        BootpayWidget.render('#bootpay-widget',
//            \(getPayloadJson(payload))
//        )
//        """
//    }
//    
//    public static func getWidgetPaymentScript(payload: Payload) -> String {
//        return """
//        BootpayWidget.requestPayment(
//            \(getPayloadJson(payload))
//        ).then( function (res) {
//            \(confirm())
//            \(issued())
//            \(done())
//        }, function (res) {
//            \(error())
//            \(cancel())
//        })
//        """
//    }
//    
//    public static func getWidgetUpdateScript(payload: Payload) -> String {
//        var refresh = false 
//        return """
//        Bootpay.setDevice('IOS');
//        Bootpay.setVersion('\(BootpayBuild.VERSION)', 'ios');
//        BootpayWidget.update(
//            \(getPayloadJson(payload))
//        , '\(refresh)');
//        """
//    }
//    
//    public static func getPasswordPaymentScript(payload: Payload) -> String {
//        payload.method = "카드간편"
//        return """
//        Bootpay.requestPayment(
//            \(getPayloadJson(payload))
//        ).then(function (res) {
//            \(confirm())
//            \(issued())
//            \(done())
//            \(resultScreenClose())
//        }, function (res) {
//            \(error())
//            \(cancel())
//            \(resultScreenClose())
//        })
//        """
//    }
//    
//    static func confirm() -> String {
//        return "if (res.event === 'confirm') { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_CONFIRM).postMessage(res); }"
//    }
//    
//    static func done() -> String {
//        return "else if (res.event === 'done') { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_DONE).postMessage(res); }"
//    }
//    
//    static func issued() -> String {
//        return "else if (res.event === 'issued') { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_ISSUED).postMessage(res); }"
//    }
//    
//    static func resultScreenClose() -> String {
//        return "else if (res.event === 'close') { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_CLOSE).postMessage(res); }"
//    }
//    
//    static func error() -> String {
//        return "if (res.event === 'error') { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_ERROR).postMessage(res); }"
//    }
//    
//    static func cancel() -> String {
//        return "else if (res.event === 'cancel') { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_CANCEL).postMessage(res); }"
//    }
//    
//    static func addCloseEvent() -> String {
//        return "document.addEventListener('bootpayclose', function (e) { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_CLOSE).postMessage('close'); });"
//    }
//     
//    
//    static func readyWatch() -> String { return "document.addEventListener('bootpay-widget-ready', function (e) { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_WIDGET_READY).postMessage(e.detail); });" }
//    
//    static func resizeWatch() -> String { return "document.addEventListener('bootpay-widget-resize', function (e) { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_WIDGET_RESIZE).postMessage(e.detail); });" }
//    
//    static func changeMethodWatch() -> String { return "document.addEventListener('bootpay-widget-change-payment', function (e) { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_WIDGET_CHANGE_PAYMENT).postMessage(e.detail); });" }
//    
//    static func changeTermsWatch() -> String { return "document.addEventListener('bootpay-widget-change-terms', function (e) { webkit.messageHandlers.\(BootpayConstant.BOOTPAY_WIDGET_CHANGE_TERMS_WATCH).postMessage(e.detail); });" }
//    
//    
//    
//    static private func getPayloadJson(_ payload: Payload) -> String {
//        let encoder = JSONEncoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return String(data: try! encoder.encode(payload), encoding: .utf8)!
//    }
//    
//    
//    private static func updatePayloadExtra(_ payload: Payload) {
//        if let extra = payload.extra {
//            if extra.appScheme == nil {
//                extra.appScheme = getURLSchema()
//                payload.extra = extra
//            }
//        } else {
//            let extra = BootExtra()
//            extra.appScheme = getURLSchema()
//            payload.extra = extra
//        }
//    }
//    
//    private static func getRequestMethod(for requestType: Int, with payload: Payload) -> String {
//        switch requestType {
//        case REQUEST_TYPE_PAYMENT:
//            return "requestPayment"
//        case REQUEST_TYPE_SUBSCRIPT:
//            if payload.subscriptionId == nil { payload.subscriptionId = payload.orderId }
//            return "requestSubscription"
//        case REQUEST_TYPE_AUTH:
//            if payload.authenticationId == nil { payload.authenticationId = payload.orderId }
//            return "requestAuthentication"
//        case REQUEST_TYPE_PASSWORD:
//            return "requestPassword"
//        default:
//            return "requestPayment"
//        }
//    }
}
