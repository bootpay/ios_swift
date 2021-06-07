//
//  BootOneStore.swift
//  SwiftUIBootpay
//
//  Created by Taesup Yoon on 2021/05/10.
//

import ObjectMapper

public class BootOneStore: NSObject, Mappable, Codable {
    
    
    public override init() {}
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    public func mapping(map: Map) {
        adId <- map["adId"]
        simOperator <- map["simOperator"]
        installerPackageName <- map["installerPackageName"] 
    }
    
    @objc public var adId = "UNKNOWN_ADID";
    @objc public var simOperator = "UNKNOWN_SIM_OPERATOR";
    @objc public var installerPackageName = "UNKNOWN_INSTALLER";
}
