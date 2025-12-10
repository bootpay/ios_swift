//
//  BootpayWidgetDelegate.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/10.
//

import Foundation

/// 부트페이 위젯 이벤트를 수신하기 위한 델리게이트 프로토콜
@objc public protocol BootpayWidgetDelegate: AnyObject {

    /// 위젯이 로드 완료되었을 때 호출됩니다.
    @objc optional func bootpayWidgetReady()

    /// 위젯의 높이가 변경되었을 때 호출됩니다.
    /// - Parameter height: 변경된 위젯 높이
    @objc optional func bootpayWidgetResize(height: CGFloat)

    /// 결제 수단이 변경되었을 때 호출됩니다.
    /// - Parameter data: 변경된 위젯 데이터
    @objc optional func bootpayWidgetChangePayment(data: WidgetData)

    /// 약관 동의 상태가 변경되었을 때 호출됩니다.
    /// - Parameter data: 변경된 위젯 데이터
    @objc optional func bootpayWidgetChangeAgreeTerm(data: WidgetData)

    /// 결제 에러가 발생했을 때 호출됩니다.
    /// - Parameter data: 에러 정보
    @objc optional func bootpayWidgetError(data: [String: Any])

    /// 결제가 취소되었을 때 호출됩니다.
    /// - Parameter data: 취소 정보
    @objc optional func bootpayWidgetCancel(data: [String: Any])

    /// 결제가 완료되었을 때 호출됩니다.
    /// - Parameter data: 결제 완료 정보
    @objc optional func bootpayWidgetDone(data: [String: Any])

    /// 결제 확인이 필요할 때 호출됩니다.
    /// - Parameter data: 결제 확인 정보
    /// - Returns: true를 반환하면 결제가 진행됩니다.
    @objc optional func bootpayWidgetConfirm(data: [String: Any]) -> Bool

    /// 가상계좌 발급이 완료되었을 때 호출됩니다.
    /// - Parameter data: 가상계좌 발급 정보
    @objc optional func bootpayWidgetIssued(data: [String: Any])

    /// 위젯이 닫혔을 때 호출됩니다.
    @objc optional func bootpayWidgetClose()
}
