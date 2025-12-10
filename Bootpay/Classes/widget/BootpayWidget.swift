//
//  BootpayWidget.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/10.
//

import SwiftUI

/// SwiftUI용 부트페이 위젯
/// UIViewRepresentable을 사용하여 BootpayWidgetView를 SwiftUI에서 사용할 수 있도록 합니다.
@available(iOS 14.0, *)
public struct BootpayWidget: UIViewRepresentable {

    /// 결제 페이로드
    public var payload: Payload

    /// 위젯 컨트롤러
    @ObservedObject public var controller: BootpayWidgetController

    /// 위젯 높이 바인딩
    @Binding public var height: CGFloat

    /// 초기화
    /// - Parameters:
    ///   - payload: 결제 페이로드
    ///   - controller: 위젯 컨트롤러
    ///   - height: 위젯 높이 바인딩
    public init(payload: Payload, controller: BootpayWidgetController, height: Binding<CGFloat>) {
        self.payload = payload
        self.controller = controller
        self._height = height
    }

    public func makeUIView(context: Context) -> BootpayWidgetView {
        let widgetView = BootpayWidgetView()
        widgetView.payload = payload
        widgetView.controller = controller

        // 높이 변경 콜백 설정
        let originalOnResize = controller.onResize
        controller.onResize = { [weak controller] newHeight in
            DispatchQueue.main.async {
                self.height = newHeight
            }
            originalOnResize?(newHeight)
        }

        // 위젯 시작
        widgetView.startWidget()

        return widgetView
    }

    public func updateUIView(_ uiView: BootpayWidgetView, context: Context) {
        // payload가 변경되면 업데이트
        if uiView.payload !== payload {
            uiView.payload = payload
        }
    }

    public static func dismantleUIView(_ uiView: BootpayWidgetView, coordinator: ()) {
        // 정리 작업
    }
}

// MARK: - BootpayWidgetController ObservableObject Extension

@available(iOS 14.0, *)
extension BootpayWidgetController: ObservableObject {
    // ObservableObject 프로토콜 준수를 위한 확장
}

// MARK: - Preview Provider

@available(iOS 14.0, *)
struct BootpayWidget_Previews: PreviewProvider {
    static var previews: some View {
        BootpayWidgetPreviewWrapper()
    }
}

@available(iOS 14.0, *)
private struct BootpayWidgetPreviewWrapper: View {
    @StateObject private var controller = BootpayWidgetController()
    @State private var widgetHeight: CGFloat = 300

    var body: some View {
        VStack {
            BootpayWidget(
                payload: createSamplePayload(),
                controller: controller,
                height: $widgetHeight
            )
            .frame(height: widgetHeight)

            Spacer()
        }
    }

    private func createSamplePayload() -> Payload {
        let payload = Payload()
        payload.applicationId = "5b9f51264457636ab9a07cdd"
        payload.price = 1000
        payload.orderName = "테스트 상품"
        payload.orderId = "order_\(Date().timeIntervalSince1970)"
        return payload
    }
}
