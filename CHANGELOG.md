## 5.2.0
* feat: 통합 환경 모드 API `Bootpay.setEnvironmentMode(_:)` 추가 (`@objc` 노출)
  - 다른 SDK (JS / Android / Flutter / RN) 와 일관된 인터페이스
  - `"development"` | `"stage"` | `"production"` (그 외 값은 production fallback)
  - 내부적으로 `BootpayConstant.ENVIRONMENT_MODE` 와 매핑
* feat: 결제/위젯 WebView stage 환경 지원
  - DEBUG 빌드는 자동으로 development, ENVIRONMENT_MODE 가 stage 면 stage 주입
  - `Bootpay.setEnvironmentMode("stage")` 런타임 호출로 토글
* chore: `BootpayConstant.ENVIRONMENT_MODE` 기본값을 `"production"` 으로 명시
  - 배포 안전성 강화 — 별도 호출 없이도 항상 실서비스로 동작
* chore(example): Bootpay.xcconfig 기반 client_key 예제로 정리, production fallback 유지
  - legacy application_id/private_key 설정은 호환용으로 유지
  - `BOOTPAY_SECRET_KEY` 등 secret 는 클라이언트 예제에서 제거

## 5.1.1
* `startItunesToInstall()` 라우팅 보강 (Android 5.1.1과 동기화)
  - `monimopay://`, `smcard://` 스킴 → 삼성 모니모 App Store 매핑 추가
  - 기존: 매핑 분기 부재로 모니모 앱 미설치 시 버튼 무반응
  - 이후: 다른 카드사와 동일하게 App Store fallback 동작

## 5.1.0
* webview CDN URL을 5.3.0으로 업데이트
* client_key 인증 방식 추가 (기존 application_id 방식과 병행 지원)
* iOS 최소 지원 버전 14.0 → 16.0으로 상향
* WIDGET_URL도 5.3.0으로 업데이트

## 5.0.5
* SwiftUI 래퍼(BootpayUI) 병합 - 단일 패키지로 UIKit/SwiftUI 모두 지원
* SPM 빌드 시 `import UIKit` 누락으로 인한 빌드 에러 수정

## 5.0.4
* 결제 완료 후 결과 페이지 이동 (Example 앱)
  - PgPaymentController, TotalPaymentController, SubscriptionController에서 onDone 시 PaymentResultController로 이동
* WebView 프리워밍 수동 호출 방식으로 변경
  - `Bootpay.warmUp()` AppDelegate에서 명시적 호출 필요
  - GPU/WebContent/Networking 프로세스 초기화용 실제 HTML 로드

## 5.0.3
* WebView 프리워밍 API 추가
  - `Bootpay.warmUp()` 명시적 호출 API 추가
  - `Bootpay.isWarmedUp` 프리워밍 완료 여부 확인 속성 추가
  - `Bootpay.releaseWarmUp()`으로 메모리 부족 시 리소스 해제 가능
* ProcessPool 공유 구조 개선
  - `Bootpay.sharedProcessPool`을 통한 세션/쿠키 유지 및 프로세스 재사용

## 5.0.1
* BootpayCommerce issued 콜백 추가 (가상계좌 발급 완료)
* 불필요한 console.log 제거

## 5.0.0
* Widget 결제 기능 추가
* CDN URL 5.2.2 업데이트
* Example 앱 UI 전면 개선
  - NativeController를 BasePaymentController + 4개 서브클래스로 분리
  - 각 결제 타입별 실제 서비스와 유사한 UI 구현
* 위젯 취소/에러 시 UX 개선 (collapseAndReload)

## 4.5.0
* 모든 외부 의존성 제거 (ObjectMapper, CryptoSwift, NVActivityIndicatorView)
* Swift Codable 적용 (ObjectMapper 대체)
* CommonCrypto 적용 (CryptoSwift 대체)
* UIActivityIndicatorView 적용 (NVActivityIndicatorView 대체)
* Privacy Manifest (PrivacyInfo.xcprivacy) 추가
* Swift Package Manager (SPM) 지원 추가
* Swift 5.9/5.10 지원
* deprecated API 수정 (keyWindow, @retroactive 등)
* Apple Silicon 시뮬레이터 지원 (EXCLUDED_ARCHS 제거)
* .travis.yml 삭제

## 4.4.6
* xcode 16 support

## 4.4.4
* redirect webapp 시나리오시 정기결제창 안닫히는 현상 개선  

## 4.4.3
* open_type popup 결제요청시 웹앱에서 웹뷰 닫히는 현상 개선 

## 4.4.2
* escrow option added
* 의존성 모듈로 인해 최소버전이 올라감 ios 9.0 -> 13.0 

## 4.4.1
* js 4.2.6 update 
* 카드자동결제 결제수단 등록 후 조건부적 안닫히는 현상 개선

## 4.4.0
* js 4.2.2 update  

## 4.3.5
* methods 미적용 버그 해결 

## 4.3.4
* 재배포


## 4.3.3
* extra 옵션 추가 

## 4.3.1
* js 4.2.0 update
* 앱 스키마 추가 
* progress bar 추가   

## 4.3.0
* modal로 띄울시 모달 전체가 닫히는 버그가 있어 수정, 관련해서 문법이 바뀜  

## 4.2.9
* 앱 스킴 업데이트, debounceClose 시간을 늘림 (중복 close 되는 버그가 있어서 해결) 

## 4.2.8
* development 서버로 잘못 패치된거 production 으로 정정 

## 4.2.7
* reqyestType public으로 선언 (BootpayUI 를 위한 작업) 
* webview url 4.0.8 적용

## 4.2.6
* debounceClose 이벤트 시점 변경 (willdisappear -> didappear) 

## 4.2.5
* request interface 수정 

## 4.2.3
* anchor property to public

## 4.2.2
* debounceClose 이벤트 추가
* SafeArea WebView 적용    

## 4.2.1
* UI 모듈과 통일을 위해 버전을 4.2.1로 배포    

## 4.1.9
* password 결제 버그 수정   

## 4.1.8
* password 결제 추가  

## 4.1.7
* webview url 4.0.7 적용 
* String extention에 convertToDictionary 추가 

## 4.1.6
* 케이뱅크 앱스키마 추가, redirect callback event 개선  

## 4.1.5
* redirect callback event 처리 수정  

## 4.1.4
* 주석 제거    

## 4.1.3
* 네이버페이 뒤로가기 버튼 제거   

## 4.1.2
* swift_version 명시적으로 지정  

## 4.1.1
* naverpay back 클릭시 redirect 모드에서 흰화면 -> 새로고침 현상으로 개선 

## 4.1.0
* webview url 4.0.6 적용 

## 4.0.5

* opentype redirect default 옵션 적용
* webview url 4.0.5 적용   

## 4.0.2

* Bootpay.confirm(data) -> Bootpay.transacionConfirm() 으로 수정 

* confirm에서 return false 일 때 결제창 닫히는 버그 수정   

## 4.0.1

* bootpay bio 호환을 위한 필드 scope 변경  

## 4.0.0

* bootpay js major update 
