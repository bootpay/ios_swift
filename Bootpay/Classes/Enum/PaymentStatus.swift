//
//  PaymentStatus.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

public enum PaymentStatus: String {
    case done = "DONE"
    case error = "ERROR"
    case cancel = "CANCEL"
    case issued = "ISSUED"
    case none = "NONE"
}

