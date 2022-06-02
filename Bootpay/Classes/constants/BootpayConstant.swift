//
//  BootpayConstantV2.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2021/12/22.
//



import Foundation

public class BootpayConstant {
    
    public static let CDN_URL = "https://webview.bootpay.co.kr/4.0.7";
    public static let BRIDGE_NAME = "Bootpay";
    
    public static let ENV_SWIFT = 0
    public static let ENV_SWIFT_UI = 1
    
    public static let REQUEST_TYPE_PAYMENT = 1 // 일반 결제
    public static let REQUEST_TYPE_SUBSCRIPT = 2 // 정기 결제
    public static let REQUEST_TYPE_AUTH = 3 // 본인인증
    public static let REQUEST_TYPE_PASSWORD = 4 // 비밀번호 결제
    
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
    
    
    public static func getJSBeforePayStart() -> [String] {
        var array = [String]()
        #if os(iOS)
        array.append("Bootpay.setDevice('IOS');")
        array.append("Bootpay.setVersion('\(BootpayBuildConfig.VERSION)', 'ios')")
        
        array.append("BootpaySDK.setDevice('IOS');")
        array.append("BootpaySDK.setUUID('\(Bootpay.getUUID())');")
        #endif
//        array.append("Bootpay.setLogLevel(4);")
        array.append(getAnalyticsData())
        if(BootpayBuildConfig.DEBUG) {
            array.append("Bootpay.setEnvironmentMode('development');")
            array.append("BootpaySDK.setEnvironmentMode('development');")
        }
        array.append(close())
        return array
    }
    
    static func getAnalyticsData() -> String {
        return "window.Bootpay.setAnalyticsData({"
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
    
    public static func getJSPay(payload: Payload, requestType: Int) -> String {
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
        payload.user?.setEncodedValueAll()
        
        var requestMethod = "requestPayment"
        if(requestType == BootpayConstant.REQUEST_TYPE_PAYMENT) {
            
        } else if(requestType == BootpayConstant.REQUEST_TYPE_SUBSCRIPT) {
            requestMethod = "requestSubscription"
            if(payload.subscriptionId.count == 0) { payload.subscriptionId = payload.orderId }
            
        } else if(requestType == BootpayConstant.REQUEST_TYPE_AUTH) {
            requestMethod = "requestAuthentication"
            if(payload.authenticationId.count == 0) { payload.authenticationId = payload.orderId }
        } else if(requestType == BootpayConstant.REQUEST_TYPE_PASSWORD) {
           return getJSPasswordPayment(payload: payload)
        }
        
        
        return [
            "Bootpay.\(requestMethod)(",
            getPayloadJson(payload),
            ")",
            ".then( function (res) {",
            confirm(),
            issued(),
            done(),
            "}, function (res) {",
            error(),
            cancel(),
            "})"
        ].reduce("", +)
    }
    
    
    public static func getJSPasswordPayment(payload: Payload) -> String {
        payload.method = "카드간편"
        
        return [
            "Bootpay.requestPayment(",
            getPayloadJson(payload),
            ")",
            ".then( function (res) {",
            confirm(),
            issued(),
            done(),
            "}, function (res) {",
            error(),
            cancel(),
            "})"
        ].reduce("", +)
    }
    
    static func confirm() -> String {
//        return ".confirm(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
        return "if (res.event === 'confirm') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func done() -> String {
        return "else if(res.event === 'done') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func issued() -> String {
        return "else if(res.event === 'issued') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    
    static func error() -> String {
//        return ".error(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
        return "if(res.event === 'error') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func cancel() -> String {
        return "else if(res.event === 'cancel') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    
    static func close() -> String {
        return  "document.addEventListener('bootpayclose', function (e) { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage('close'); });"
    }
     
        
    static private func getPayloadJson(_ payload: Payload) -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
}
