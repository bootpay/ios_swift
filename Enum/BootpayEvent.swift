//
//  BootpayEvent.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

public enum BootpayEvent: String {
    case defaultEvent = "Bootpay" //redirect 포함
    case done = "BootpayDone"
    case confirm = "BootpayConfirm"
    case issued = "BootpayIssued"
    case cancel = "BootpayCancel"
    case error = "BootpayError"
    case close = "CLOSE"
    
}

