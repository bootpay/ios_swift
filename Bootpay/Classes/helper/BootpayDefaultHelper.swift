//
//  BootpayDefaultHelper.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//

import Foundation

//MARK: UserDefault Standard For Session
class BootpayDefaultHelper {
    static func getInt(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    static func getString(key: String) -> String {
        guard let value = UserDefaults.standard.string(forKey: key) else { return "" }
        return value
    }
    
    static func setValue(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
