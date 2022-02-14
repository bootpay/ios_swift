//
//  BootpayConstants.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//


import Foundation

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

public class BootpayConstants {
    public static let CDN_URL = "https://inapp.bootpay.co.kr/3.3.3/production.html"; 
    public static let BRIDGE_NAME = "BootpayiOS"
    
    public static let ENV_SWIFT = 0
    public static let ENV_SWIFT_UI = 1
    
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
    
    
    public static func getJSBeforePayStart(_ quickPopup: Bool) -> [String] {
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
        + "uuid: '\(Bootpay.getUUID())'"
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
    
    public static func getJSPay(payload: Payload) -> String {
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
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
