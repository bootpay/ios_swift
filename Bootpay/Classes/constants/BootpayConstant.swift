//
//  BootpayConstantV2.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2021/12/22.
//



import Foundation

public class BootpayConstant {

    public static let CDN_URL = "https://webview.bootpay.co.kr/5.3.0";
    public static let BRIDGE_NAME = "Bootpay";

    // Commerce WebView URL
    public static let COMMERCE_URL = "https://webview.bootpay.co.kr/commerce/1.0.5/index.html";
    
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
        if(requestType == BootpayConstant.REQUEST_TYPE_SUBSCRIPT) {
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
            resultScreenClose(),
            "}, function (res) {",
            error(),
            cancel(),
            resultScreenClose(),
            "})"
        ].reduce("", +)
    }
    
    static func confirm() -> String {
        return "if (res.event === 'confirm') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func done() -> String {
        return "else if(res.event === 'done') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func issued() -> String {
        return "else if(res.event === 'issued') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    static func resultScreenClose() -> String {
        return "else if(res.event === 'close') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(res); }"
    }
    
    
    static func error() -> String {
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
        guard let data = try? encoder.encode(payload),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }

    // MARK: - Widget JavaScript Functions

    /// 위젯 CDN URL (HTTP 사용 - 위젯 전용)
    public static let WIDGET_URL = "https://webview.bootpay.co.kr/5.3.0/widget.html"

    /// 위젯 초기화 JavaScript (위젯 전용 - Flutter 방식 참조)
    public static func getJSWidgetBeforeStart() -> [String] {
        var array = [String]()
        // 환경 설정만 (setDevice, setVersion 등은 위젯에서 미지원)
        if BootpayBuildConfig.DEBUG {
            array.append("BootpayWidget.setEnvironmentMode('development');")
        }
        return array
    }

    /// 위젯 렌더링 JavaScript 생성
    public static func getJSWidgetRender(payload: Payload) -> String {
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

        var scripts = [String]()

        // 환경 설정
        if BootpayBuildConfig.DEBUG {
            scripts.append("BootpayWidget.setEnvironmentMode('development');")
        }

        // 이벤트 리스너 등록 (Flutter 방식과 동일)
        scripts.append(widgetReadyWatch())
        scripts.append(widgetResizeWatch())
        scripts.append(widgetChangePaymentWatch())
        scripts.append(widgetChangeTermsWatch())

        // 위젯 렌더링
        scripts.append("BootpayWidget.render('#bootpay-widget', \(getWidgetPayloadJson(payload)));")

        // close 이벤트 리스너
        scripts.append(widgetCloseWatch())

        return scripts.joined(separator: "")
    }

    /// 위젯 닫기 이벤트 감지
    static func widgetCloseWatch() -> String {
        return "document.addEventListener('bootpayclose', function (e) { webkit.messageHandlers.\(BRIDGE_NAME).postMessage('close'); });"
    }

    /// 위젯 업데이트 JavaScript 생성
    public static func getJSWidgetUpdate(payload: Payload, refresh: Bool) -> String {
        return "BootpayWidget.update(\(getWidgetPayloadJson(payload)), \(refresh ? "true" : "false"));"
    }

    /// 위젯 결제 요청 JavaScript 생성
    public static func getJSWidgetRequestPayment(payload: Payload) -> String {
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
        payload.user?.setEncodedValueAll()

        var scripts = [String]()

        // 디바이스 설정 (결제 요청 시 필수 - Platform Type 일치를 위해)
        #if os(iOS)
        scripts.append("Bootpay.setDevice('IOS');")
        scripts.append("Bootpay.setVersion('\(BootpayBuildConfig.VERSION)', 'ios');")
        scripts.append("BootpaySDK.setDevice('IOS');")
        scripts.append("BootpaySDK.setUUID('\(Bootpay.getUUID())');")
        #endif

        // 결제 요청 (JS SDK 방식과 동일하게 - render 시 설정된 값 외에 결제 요청에 필요한 정보만 전달)
        scripts.append("BootpayWidget.requestPayment(")
        scripts.append(getWidgetRequestPaymentJson(payload))
        scripts.append(")")
        scripts.append(".then( function (res) {")
        scripts.append("console.log('[BootpayWidget] requestPayment response:', res);")
        scripts.append(widgetConfirm())
        scripts.append(widgetIssued())
        scripts.append(widgetDone())
        scripts.append("}, function (res) {")
        scripts.append("console.log('[BootpayWidget] requestPayment error:', res);")
        scripts.append(widgetError())
        scripts.append(widgetCancel())
        scripts.append("})")

        return scripts.joined(separator: "")
    }

    // MARK: - Widget Event Watchers

    static func widgetReadyWatch() -> String {
        return "document.addEventListener('bootpay-widget-ready', function (e) { webkit.messageHandlers.\(BRIDGE_NAME).postMessage({event: 'widget_ready', data: e.detail}); });"
    }

    static func widgetResizeWatch() -> String {
        return "document.addEventListener('bootpay-widget-resize', function (e) { webkit.messageHandlers.\(BRIDGE_NAME).postMessage({event: 'widget_resize', height: e.detail.height}); });"
    }

    static func widgetChangePaymentWatch() -> String {
        return "document.addEventListener('bootpay-widget-change-payment', function (e) { webkit.messageHandlers.\(BRIDGE_NAME).postMessage({event: 'widget_change_payment', data: e.detail}); });"
    }

    static func widgetChangeTermsWatch() -> String {
        return "document.addEventListener('bootpay-widget-change-terms', function (e) { webkit.messageHandlers.\(BRIDGE_NAME).postMessage({event: 'widget_change_agree_term', data: e.detail}); });"
    }

    // MARK: - Widget Payment Event Handlers

    static func widgetConfirm() -> String {
        return "if (res.event === 'confirm') { webkit.messageHandlers.\(BRIDGE_NAME).postMessage(res); }"
    }

    static func widgetDone() -> String {
        return "else if(res.event === 'done') { webkit.messageHandlers.\(BRIDGE_NAME).postMessage(res); }"
    }

    static func widgetIssued() -> String {
        return "else if(res.event === 'issued') { webkit.messageHandlers.\(BRIDGE_NAME).postMessage(res); }"
    }

    static func widgetError() -> String {
        return "if(res.event === 'error') { webkit.messageHandlers.\(BRIDGE_NAME).postMessage(res); }"
    }

    static func widgetCancel() -> String {
        return "else if(res.event === 'cancel') { webkit.messageHandlers.\(BRIDGE_NAME).postMessage(res); }"
    }

    // MARK: - Widget Payload JSON

    /// 위젯 결제 요청용 JSON (requestPayment 전용 - JS SDK 방식)
    /// render에서 이미 설정된 값들(application_id, price, widget_key 등)은 제외하고
    /// 결제 요청에 필요한 정보만 전달
    static private func getWidgetRequestPaymentJson(_ payload: Payload) -> String {
        var dict: [String: Any] = [:]

        // 주문 정보
        if let orderName = payload.orderName { dict["order_name"] = orderName }
        if !payload.orderId.isEmpty { dict["order_id"] = payload.orderId }
        if let metadata = payload.metadata { dict["metadata"] = metadata }
        if let userToken = payload.userToken { dict["user_token"] = userToken }

        // Extra (결제 요청용)
        if let extra = payload.extra {
            var extraDict: [String: Any] = [:]
            if let appScheme = extra.appScheme { extraDict["app_scheme"] = appScheme }
            extraDict["show_close_button"] = extra.showCloseButton
            extraDict["display_success_result"] = extra.displaySuccessResult
            extraDict["display_error_result"] = extra.displayErrorResult
            if extra.separatelyConfirmed { extraDict["separately_confirmed"] = true }
            // redirect_url 필수 (위젯 결제 요청 시)
            extraDict["redirect_url"] = "https://api.bootpay.co.kr/v2/callback"
            dict["extra"] = extraDict
        } else {
            // extra가 없어도 redirect_url은 필수
            dict["extra"] = ["redirect_url": "https://api.bootpay.co.kr/v2/callback"]
        }

        // User
        if let user = payload.user {
            var userDict: [String: Any] = [:]
            if let id = user.id { userDict["id"] = id }
            if let userId = user.userId { userDict["user_id"] = userId }
            if let username = user.username { userDict["username"] = username }
            if let email = user.email { userDict["email"] = email }
            if user.gender > 0 { userDict["gender"] = user.gender }
            if let birth = user.birth { userDict["birth"] = birth }
            if let phone = user.phone { userDict["phone"] = phone }
            if let area = user.area { userDict["area"] = area }
            if let addr = user.addr { userDict["addr"] = addr }
            dict["user"] = userDict
        }

        // Items
        if let items = payload.items {
            dict["items"] = items.map { item -> [String: Any] in
                var itemDict: [String: Any] = [:]
                if let id = item.id { itemDict["id"] = id }
                if !item.name.isEmpty { itemDict["item_name"] = item.name }
                if item.qty > 0 { itemDict["qty"] = item.qty }
                if item.price > 0 { itemDict["price"] = item.price }
                if let cat1 = item.cat1 { itemDict["cat1"] = cat1 }
                if let cat2 = item.cat2 { itemDict["cat2"] = cat2 }
                if let cat3 = item.cat3 { itemDict["cat3"] = cat3 }
                return itemDict
            }
        }

        return dicToJsonString(dict)
    }

    static private func getWidgetPayloadJson(_ payload: Payload) -> String {
        var dict: [String: Any] = [:]

        if !payload.clientKey.isEmpty {
            dict["client_key"] = payload.clientKey
        } else {
            dict["application_id"] = payload.applicationId
        }

        if let pg = payload.pg { dict["pg"] = pg }
        if let method = payload.method { dict["method"] = method }
        if let methods = payload.methods, methods.count > 0 { dict["methods"] = methods }
        if let orderName = payload.orderName { dict["order_name"] = orderName }
        if payload.price > 0 { dict["price"] = payload.price }
        if payload.taxFree > 0 { dict["tax_free"] = payload.taxFree }
        if !payload.orderId.isEmpty { dict["order_id"] = payload.orderId }
        if !payload.subscriptionId.isEmpty { dict["subscription_id"] = payload.subscriptionId }
        if !payload.authenticationId.isEmpty { dict["authentication_id"] = payload.authenticationId }
        if let metadata = payload.metadata { dict["metadata"] = metadata }
        if let userToken = payload.userToken { dict["user_token"] = userToken }

        // Widget specific fields (JS SDK 방식과 동일하게)
        if let widgetKey = payload.widgetKey { dict["widget_key"] = widgetKey }
        dict["use_terms"] = payload.widgetUseTerms
        dict["sandbox"] = payload.widgetSandbox

        // Widget wallet_id if exists
        if let walletId = payload.widgetWalletId { dict["wallet_id"] = walletId }

        // Select terms if exists
        if let selectTerms = payload.widgetSelectTerms {
            dict["select_terms"] = selectTerms.map { $0.toJSON() }
        }

        // Extra (위젯용 - open_type, redirect_url 제외)
        if let extra = payload.extra {
            var extraDict: [String: Any] = [:]
            if let appScheme = extra.appScheme { extraDict["app_scheme"] = appScheme }
            // 위젯에서는 open_type, redirect_url 미사용
            extraDict["use_bootpay_inapp_sdk"] = true
            extraDict["show_close_button"] = extra.showCloseButton
            extraDict["display_success_result"] = extra.displaySuccessResult
            extraDict["display_error_result"] = extra.displayErrorResult
            dict["extra"] = extraDict
        }

        // User
        if let user = payload.user {
            var userDict: [String: Any] = [:]
            if let id = user.id { userDict["id"] = id }
            if let userId = user.userId { userDict["user_id"] = userId }
            if let username = user.username { userDict["username"] = username }
            if let email = user.email { userDict["email"] = email }
            if user.gender > 0 { userDict["gender"] = user.gender }
            if let birth = user.birth { userDict["birth"] = birth }
            if let phone = user.phone { userDict["phone"] = phone }
            if let area = user.area { userDict["area"] = area }
            if let addr = user.addr { userDict["addr"] = addr }
            dict["user"] = userDict
        }

        // Items
        if let items = payload.items {
            dict["items"] = items.map { item -> [String: Any] in
                var itemDict: [String: Any] = [:]
                if let id = item.id { itemDict["id"] = id }
                if !item.name.isEmpty { itemDict["item_name"] = item.name }
                if item.qty > 0 { itemDict["qty"] = item.qty }
                if item.price > 0 { itemDict["price"] = item.price }
                if let cat1 = item.cat1 { itemDict["cat1"] = cat1 }
                if let cat2 = item.cat2 { itemDict["cat2"] = cat2 }
                if let cat3 = item.cat3 { itemDict["cat3"] = cat3 }
                return itemDict
            }
        }

        return dicToJsonString(dict)
    }
}
