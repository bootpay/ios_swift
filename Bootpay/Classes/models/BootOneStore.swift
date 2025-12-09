//
//  BootOneStore.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import Foundation

public class BootOneStore: NSObject, Codable {

    public override init() {}

    enum CodingKeys: String, CodingKey {
        case adId = "ad_id"
        case simOperator = "sim_operator"
        case installerPackageName = "installer_package_name"
    }

    @objc public var adId = "UNKNOWN_ADID";
    @objc public var simOperator = "UNKNOWN_SIM_OPERATOR";
    @objc public var installerPackageName = "UNKNOWN_INSTALLER";
}
