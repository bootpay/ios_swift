# Bootpay iOS Widget 연동 가이드

## 개요

Bootpay Widget은 앱 화면 내에 삽입 가능한 결제 컴포넌트입니다. 사용자가 결제수단을 선택하고 약관에 동의한 후, 결제하기 버튼을 눌러 결제를 진행할 수 있습니다.

## 기본 구성요소

### 1. BootpayWidgetView
결제 위젯을 표시하는 UIView입니다. 화면에 삽입하여 사용합니다.

### 2. BootpayWidgetController
위젯의 상태를 관리하고 이벤트 콜백을 처리하는 컨트롤러입니다.

### 3. Payload
결제 정보를 담는 데이터 클래스입니다.

## 연동 방법

### Step 1. Import

```swift
import Bootpay
```

### Step 2. 프로퍼티 선언

```swift
var widgetView: BootpayWidgetView!
var widgetController: BootpayWidgetController!
var payload: Payload!
var widgetHeightConstraint: NSLayoutConstraint!
```

### Step 3. Payload 설정

```swift
func setupPayload() {
    payload = Payload()
    payload.applicationId = "YOUR_APPLICATION_ID"  // 부트페이 관리자에서 확인
    payload.price = 1000                            // 결제 금액
    payload.orderId = String(Int(Date().timeIntervalSince1970 * 1000))  // 주문 고유 ID
    payload.orderName = "테스트 상품"               // 주문명

    // Widget 필수 설정
    payload.widgetKey = "default-widget"           // 위젯 키
    payload.widgetSandbox = true                   // 샌드박스 모드 (테스트: true, 운영: false)
    payload.widgetUseTerms = true                  // 약관동의 UI 사용 여부

    // User 설정 (선택)
    payload.user = BootUser()
    payload.user?.id = "user_id"
    payload.user?.username = "홍길동"
    payload.user?.email = "test@example.com"
    payload.user?.phone = "01012341234"

    // Extra 설정 (선택)
    payload.extra = BootExtra()
    payload.extra?.appScheme = "yourAppScheme"     // 앱 스킴 (앱투앱 결제 복귀용)
    // payload.extra?.displaySuccessResult = true  // 결제 성공 결과 화면 표시 여부
    // payload.extra?.displayErrorResult = true    // 결제 에러 결과 화면 표시 여부
}
```

### Step 4. UI 구성

```swift
func setupUI() {
    // Widget View 생성
    widgetView = BootpayWidgetView()
    widgetView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(widgetView)

    // 결제 버튼 생성
    let payButton = UIButton(type: .system)
    payButton.setTitle("결제하기", for: .normal)
    payButton.isEnabled = false  // 초기에는 비활성화
    payButton.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
    view.addSubview(payButton)

    // Constraints 설정
    NSLayoutConstraint.activate([
        widgetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        widgetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        widgetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        // ... 기타 constraints
    ])

    // 위젯 높이 constraint (동적으로 변경됨)
    widgetHeightConstraint = widgetView.heightAnchor.constraint(equalToConstant: 516)
    widgetHeightConstraint.isActive = true
}
```

### Step 5. WidgetController 설정

```swift
func setupWidgetController() {
    widgetController = BootpayWidgetController()

    // 닫기 동작 설정
    widgetController.closeAction = .none  // 직접 처리

    // 위젯 준비 완료
    widgetController.onReady = {
        print("위젯 준비 완료")
    }

    // 위젯 높이 변경
    widgetController.onResize = { [weak self] height in
        self?.widgetHeightConstraint.constant = height
        UIView.animate(withDuration: 0.3) {
            self?.view.layoutIfNeeded()
        }
    }

    // 결제수단 변경
    widgetController.onChangePayment = { [weak self] data in
        self?.payload.mergeWidgetData(data)
        self?.updatePayButtonState()
    }

    // 약관동의 변경
    widgetController.onChangeAgreeTerm = { [weak self] data in
        self?.payload.mergeWidgetData(data)
        self?.updatePayButtonState()
    }

    // 결제 완료
    widgetController.onDone = { [weak self] data in
        print("결제 완료: \(data)")
        // 결과 페이지로 이동 또는 처리
    }

    // 결제 에러
    widgetController.onError = { [weak self] data in
        print("결제 에러: \(data)")
        // 에러 처리
    }

    // 결제 취소
    widgetController.onCancel = { data in
        print("결제 취소: \(data)")
    }

    // 결제 확인 (서버 검증 후 진행 여부 결정)
    widgetController.onConfirm = { data in
        // 서버에서 결제 정보 검증 후 true/false 반환
        return true
    }

    // 가상계좌 발급
    widgetController.onIssued = { data in
        print("가상계좌 발급: \(data)")
    }

    // 닫기
    widgetController.onClose = { [weak self] in
        self?.navigationController?.popViewController(animated: true)
    }

    // 위젯 뷰에 컨트롤러 연결
    widgetView.controller = widgetController
}
```

### Step 6. 위젯 시작

```swift
func startWidget() {
    widgetView.payload = payload
    widgetView.startWidget()
}
```

### Step 7. 결제 요청

```swift
@objc func requestPayment() {
    guard payload.widgetIsCompleted else {
        // 결제수단 선택과 약관동의 미완료
        return
    }
    widgetController.requestPayment(payload: payload)
}

func updatePayButtonState() {
    payButton.isEnabled = payload.widgetIsCompleted
}
```

## displaySuccessResult / displayErrorResult 옵션

결제 완료 또는 에러 발생 시 웹뷰에서 결과 화면을 표시할지 여부를 설정합니다.

### 옵션별 동작

| 옵션 | 값 | 동작 |
|------|-----|------|
| `displaySuccessResult` | `true` | 결제 성공 시 웹뷰에서 결과 화면 표시 → 사용자가 닫기 버튼 클릭 → `onClose` 호출 |
| `displaySuccessResult` | `false` (기본값) | 결제 성공 시 즉시 `onDone` 호출 → 앱에서 결과 화면 처리 |
| `displayErrorResult` | `true` | 결제 에러 시 웹뷰에서 에러 화면 표시 → 사용자가 닫기 버튼 클릭 → `onClose` 호출 |
| `displayErrorResult` | `false` (기본값) | 결제 에러 시 즉시 `onError` 호출 → 위젯 자동 재로드 |

### 권장 사용 패턴

#### 패턴 1: 앱 네이티브 결과 화면 사용 (권장)

```swift
// Payload 설정
payload.extra = BootExtra()
payload.extra?.displaySuccessResult = false  // 기본값
payload.extra?.displayErrorResult = false    // 기본값

// Controller 설정
widgetController.closeAction = .none

widgetController.onDone = { [weak self] data in
    // 네이티브 결과 화면으로 이동
    let resultVC = PaymentResultController()
    resultVC.paymentData = data

    if let nav = self?.navigationController {
        var viewControllers = nav.viewControllers
        viewControllers.removeLast()
        viewControllers.append(resultVC)
        nav.setViewControllers(viewControllers, animated: true)
    }
}

widgetController.onError = { [weak self] data in
    // 에러 후 위젯 재로드 (재시도 가능)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self?.widgetView.reloadWidget()
    }
}

widgetController.onCancel = { [weak self] data in
    // 취소 시 이전 화면으로
    self?.navigationController?.popViewController(animated: true)
}

widgetController.onClose = { [weak self] in
    // 닫기 시 이전 화면으로
    self?.navigationController?.popViewController(animated: true)
}
```

#### 패턴 2: 웹뷰 결과 화면 사용

```swift
// Payload 설정
payload.extra = BootExtra()
payload.extra?.displaySuccessResult = true
payload.extra?.displayErrorResult = true

// Controller 설정
widgetController.closeAction = .popViewController  // 자동 pop

widgetController.onDone = { data in
    print("결제 완료 - 웹뷰에서 결과 화면 표시 중")
    // 별도 처리 불필요, 사용자가 닫기 버튼 클릭 시 자동 pop
}

widgetController.onError = { data in
    print("결제 에러 - 웹뷰에서 에러 화면 표시 중")
    // 별도 처리 불필요, 사용자가 닫기 버튼 클릭 시 자동 pop
}
```

## closeAction 옵션

위젯 닫기 시 동작을 설정합니다.

| 값 | 동작 |
|----|------|
| `.popViewController` | NavigationController에서 현재 화면 pop |
| `.dismissViewController` | Modal로 표시된 경우 dismiss |
| `.none` | 아무 동작 안함 (onClose에서 직접 처리) |

```swift
// 예시: NavigationController 사용 시
widgetController.closeAction = .popViewController

// 예시: Modal 사용 시
widgetController.closeAction = .dismissViewController

// 예시: 직접 처리
widgetController.closeAction = .none
widgetController.onClose = { [weak self] in
    // 커스텀 동작
    self?.navigationController?.popToRootViewController(animated: true)
}
```

## 이벤트 콜백 정리

| 콜백 | 설명 | 파라미터 |
|------|------|----------|
| `onReady` | 위젯 준비 완료 | 없음 |
| `onResize` | 위젯 높이 변경 | `height: CGFloat` |
| `onChangePayment` | 결제수단 변경 | `data: WidgetData` |
| `onChangeAgreeTerm` | 약관동의 변경 | `data: WidgetData` |
| `onDone` | 결제 완료 | `data: [String: Any]` |
| `onError` | 결제 에러 | `data: [String: Any]` |
| `onCancel` | 결제 취소 | `data: [String: Any]` |
| `onConfirm` | 결제 확인 (검증) | `data: [String: Any]` → `Bool` 반환 |
| `onIssued` | 가상계좌 발급 | `data: [String: Any]` |
| `onClose` | 위젯 닫기 | 없음 |

## WidgetData 구조

```swift
class WidgetData {
    var pg: String?           // PG사 코드
    var method: String?       // 결제수단
    var termPassed: Bool      // 약관동의 완료 여부
    var completed: Bool       // 결제 준비 완료 여부 (결제수단 + 약관동의)
    var methodOriginSymbol: String?  // 결제수단 원본 심볼
    var cardQuota: String?    // 할부 개월
    var methodSymbol: String? // 결제수단 심볼
    var easyPay: String?      // 간편결제 종류
}
```

## 전체 예제 코드

```swift
import UIKit
import Bootpay

class WidgetController: UIViewController {

    let applicationId = "YOUR_APPLICATION_ID"

    var widgetView: BootpayWidgetView!
    var widgetController: BootpayWidgetController!
    var payButton: UIButton!
    var widgetHeightConstraint: NSLayoutConstraint!
    var payload: Payload!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "결제하기"

        setupPayload()
        setupUI()
        setupWidgetController()
        startWidget()
    }

    func setupPayload() {
        payload = Payload()
        payload.applicationId = applicationId
        payload.price = 1000
        payload.orderId = String(Int(Date().timeIntervalSince1970 * 1000))
        payload.orderName = "테스트 상품"

        payload.widgetKey = "default-widget"
        payload.widgetSandbox = true
        payload.widgetUseTerms = true

        payload.user = BootUser()
        payload.user?.id = "test_user"
        payload.user?.username = "홍길동"
        payload.user?.email = "test@example.com"
        payload.user?.phone = "01012341234"

        payload.extra = BootExtra()
        payload.extra?.appScheme = "myAppScheme"
    }

    func setupUI() {
        // ScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Widget View
        widgetView = BootpayWidgetView()
        widgetView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(widgetView)

        // Pay Button
        payButton = UIButton(type: .system)
        payButton.setTitle("결제하기", for: .normal)
        payButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        payButton.backgroundColor = .systemGray
        payButton.setTitleColor(.white, for: .normal)
        payButton.layer.cornerRadius = 10
        payButton.isEnabled = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
        view.addSubview(payButton)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -10),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            widgetView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            widgetView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            widgetView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            widgetView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            payButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        widgetHeightConstraint = widgetView.heightAnchor.constraint(equalToConstant: 516)
        widgetHeightConstraint.isActive = true
    }

    func setupWidgetController() {
        widgetController = BootpayWidgetController()
        widgetController.closeAction = .none

        widgetController.onReady = {
            print("[Widget] Ready")
        }

        widgetController.onResize = { [weak self] height in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.widgetHeightConstraint.constant = height
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        widgetController.onChangePayment = { [weak self] data in
            self?.payload.mergeWidgetData(data)
            self?.updatePayButtonState()
        }

        widgetController.onChangeAgreeTerm = { [weak self] data in
            self?.payload.mergeWidgetData(data)
            self?.updatePayButtonState()
        }

        widgetController.onDone = { [weak self] data in
            print("[Widget] Done: \(data)")
            // 결과 페이지로 이동
            let resultVC = PaymentResultController()
            resultVC.paymentData = data
            if let nav = self?.navigationController {
                var viewControllers = nav.viewControllers
                viewControllers.removeLast()
                viewControllers.append(resultVC)
                nav.setViewControllers(viewControllers, animated: true)
            }
        }

        widgetController.onError = { [weak self] data in
            print("[Widget] Error: \(data)")
            // 위젯 재로드
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.widgetView.reloadWidget()
            }
        }

        widgetController.onCancel = { [weak self] data in
            print("[Widget] Cancel: \(data)")
            self?.navigationController?.popViewController(animated: true)
        }

        widgetController.onConfirm = { data in
            return true
        }

        widgetController.onIssued = { data in
            print("[Widget] Issued: \(data)")
        }

        widgetController.onClose = { [weak self] in
            print("[Widget] Close")
            self?.navigationController?.popViewController(animated: true)
        }

        widgetView.controller = widgetController
    }

    func startWidget() {
        widgetView.payload = payload
        widgetView.startWidget()
    }

    func updatePayButtonState() {
        let isCompleted = payload.widgetIsCompleted
        DispatchQueue.main.async { [weak self] in
            self?.payButton.isEnabled = isCompleted
            self?.payButton.backgroundColor = isCompleted ? .systemBlue : .systemGray
        }
    }

    @objc func requestPayment() {
        guard payload.widgetIsCompleted else { return }
        widgetController.requestPayment(payload: payload)
    }
}
```

## 주의사항

1. **위젯 높이**: 위젯 내용에 따라 높이가 동적으로 변경됩니다. `onResize` 콜백에서 높이를 업데이트해야 합니다.

2. **결제 버튼 활성화**: `payload.widgetIsCompleted`가 `true`일 때만 결제 버튼을 활성화하세요.

3. **앱 스킴 설정**: 앱투앱 결제(카드사 앱, 은행 앱 등) 후 복귀를 위해 `payload.extra?.appScheme`을 설정해야 합니다.

4. **샌드박스 모드**: 테스트 시 `payload.widgetSandbox = true`로 설정하고, 운영 환경에서는 `false`로 변경하세요.

5. **서버 검증**: `onConfirm` 콜백에서 서버로 결제 정보를 전송하여 검증한 후 결제를 진행하는 것을 권장합니다.
