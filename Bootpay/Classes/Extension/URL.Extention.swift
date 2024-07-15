//
//  URL.Extention.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//

import Foundation

extension URL {
    public var queryItems: [String: Any] {
        var params = [String: Any]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (_, item) -> [String: Any] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }
}
