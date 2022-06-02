//
//  NativeController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay


extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

class NativeController: UIViewController {    
    let _applicationId = "5b8f6a4d396fa665fdc2b5e9" //production
    let _restApplicationId = "5b8f6a4d396fa665fdc2b5ea" //production
    let _privateKey = "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=" //production
    
//    let _applicationId = "5b9f51264457636ab9a07cdd" //development
//    let _restApplicationId = "5b9f51264457636ab9a07cde" //development
//    let _privateKey = "sfilSOSVakw+PZA+PRux4Iuwm7a//9CXXudCq9TMDHk=" //development
     

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
#if os(macOS)
    
print("macos")
#elseif os(iOS)
    
print("ios")
#endif
        
        setUI()
        bootpayAnalyticsUserTrace()
        bootpayAnalyticsPageTrace()
    }
    
    func bootpayAnalyticsUserTrace() {
        //회원이 로그인 했을때 한번 호출하여, 통계를 쌓는다
        BootpayAnalytics.userTrace(id: "1234",
                                   email: "testUser@gmail.com",
                                   gender: 1,
                                   birth: "1994-10-14",
                                   phone: "01012341234",
                                   area: "서울",
                                   applicationId: _applicationId //ios application id
        )
    }
    
    func bootpayAnalyticsPageTrace() {
        //url이나 앱 화면 변경시 상품페이지 정보를 보내, 통계를 쌓는다
        let item1 = BootpayStatItem()
        item1.itemName = "나는 아이템1"
        item1.unique = "item_01"
        item1.price = 500
        item1.cat1 = "TOP"
        item1.cat2 = "티셔츠"
        item1.cat3 = "반팔티"
        
        let item2 = BootpayStatItem()
        item2.itemName = "나는 아이템1"
        item2.unique = "item_02"
        item2.price = 250
        item2.cat1 = "TOP"
        item2.cat2 = "데님"
        item2.cat3 = "청자켓"
        
        BootpayAnalytics.pageTrace(
            "main_page_1234", // 앱 페이지 url 또는 화면이름
            applicationId: _applicationId,
            items: [item1, item2]
        )
    }
    
    func setUI() {
        for i in 0...4 {
            self.view.backgroundColor = .white
            let btn = UIButton()
            
            if(i == 0) {
                btn.setTitle("1. PG일반 테스트", for: .normal)
                btn.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
            } else if(i == 1) {
                btn.setTitle("2. 통합결제 테스트", for: .normal)
                btn.addTarget(self, action: #selector(requestTotalPayment), for: .touchUpInside)
            } else if(i == 2) {
                btn.setTitle("3. 정기결제 테스트", for: .normal)
                btn.addTarget(self, action: #selector(requestSubscription), for: .touchUpInside)
            } else if(i == 3) {
                btn.setTitle("4. 본인인증 테스트", for: .normal)
                btn.addTarget(self, action: #selector(requestAuthentication), for: .touchUpInside)
            } else if(i == 4) {
                btn.setTitle("5. 비밀번호 결제 테스트", for: .normal)
                btn.addTarget(self, action: #selector(requestPassword), for: .touchUpInside)
            }
            
            
            btn.frame = CGRect(
                x: self.view.frame.width/2 - 150,
                y: self.view.frame.height/2 - 120 + 60 * CGFloat(i) ,
                width: 300,
                height: 40
            )
            btn.setTitleColor(.darkGray, for: .normal)
            self.view.addSubview(btn)
        }
    }
    
    func generatePayload() -> Payload {
        let payload = Payload()
        payload.applicationId = _applicationId //ios application id
         
        payload.price = 1000
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.pg = "다날"
        payload.method = "계좌이체"
        payload.orderName = "테스트 아이템"
        payload.extra = BootExtra()
        
         
        payload.extra?.cardQuota = "3"
//        payload.extra?.appScheme = "bootpayFlutter"
//        payload.extra?.carrier = "SKT" //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
//        payload.extra?.ageLimit = 40 // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능
        
        
        //통계를 위한 상품데이터
        let item1 = BootItem()
        item1.name = "나는 아이템1"
        item1.qty = 1
        item1.id = "item_01"
        item1.price = 500
        item1.cat1 = "TOP"
        item1.cat2 = "티셔츠"
        item1.cat3 = "반팔티"
        
        let item2 = BootItem()
        item2.name = "나는 아이템1"
        item2.qty = 2
        item2.id = "item_02"
        item2.price = 250
        item2.cat1 = "TOP"
        item2.cat2 = "데님"
        item2.cat3 = "청자켓"
        payload.items = [item1, item2]
        
        
        let customParams: [String: String] = [
            "callbackParam1": "value12",
            "callbackParam2": "value34",
            "callbackParam3": "value56",
            "callbackParam4": "value78",
        ]
         
        payload.metadata = customParams
//        payload.metadata = dicToJson(customParams).replace(target: "'", withString: "\\'").replace(target: "'\n", withString: "")
        
 
        payload.user = generateUser()
        return payload
    }
    
    
    
    func dicToJson(_ data: [String: Any]) -> String {
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
    
    @objc func requestPayment() {
        let payload = generatePayload()
                
        Bootpay.requestPayment(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onIssued { data in
                print("-- issued: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                Bootpay.transactionConfirm()
//                return false //재고가 없어서 결제를 승인하지 않을때
            }
            .onDone { data in
                print("-- done: \(data)")
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("-- close")
            }
    }
    
    @objc func requestTotalPayment() {
        let payload = generatePayload()
        payload.pg = ""
        payload.method = ""
                
        Bootpay.requestPayment(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onIssued { data in
                print("-- issued: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                Bootpay.transactionConfirm()
//                return false //재고가 없어서 결제를 승인하지 않을때
            }
            .onDone { data in
                print("-- done: \(data)")
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("-- close")
            }
        
    }
    
    
    @objc func requestSubscription() {
        let payload = generatePayload()
        payload.pg = "나이스페이"
        payload.method = "카드자동"
                
        Bootpay.requestSubscription(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onIssued { data in
                print("-- ready: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return false //재고가 없어서 결제를 승인하지 않을때
            }
            .onDone { data in
                print("-- done: \(data)")
                //이후 서버사이드에서 빌링키 결제데이터 가져오기를 수행해야 한다. (subscribe_billing_key)
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("-- close")
            }
    }
    
    
    @objc func requestAuthentication() {
        let payload = generatePayload()
        payload.pg = "다날"
        payload.method = "본인인증"
        
                
        Bootpay.requestAuthentication(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onIssued { data in
                print("-- ready: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return false //재고가 없어서 결제를 승인하지 않을때
            }
            .onDone { data in
                print("-- done: \(data)")
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("close")
            }
    }
    
    @objc func requestPassword() {
        getUserToken()
    }
    
    func goPasswordPay(userToken: String) {
        let payload = generatePayload()
        payload.pg = "나이스페이"
        payload.userToken = userToken
//        payload.method = "본인인증"
        
                
        Bootpay.requestPassword(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onIssued { data in
                print("-- ready: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return false //재고가 없어서 결제를 승인하지 않을때
            }
            .onDone { data in
                print("-- done: \(data)")
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("close")
            }
    }
     
    
    
    func generateUser() -> BootUser {
        
        let user = BootUser()
        user.id = "123456abcdffffe23456789012345613245167891223111"
        user.userId = "123456abcdffffe23456789012345613245167891223111"
        user.area = "서울"
        user.gender = 1
        user.email = "test1234@gmail.com"
        user.phone = "01012344567"
        user.birth = "1988-06-10"
        user.username = "홍길동"
        return user
    }
    
    func getUserToken() {
      
        
        BootpayRest.getRestToken(
            sendable: self,
            restApplicationId: _restApplicationId,
            privateKey: _privateKey
        )
    }
    
    
    
    

}


extension NativeController: BootpayRestProtocol {
   func callbackRestToken(resData: [String : Any]) {
       if let token = resData["access_token"] {
           BootpayRest.getEasyPayUserToken(
               sendable: self,
               restToken: token as! String,
               user: generateUser()
           )
       }
   }
   
   func callbackEasyCardUserToken(resData: [String : Any]) {
       if let userToken = resData["user_token"] as? String {
           self.goPasswordPay(userToken: userToken)
       }
   }
}
