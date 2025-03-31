# Bootpay

[![CI Status](https://img.shields.io/travis/bootpay/Bootpay.svg?style=flat)](https://travis-ci.org/bootpay/Bootpay)
[![Version](https://img.shields.io/cocoapods/v/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)
[![License](https://img.shields.io/cocoapods/l/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)
[![Platform](https://img.shields.io/cocoapods/p/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)

# Bootpay iOS

자세한 내용은 [부트페이 개발연동 문서](https://app.gitbook.com/@bootpay/s/docs/client/pg/android)를 참고해주세요.

Native 방식으로 iOS 앱을 만들때 이 페이지를 참조하시면 됩니다. 

PG 결제창은 기본적으로 Javascript로 연동됩니다. 부트페이 iOS SDK는 내부적으로 Webview 방식으로 구현하였으며, 사용방법은 아래와 같습니다. 


iOS 10 버전부터는 보안정책으로 **LSApplicationQueriesSchemes** 을 통하여 사용하고자 하는 URL scheme들을 등록하길 권장합니다.  하지만 부트페이에서는 각 은행사들의 scheme를 변경/추가/삭제에 대응하기 어렵다고 판단하여,  custom URL scheme 요청시 WKWebView에서 앱투앱 처리를 합니다. 코드가 궁금하신 분들인[ 이 곳](https://github.com/bootpay/SwiftyBootpay/blob/master/SwiftyBootpay/Classes/BootpayWebView.swift)을 참고하세요


### Cocoapod을 통한 설치 

```java
pod 'Bootpay'
```

### info.plist

```markup
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    ...

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>kr.co.bootpaySample</string> // 사용하고자 하시는 앱의 bundle url name
            <key>CFBundleURLSchemes</key>
            <array>
                <string>bootpaySample</string> // 사용하고자 하시는 앱의 bundle url scheme
            </array>
        </dict>
    </array>

    ...
    <key>NSFaceIDUsageDescription</key>
    <string>생체인증 결제 진행시 권한이 필요합니다</string>
</dict>
</plist>
```

**카드사 앱 실행 후 개발중인 원래 앱으로 돌아오지 않는 경우**

상단의 프로젝트 설정의 info.plist에서 CFBundleURLSchemes를 설정해주시면 부트페이 SDK가 해당 값을 읽어 extra.appScheme 에 값을 채워 결제데이터를 전송합니다.       


## 결제창 띄우는 iOS 코드


```swift

import UIKit
import Bootpay

class NativeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        let btn = UIButton()
        btn.setTitle("결제하기", for: .normal)
        btn.addTarget(self, action: #selector(showBootpay), for: .touchUpInside)
        btn.frame = CGRect(
            x: self.view.frame.width/2 - 40,
            y: self.view.frame.height/2 - 40,
            width: 80,
            height: 80
        )
        btn.setTitleColor(.darkGray, for: .normal)
        self.view.addSubview(btn)
    }
    
    @objc func showBootpay() {
        let payload = Payload()
        payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
                
        payload.price = 1000
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.pg = "payletter"
        payload.method = "card"
        payload.name = "테스트 아이템"
        payload.extra = BootExtra()
        payload.extra?.popup = 0
        payload.extra?.quickPopup = 0
        

        let user = BootUser()
        user.username = "테스트 유저"
        user.phone = "01012345678"
        payload.userInfo = user
                
        Bootpay.requestPayment(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onReady { data in
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
                print("-- close")
            }
    }
}
``` 
 
 결제 진행 상태에 따라 LifeCycle 함수가 실행됩니다. 각 함수에 대한 상세 설명은 아래를 참고하세요.


```swift
//MARK: Bootpay Callback Protocol
extension ViewController: BootpayRequestProtocol {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print(data)
    }

    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
        print("ready")
        print(data)
    }

    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print(data)

        var iWantPay = true
        if iWantPay == true {  // 재고가 있을 경우.
            Bootpay.transactionConfirm(data: data) // 결제 승인
        } else { // 재고가 없어 중간에 결제창을 닫고 싶을 경우
            Bootpay.dismiss() // 결제창 종료
        }
    }

    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
        print(data)
    }

    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
        print(data)
    }

    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("close")
        Bootpay.dismiss() // 결제창 종료
    }
}
```

### onError 함수

결제 진행 중 오류가 발생된 경우 호출되는 함수입니다. 진행중 에러가 발생되는 경우는 다음과 같습니다.

1. **부트페이 관리자에서 활성화 하지 않은 PG, 결제수단을 사용하고자 할 때**
2. **PG에서 보내온 결제 정보를 부트페이 관리자에 잘못 입력하거나 입력하지 않은 경우**
3. **결제 진행 도중 한도초과, 카드정지, 휴대폰소액결제 막힘, 계좌이체 불가 등의 사유로 결제가 안되는 경우**
4. **PG에서 리턴된 값이 다른 Client에 의해 변조된 경우**

에러가 난 경우 해당 함수를 통해 관련 에러 메세지를 사용자에게 보여줄 수 있습니다.

 data 포맷은 아래와 같습니다.

```text
{
  action: "BootpayError",
  message: "카드사 거절",
  receipt_id: "5fffab350c20b903e88a2cff"
}
```

### onCancel 함수
결제 진행 중 사용자가 PG 결제창에서 취소 혹은 닫기 버튼을 눌러 나온 경우 입니다. ****

 data 포맷은 아래와 같습니다.

```text
{
  action: "BootpayCancel",
  message: "사용자가 결제를 취소하였습니다.",
  receipt_id: "5fffab350c20b903e88a2cff"
}
```

### onReady 함수

가상계좌 발급이 완료되면 호출되는 함수입니다. 가상계좌는 다른 결제와 다르게 입금할 계좌 번호 발급 이후 입금 후에 Feedback URL을 통해 통지가 됩니다. 발급된 가상계좌 정보를 ready 함수를 통해 확인하실 수 있습니다.

  data 포맷은 아래와 같습니다.

```text
{
  account: "T0309260001169"
  accounthodler: "한국사이버결제"
  action: "BootpayBankReady"
  bankcode: "BK03"
  bankname: "기업은행"
  expiredate: "2021-01-17 00:00:00"
  item_name: "테스트 아이템"
  method: "vbank"
  method_name: "가상계좌"
  order_id: "1610591554856"
  params: null
  payment_group: "vbank"
  payment_group_name: "가상계좌"
  payment_name: "가상계좌"
  pg: "kcp"
  pg_name: "KCP"
  price: 3000
  purchased_at: null
  ready_url: "https://dev-app.bootpay.co.kr/bank/7o044QyX7p"
  receipt_id: "5fffad430c20b903e88a2d17"
  requested_at: "2021-01-14 11:32:35"
  status: 2
  tax_free: 0
  url: "https://d-cdn.bootapi.com"
  username: "홍길동"
}
```

### onConfirm 함수

결제 승인이 되기 전 호출되는 함수입니다. 승인 이전 관련 로직을 서버 혹은 클라이언트에서 수행 후 결제를 승인해도 될 경우 

`BootPay.transactionConfirm(data); 또는 return true;`

코드를 실행해주시면 PG에서 결제 승인이 진행이 됩니다.

**\* 페이앱, 페이레터 PG는 이 함수가 실행되지 않고 바로 결제가 승인되는 PG 입니다. 참고해주시기 바랍니다.**

 data 포맷은 아래와 같습니다.

```text
{
  receipt_id: "5fffc0460c20b903e88a2d2c",
  action: "BootpayConfirm"
}
```
{% endtab %}

{% tab title="onDone 함수" %}
PG에서 거래 승인 이후에 호출 되는 함수입니다. 결제 완료 후 다음 결제 결과를 호출 할 수 있는 함수 입니다.

이 함수가 호출 된 후 반드시 REST API를 통해 [결제검증](https://docs.bootpay.co.kr/rest/verify)을 수행해야합니다. data 포맷은 아래와 같습니다.

```text
{
  action: "BootpayDone"
  card_code: "CCKM",
  card_name: "KB국민카드",
  card_no: "0000120000000014",
  card_quota: "00",
  item_name: "테스트 아이템",
  method: "card",
  method_name: "카드결제",
  order_id: "1610596422328",
  payment_group: "card",
  payment_group_name: "신용카드",
  payment_name: "카드결제",
  pg: "kcp",
  pg_name: "KCP",
  price: 100,
  purchased_at: "2021-01-14 12:54:53",
  receipt_id: "5fffc0460c20b903e88a2d2c",
  receipt_url: "https://app.bootpay.co.kr/bill/UFMvZzJqSWNDNU9ERWh1YmUycU9hdnBkV29DVlJqdzUxRzZyNXRXbkNVZW81%0AQT09LS1XYlNJN1VoMDI4Q1hRdDh1LS10MEtZVmE4c1dyWHNHTXpZTVVLUk1R%0APT0%3D%0A",
  requested_at: "2021-01-14 12:53:42",
  status: 1,
  tax_free: 0,
  url: "https://d-cdn.bootapi.com"
}
```  



# 기타 문의사항이 있으시다면

1. [부트페이 개발연동 문서](https://app.gitbook.com/@bootpay/s/docs/client/pg/android) 참고
2. [부트페이 홈페이지](https://www.bootpay.co.kr) 참고 - 사이트 우측 하단에 채팅으로 기술문의 주시면 됩니다.
