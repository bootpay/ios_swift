//
//  BootpayConstants.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

struct BootpayConstants {
    static let CDN_URL = "https://inapp.bootpay.co.kr/3.3.2/production.html";
//    static let CDN_URL = "https://www.google.com"
    static let BRIDGE_NAME = "BootpayiOS"
    
    static func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonStr = String(data: jsonData, encoding: .utf8)
            if let jsonStr = jsonStr {
                return jsonStr
            }
            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    
    static func getJSBeforePayStart(_ quickPopup: Bool) -> [String] {
        var array = [String]()
        #if os(iOS)
        array.append("BootPay.setDevice('IOS');")
        #endif
        array.append(getAnalyticsData())
        if(BootpayBuildConfig.DEBUG) { array.append("BootPay.setMode('development');") }
        if(quickPopup) { array.append("BootPay.startQuickPopup();") }
        return array
    }
    
    static func getAnalyticsData() -> String {
        return "window.BootPay.setAnalyticsData({"
            + "sk: '\(Bootpay.getSk())', "
            + "sk_time: \(Bootpay.getSkTime()), "
            + "uuid: '\(Bootpay.getUUId())'"
            + "});"
    }
        
    private static func getURLSchema() -> String{
        guard let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String:Any]],
            let schema = schemas.first,
            let urlschemas = schema["CFBundleURLSchemes"] as? [String],
            let urlschema = urlschemas.first
            else {
                return ""
        }
        return urlschema
    }
    
    static func getJSPay(payload: Payload) -> String {
        if let extra = payload.extra {
            if extra.appScheme != nil {
                //가맹점이 설정한 appScheme 값을 그대로 둔다
            } else {
                extra.appScheme = getURLSchema()
                payload.extra = extra
            }
        } else {
            let extra = BootExtra()
            extra.appScheme = getURLSchema()
            payload.extra = extra
        }
        payload.userInfo?.setEncodedValueAll()
        return [
            "BootPay.request(",
            getPayloadJson(payload),
            ")",
            error(),
            confirm(),
            ready(),
            cancel(),
            done(),
            close()
        ].reduce("", +)
    }
    
    static func error() -> String {
        return ".error(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func confirm() -> String {
        return ".confirm(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func ready() -> String {
        return ".ready(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func cancel() -> String {
        return ".cancel(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func done() -> String {
        return ".done(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func close() -> String {
        return ".close(function () {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage('close');})"
    }
        
    static private func getPayloadJson(_ payload: Payload) -> String {
        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
}
