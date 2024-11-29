//
//  BootpayScript.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

import Foundation


public class BootpayScript {
    
    static func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            print("dicToJsonString : \(error.localizedDescription)")
            return ""
        }
    }
    
    static private func getURLSchema() -> String {
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
    
    static private func getPayloadJson(_ payload: Payload) -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
    
    public static func bindAppScheme(_ payload: Payload) {
        if payload.extra == nil { payload.extra = BootExtra() }
        if payload.extra?.appScheme == nil {
            payload.extra?.appScheme = getURLSchema()
        }
    }
}


//analytics 관련
extension BootpayScript {
    static func getAnalyticsData() -> String {
        return """
        window.Bootpay.$analytics.setAnalyticsData({
            sk: '\(Bootpay.getSk())',
            sk_time: \(Bootpay.getSkTime()),
            uuid: '\(Bootpay.getUUID())'
        });
        """
    }
}

//payment script 관련
extension BootpayScript {
    public static func getJSBeforePayStart() -> [String] {
        var scripts = [String]()
        #if os(iOS)
        scripts.append("Bootpay.setDevice('IOS');")
        scripts.append("Bootpay.setVersion('\(BootpayBuild.VERSION)', 'ios')")
        scripts.append("BootpaySDK.setDevice('IOS');")
        scripts.append("BootpaySDK.setUUID('\(Bootpay.getUUID())');")
        #endif
        scripts.append(getAnalyticsData())
        if BootpayBuild.DEBUG {
            scripts.append("Bootpay.setEnvironmentMode('development');")
            scripts.append("BootpaySDK.setEnvironmentMode('development');")
        }
        scripts.append(addCloseEvent())
        return scripts
    }
    
    public static func getTransactionConfirmScript() -> String {
        return """
            window.Bootpay.confirm()
            .then(function (res) {
                \(confirm())
                \(issued())
                \(done())
            }, function (res) {
                \(error())
                \(cancel())
            })
            """
    }
    
    
    public static func getPaymentScript(payload: Payload, requestType: RequestType) -> String {
        return """
        Bootpay.\(requestType.rawValue)(
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
}


//widget script 관련
extension BootpayScript {
    public static func getWidgetUpdateScript(payload: Payload) -> String {
        let refresh = false
        return """
        Bootpay.setDevice('IOS');
        Bootpay.setVersion('\(BootpayBuild.VERSION)', 'ios');
        BootpayWidget.update(
            \(getPayloadJson(payload))
        , '\(refresh)');
        """
    }
    
    public static func getJSBWidgetRenderefore() -> [String] {
        var scripts = [String]()
        
        if BootpayBuild.DEBUG {
            scripts.append("BootpayWidget.setEnvironmentMode('development');")
        }
        scripts.append(BootpayScript.readyWatch())
        scripts.append(BootpayScript.resizeWatch())
        scripts.append(BootpayScript.changeMethodWatch())
        scripts.append(BootpayScript.changeTermsWatch())
        scripts.append(BootpayScript.addCloseEvent())
         
        return scripts
    }
    
    public static func getWidgetRenderScript(payload: Payload) -> String {
        return """
        BootpayWidget.render('#bootpay-widget',
            \(getPayloadJson(payload))
        )
        """
    }
    
    public static func getWidgetPaymentScript(payload: Payload) -> String {
        return """
        BootpayWidget.requestPayment(
            \(getPayloadJson(payload))
        ).then( function (res) {
            \(confirm())
            \(issued())
            \(done())
        }, function (res) {
            \(error())
            \(cancel())
        })
        """
    }
    
    public static func getRemovePaymentWindowScript() -> String {
        return "window.BootPay.dismiss();"
    }
}


//payment event 관련
extension BootpayScript {
    static func confirm() -> String {
        return "if (res.event === 'confirm') { webkit.messageHandlers.\(BootpayEvent.confirm.rawValue).postMessage(res); }"
    }
    
    static func done() -> String {
        return "else if (res.event === 'done') { webkit.messageHandlers.\(BootpayEvent.done.rawValue).postMessage(res); }"
    }
    
    static func issued() -> String {
        return "else if (res.event === 'issued') { webkit.messageHandlers.\(BootpayEvent.issued.rawValue).postMessage(res); }"
    }
    
//    static func resultScreenClose() -> String {
//        return "else if (res.event === 'close') { webkit.messageHandlers.\(BootpayEvent.close.rawValue).postMessage(res); }"
//    }
    
    static func error() -> String {
        return "if (res.event === 'error') { webkit.messageHandlers.\(BootpayEvent.error.rawValue).postMessage(res); }"
    }
    
    static func cancel() -> String {
        return "else if (res.event === 'cancel') { webkit.messageHandlers.\(BootpayEvent.cancel.rawValue).postMessage(res); }"
    }
    
    static func addCloseEvent() -> String { 
        return "document.addEventListener('bootpayclose', function (e) { webkit.messageHandlers.\(BootpayEvent.close.rawValue).postMessage('close'); });"
    }
    
    static func removeCloseEvent() -> String {
        return """
          (function() {
            document.removeEventListener('bootpayclose', handleBootpayClose); 
          })();
          """
    }
}

//widget event 관련
extension BootpayScript {
    static func readyWatch() -> String { return "document.addEventListener('bootpay-widget-ready', function (e) { webkit.messageHandlers.\(BootpayWidgetEvent.ready.rawValue).postMessage(e.detail); });" }
    
    static func resizeWatch() -> String { return "document.addEventListener('bootpay-widget-resize', function (e) { webkit.messageHandlers.\(BootpayWidgetEvent.resize.rawValue).postMessage(e.detail); });" }
    
    static func changeMethodWatch() -> String { return "document.addEventListener('bootpay-widget-change-payment', function (e) { webkit.messageHandlers.\(BootpayWidgetEvent.changePayment.rawValue).postMessage(e.detail); });" }
    
    static func changeTermsWatch() -> String { return "document.addEventListener('bootpay-widget-change-terms', function (e) { webkit.messageHandlers.\(BootpayWidgetEvent.changeTermsWatch.rawValue).postMessage(e.detail); });" }
}
