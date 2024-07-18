# Bootpay

[![CI Status](https://img.shields.io/travis/bootpay/Bootpay.svg?style=flat)](https://travis-ci.org/bootpay/Bootpay)
[![Version](https://img.shields.io/cocoapods/v/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)
[![License](https://img.shields.io/cocoapods/l/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)
[![Platform](https://img.shields.io/cocoapods/p/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)

# Bootpay iOS

부트페이에서 지원하는 공식 iOS 라이브러리 입니다
* iOS OS 13 부터 사용 가능합니다.

## 기능
1. 국내 주요 PG사 지원 
2. 주요 결제수단 지원 
3. 카드/계좌 자동결제 지원 
4. 위젯 지원  
5. 본인인증 지원 
 

### Cocoapod을 통한 설치 
```java
pod 'Bootpay'
```

### info.plist
``CFBundleURLName``과 ``CFBundleURLSchemes``의 값은 개발사에서 고유값으로 지정해주셔야 합니다. 외부앱(카드사앱)에서 다시 기존 앱으로 돌아올 때 필요한 스키마 값입니다. 
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
</dict>
</plist>
```

**카드사 앱 실행 후 개발중인 원래 앱으로 돌아오지 않는 경우**
상단의 프로젝트 설정의 info.plist에서 CFBundleURLSchemes를 설정해주시면 부트페이 SDK가 해당 값을 읽어 extra.appScheme 에 값을 채워 결제데이터를 전송합니다.       


## 위젯 설정 
[부트페이 관리자](https://developers.bootpay.co.kr/pg/guides/widget)에서 위젯을 생성하셔야만 사용이 가능합니다. 


## 위젯 렌더링 
```swift
private let widgetContainerView = UIView() //위젯을 담을 상위 뷰 
var widgetView: UIView? //부트페이가 생성하는 위젯 뷰 

override func viewDidLoad() {
    // WidgetView 설정
    widgetView = BootpayWidget.render(
        payload: payload,
        onWidgetResize: { height in
            //위젯 사이즈 변경 이벤트 
            print("onWidgetResize: \(height)")
        },
        onWidgetReady: {
            //위젯이 렌더링되면 호출되는 이벤트
            print("onWidgetReady")
        },
        onWidgetChangePayment: { widgetData in
            //선택된 결제수단 변경 이벤트 
            print("onWidgetChangePayment: \(widgetData.toJSON())")
            self.payload.mergeWidgetData(data: widgetData) //widgetData 정보를 payload에 반영합니다. 반영된 payload는 추후 결제요청시 사용됩니다.
            self.updatePaymentButtonState()
        },
        onWidgetChangeAgreeTerm: { widgetData in
            //선택된 약관 변경 이벤트
            print("onWidgetChangeAgreeTerm: \(widgetData.toJSON())")
            self.payload.mergeWidgetData(data: widgetData) //widgetData 정보를 payload에 반영합니다. 반영된 payload는 추후 결제요청시 사용됩니다.
            self.updatePaymentButtonState()
        },
        needReloadWidget: {
            //위젯 뷰 새로고침이 필요할 때 호출되는 이벤트 
            if self.widgetView != nil {
                self.widgetContainerView.subviews.forEach { $0.removeFromSuperview() }
                self.widgetContainerView.addSubview(self.widgetView!)
                self.setupWidgetContainerConstraints()
            }
        }
    )

    //위젯을 상위 뷰에 추가한다 
    if let widgetView = widgetView {
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        widgetContainerView.addSubview(widgetView) 
    }
}

func updatePaymentButtonState() {
    button.backgroundColor = payload.getWidgetIsCompleted() == true ? .systemBlue : .darkGray
}

func setupWidgetContainerConstraints() {
    guard let widgetView = widgetView else { return }
    NSLayoutConstraint.activate([
        widgetView.topAnchor.constraint(equalTo: widgetContainerView.topAnchor),
        widgetView.leadingAnchor.constraint(equalTo: widgetContainerView.leadingAnchor),
        widgetView.trailingAnchor.constraint(equalTo: widgetContainerView.trailingAnchor),
        widgetView.bottomAnchor.constraint(equalTo: widgetContainerView.bottomAnchor)
    ])
}
```

## 위젯으로 결제 요청하기
이 방법은 위젯을 사용하여 결제하는 방법입니다. 위젯을 사용하지 않고 결제를 요청하는 방법은 별도로 제공합니다. 
```swift
@objc func requestPayment() {
    BootpayWidget.requestPayment(
        payload: self.payload
    ).onCancel { data in
        print("-- cancel: \(data)")
    }
    .onIssued { data in
        print("-- issued: \(data)")
    }
    .onConfirm { data in
        print("-- confirm: \(data)")
        return true // 결제 승인요청 
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
```




## 결제 요청하기 
이 방법은 위젯을 사용하지 않고 결제를 요청하는 방법입니다.
```swift
@objc func requestPayment() {
    let payload = generatePayload() 
            
    if #available(iOS 13.0, *) {
        Bootpay.requestPayment(
            payload: payload,
            rootController: self
        )
        .onCancel { data in
            print("-- cancel: \(data)")
        }
        .onIssued { data in
            print("-- issued: \(data)")
        }
        .onConfirm { data in
            print("-- confirm: \(data)")
            
            if(self.checkClientValidation(data: data)) {
//                    Bootpay.confirm() // 승인 요청(방법 1), 이때는 return false 를 해야함
                return true //승인 요청(방법 2), return true시 내부적으로 승인을 요청함
            } else {
                Bootpay.dismiss()
                return false
            }
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

func generatePayload() -> Payload {
    let payload = Payload()
    payload.applicationId = _applicationId //ios application id
        
    payload.price = 1000
    payload.orderId = String(NSTimeIntervalSince1970)
    payload.pg = "나이스페이"
    payload.method = "네이버페이"
    payload.orderName = "테스트 아이템"
    payload.extra = BootExtra()
    payload.extra?.displaySuccessResult = true 
        
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
    payload.user = generateUser()
        
    return payload
}
``` 
 

## 자동결제 - 빌링키 발급 요청하기 
```swift
func requestSubscription() {
    let payload = generatePayload()
    payload.pg = "나이스페이"
    payload.method = "카드자동"
            
    Bootpay.requestSubscription(payload: payload, rootController: self)
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
```

## 본인인증 
```swift
func requestAuthentication() {
    let payload = generatePayload()
    payload.pg = "다날"
    payload.method = "본인인증" 
    
    if #available(iOS 13.0, *) {
        Bootpay.requestAuthentication(
            payload: payload,
            rootController: self
        )
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

}
```


## Bootpay Event Listener
결제 진행 상태에 따라 이벤트 함수가 실행됩니다. 각 이벤트에 대한 상세 설명은 아래를 참고하세요.

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


## Documentation

[부트페이 개발매뉴얼](https://developer.bootpay.co.kr/)을 참조해주세요

## 기술문의

[채팅](https://bootpay.channel.io/)으로 문의

## License

[MIT License](https://opensource.org/licenses/MIT).

