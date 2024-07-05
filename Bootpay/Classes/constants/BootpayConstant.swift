//
//  BootpayConstantV2.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2021/12/22.
//

import Foundation

public class BootpayConstant {
    
    public static let CDN_URL = "https://webview.bootpay.co.kr/5.0.0-rc.13"
    public static let BRIDGE_NAME = "Bootpay"
    
    public static let ENV_SWIFT = 0
    public static let ENV_SWIFT_UI = 1
    
    public static let REQUEST_TYPE_PAYMENT = 1
    public static let REQUEST_TYPE_SUBSCRIPT = 2
    public static let REQUEST_TYPE_AUTH = 3
    public static let REQUEST_TYPE_PASSWORD = 4
    
    static func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    public static func getJSBeforePayStart() -> [String] {
        var scripts = [String]()
        #if os(iOS)
        scripts.append("Bootpay.setDevice('IOS');")
        scripts.append("Bootpay.setVersion('\(BootpayBuildConfig.VERSION)', 'ios')")
        scripts.append("BootpaySDK.setDevice('IOS');")
        scripts.append("BootpaySDK.setUUID('\(Bootpay.getUUID())');")
        #endif
        scripts.append(getAnalyticsData())
        if BootpayBuildConfig.DEBUG {
            scripts.append("Bootpay.setEnvironmentMode('development');")
            scripts.append("BootpaySDK.setEnvironmentMode('development');")
        }
        scripts.append(closeEventListener())
        return scripts
    }
    
    static func getAnalyticsData() -> String {
        return """
        window.Bootpay.setAnalyticsData({
            sk: '\(Bootpay.getSk())',
            sk_time: \(Bootpay.getSkTime()),
            uuid: '\(Bootpay.getUUID())'
        });
        """
    }
    
    private static func getURLSchema() -> String {
        guard
            let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
            let schema = schemas.first,
            let urlSchemas = schema["CFBundleURLSchemes"] as? [String],
            let urlSchema = urlSchemas.first
        else {
            return ""
        }
        return urlSchema
    }
    
    public static func getPaymentScript(payload: Payload, requestType: Int) -> String {
        updatePayloadExtra(payload)
        payload.user?.setEncodedValueAll()
        
        let requestMethod = getRequestMethod(for: requestType, with: payload)
        
        return """
        Bootpay.\(requestMethod)(
            \(getPayloadJson(payload))
        ).then(function (res) {
            \(confirm())
            \(issued())
            \(done())
        }, function (res) {
            \(error())
            \(cancel())
        })
        """
    }
    
    public static func getPasswordPaymentScript(payload: Payload) -> String {
        payload.method = "카드간편"
        return """
        Bootpay.requestPayment(
            \(getPayloadJson(payload))
        ).then(function (res) {
            \(confirm())
            \(issued())
            \(done())
            \(resultScreenClose())
        }, function (res) {
            \(error())
            \(cancel())
            \(resultScreenClose())
        })
        """
    }
    
    static func confirm() -> String {
        return "if (res.event === 'confirm') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func done() -> String {
        return "else if (res.event === 'done') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func issued() -> String {
        return "else if (res.event === 'issued') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func resultScreenClose() -> String {
        return "else if (res.event === 'close') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func error() -> String {
        return "if (res.event === 'error') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func cancel() -> String {
        return "else if (res.event === 'cancel') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func closeEventListener() -> String {
        return "document.addEventListener('bootpayclose', function (e) { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage('close'); });"
    }
    
    static private func getPayloadJson(_ payload: Payload) -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
    
    private static func updatePayloadExtra(_ payload: Payload) {
        if let extra = payload.extra {
            if extra.appScheme == nil {
                extra.appScheme = getURLSchema()
                payload.extra = extra
            }
        } else {
            let extra = BootExtra()
            extra.appScheme = getURLSchema()
            payload.extra = extra
        }
    }
    
    private static func getRequestMethod(for requestType: Int, with payload: Payload) -> String {
        switch requestType {
        case REQUEST_TYPE_PAYMENT:
            return "requestPayment"
        case REQUEST_TYPE_SUBSCRIPT:
            if payload.subscriptionId.isEmpty { payload.subscriptionId = payload.orderId }
            return "requestSubscription"
        case REQUEST_TYPE_AUTH:
            if payload.authenticationId.isEmpty { payload.authenticationId = payload.orderId }
            return "requestAuthentication"
        case REQUEST_TYPE_PASSWORD:
            return "requestPassword"
        default:
            return "requestPayment"
        }
    }
}
