# Bootpay iOS SDK

[![Version](https://img.shields.io/cocoapods/v/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)
[![License](https://img.shields.io/cocoapods/l/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)
[![Platform](https://img.shields.io/cocoapods/p/Bootpay.svg?style=flat)](https://cocoapods.org/pods/Bootpay)

Bootpay 결제 연동을 위한 iOS Swift SDK입니다. UIKit과 SwiftUI를 모두 지원합니다.

- iOS 14.0+
- Swift 5.9+
- 외부 의존성 없음

## 설치

### Swift Package Manager (SPM)

Xcode에서 `File` > `Add Package Dependencies...` 선택 후 URL 입력:

```
https://github.com/bootpay/ios_swift.git
```

또는 `Package.swift`에 직접 추가:

```swift
dependencies: [
    .package(url: "https://github.com/bootpay/ios_swift.git", from: "5.0.5")
]
```

타겟에 의존성 추가:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "Bootpay", package: "ios_swift")
    ]
)
```

### CocoaPods

`Podfile`에 추가:

```ruby
pod 'Bootpay'
```

설치:

```bash
pod install
```

## info.plist 설정

```xml
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
        <string>kr.co.bootpaySample</string> <!-- 앱의 bundle url name -->
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bootpaySample</string> <!-- 앱의 bundle url scheme -->
        </array>
    </dict>
</array>
```

카드사 앱 실행 후 원래 앱으로 돌아오지 않는 경우, `CFBundleURLSchemes`를 설정하면 부트페이 SDK가 해당 값을 읽어 `extra.appScheme`에 자동으로 채웁니다.

## 사용법

### UIKit

```swift
import UIKit
import Bootpay

class PaymentController: UIViewController {

    @objc func showBootpay() {
        let payload = Payload()
        payload.applicationId = "YOUR_APPLICATION_ID"
        payload.price = 1000
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.orderName = "테스트 아이템"
        payload.pg = "kcp"
        payload.method = "card"

        let user = BootUser()
        user.username = "테스트 유저"
        user.phone = "01012345678"
        payload.user = user

        Bootpay.requestPayment(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true // 결제 승인
            }
            .onDone { data in
                print("-- done: \(data)")
            }
            .onError { data in
                print("-- error: \(data)")
            }
        Bootpay.onClose {
            print("-- close")
        }
    }
}
```

### SwiftUI

```swift
import SwiftUI
import Bootpay

struct PaymentView: View {
    var body: some View {
        BootpayUI(
            payload: makePayload(),
            requestType: BootpayConstant.REQUEST_TYPE_PAYMENT
        )
        .onDone { data in
            print("결제 완료: \(data)")
        }
        .onCancel { data in
            print("결제 취소: \(data)")
        }
        .onError { data in
            print("결제 에러: \(data)")
        }
        .onClose {
            print("결제창 닫힘")
        }
    }

    func makePayload() -> Payload {
        let payload = Payload()
        payload.applicationId = "YOUR_APPLICATION_ID"
        payload.orderName = "테스트 결제"
        payload.price = 1000
        payload.orderId = "order_\(Int(Date().timeIntervalSince1970))"
        return payload
    }
}
```

### 결제 타입

| 타입 | UIKit | SwiftUI requestType |
|------|-------|---------------------|
| 일반결제 | `Bootpay.requestPayment(...)` | `BootpayConstant.REQUEST_TYPE_PAYMENT` (1) |
| 정기결제 | `Bootpay.requestSubscription(...)` | `BootpayConstant.REQUEST_TYPE_SUBSCRIPT` (2) |
| 본인인증 | `Bootpay.requestAuthentication(...)` | `BootpayConstant.REQUEST_TYPE_AUTH` (3) |
| 비밀번호결제 | `Bootpay.requestPassword(...)` | `BootpayConstant.REQUEST_TYPE_PASSWORD` (4) |

## WebView 프리워밍

iOS의 WKWebView는 첫 로딩 시 GPU, Networking, WebContent 프로세스를 생성하므로 4-6초의 지연이 발생할 수 있습니다. AppDelegate에서 프리워밍을 호출하면 첫 결제 화면 로딩 속도가 크게 개선됩니다.

```swift
// AppDelegate.swift
import Bootpay

func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Bootpay.warmUp()
    return true
}

// (선택) 메모리 경고 시 리소스 해제
func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
    Bootpay.releaseWarmUp()
}
```

| API | 설명 |
|-----|------|
| `Bootpay.warmUp()` | WebView 프로세스 미리 초기화 (기본 0.1초 딜레이) |
| `Bootpay.warmUp(delay: 0.5)` | 커스텀 딜레이로 프리워밍 |
| `Bootpay.isWarmedUp` | 프리워밍 완료 여부 확인 |
| `Bootpay.releaseWarmUp()` | 프리워밍 리소스 해제 (메모리 부족 시) |

## 콜백 함수 설명

| 함수 | 설명 |
|------|------|
| `onError` | 결제 진행 중 오류 발생 시 호출 |
| `onCancel` | 사용자가 결제창에서 취소/닫기 시 호출 |
| `onConfirm` | 결제 승인 직전 호출. `return true`로 승인, `return false`로 중단 |
| `onIssued` | 가상계좌 발급 완료 시 호출 |
| `onDone` | 결제 완료 시 호출. 반드시 REST API로 [결제검증](https://docs.bootpay.co.kr/rest/verify) 필요 |
| `onClose` | 결제창이 닫힐 때 호출 |

## ios_swiftui에서 마이그레이션

5.0.5부터 SwiftUI 래퍼(`BootpayUI`)가 이 패키지에 포함되었습니다. 기존 `ios_swiftui` 패키지 사용자는:

1. `ios_swiftui` 의존성을 제거하고 `ios_swift`로 교체
2. `import BootpayUI` → `import Bootpay`로 변경
3. `BootpayRequest.TYPE_PAYMENT` → `BootpayConstant.REQUEST_TYPE_PAYMENT`로 변경 (또는 정수 리터럴 1, 2, 3, 4 사용)

## 문서

- [부트페이 공식 문서](https://docs.bootpay.co.kr/)
- [변경 이력](CHANGELOG.md)

## 라이선스

MIT
