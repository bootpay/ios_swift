//
//  BootpayDefaultHelper.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//

import Foundation

//MARK: UserDefault Standard For Session
open class BootpayDefaultHelper {
    static public func getInt(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    
    static public func getString(key: String) -> String {
        guard let value = UserDefaults.standard.string(forKey: key) else { return "" }
        return value
    }
    
    static public func setValue(_ key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
