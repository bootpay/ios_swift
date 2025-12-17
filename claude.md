# Bootpay iOS Swift SDK

Bootpay 결제 연동을 위한 iOS Swift SDK 입니다.

## 프로젝트 구조

```
Bootpay/
├── Classes/
│   ├── config/
│   │   └── BootpayBuildConfig.swift    # SDK 버전 관리
│   ├── constants/
│   │   └── BootpayConstant.swift       # CDN URL, 상수 정의
│   ├── models/                         # 데이터 모델
│   └── ...
Example/
├── Bootpay/                            # 예제 앱
│   ├── BasePaymentController.swift     # 결제 공통 베이스
│   ├── PgPaymentController.swift       # PG 일반결제
│   ├── TotalPaymentController.swift    # 통합결제
│   ├── SubscriptionController.swift    # 정기결제
│   ├── AuthenticationController.swift  # 본인인증
│   └── ...
CHANGELOG.md                            # 버전별 변경 기록
```

## 버전 업데이트 가이드

SDK 버전을 올릴 때 반드시 다음 파일들을 함께 수정해야 합니다:

### 1. BootpayBuildConfig.swift
```swift
// 경로: Bootpay/Classes/config/BootpayBuildConfig.swift
struct BootpayBuildConfig {
    static let DEBUG = false
    static let VERSION = "4.5.0"  // ← SDK 버전 수정
}
```

### 2. BootpayConstant.swift (CDN URL 버전)
```swift
// 경로: Bootpay/Classes/constants/BootpayConstant.swift
public class BootpayConstant {
    public static let CDN_URL = "https://webview.bootpay.co.kr/5.2.2";     // ← CDN 버전 수정
    public static let WIDGET_URL = "https://webview.bootpay.co.kr/5.2.2/widget.html"  // ← 위젯 URL 버전 수정
}
```

### 3. CHANGELOG.md
```markdown
// 경로: CHANGELOG.md
## X.X.X (새 버전)
* 변경사항 1
* 변경사항 2
* ...

## 4.5.0 (이전 버전)
* ...
```

### 4. Podspec (배포 시)
```ruby
// 경로: Bootpay.podspec
s.version = 'X.X.X'  // ← 배포 버전 수정
```

## 버전 업데이트 체크리스트

버전을 올릴 때 아래 항목을 확인하세요:

- [ ] `BootpayBuildConfig.swift`의 `VERSION` 수정
- [ ] `BootpayConstant.swift`의 `CDN_URL` 수정 (CDN 버전 변경 시)
- [ ] `BootpayConstant.swift`의 `WIDGET_URL` 수정 (CDN 버전 변경 시)
- [ ] `CHANGELOG.md`에 새 버전 변경사항 추가
- [ ] `Bootpay.podspec`의 `version` 수정 (CocoaPods 배포 시)

## 커밋 컨벤션

```
feat: 새로운 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
docs: 문서 수정
chore: 빌드, 설정 변경
```

## Example 앱 구조

각 결제 타입별로 Controller가 분리되어 있습니다:

| Controller | 용도 | UI 테마 |
|------------|------|---------|
| PgPaymentController | PG 일반결제 | 상품 상세 페이지 (파란색) |
| TotalPaymentController | 통합결제 | 장바구니/결제 페이지 (초록색) |
| SubscriptionController | 정기결제 | 구독 페이지 (보라색) |
| AuthenticationController | 본인인증 | 인증 페이지 (청록색) |

모든 Controller는 `BasePaymentController`를 상속받아 공통 기능을 재사용합니다.
