//
//  DeviceHelper.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2021/12/09.
//

enum DeviceHelper {
    case nativeMac
    case iPad
    case iPhone
    case iWatch
    
    public static var currentDevice: Self {
        var currentDeviceModel = UIDevice.current.model
        #if targetEnvironment(macCatalyst)
        currentDeviceModel = "nativeMac"
        #elseif os(watchOS)
        currentDeviceModel = "watchOS"
        #endif
        
        if currentDeviceModel.starts(with: "iPhone") {
            return .iPhone
        }
        if currentDeviceModel.starts(with: "iPad") {
            return .iPad
        }
        if currentDeviceModel.starts(with: "watchOS") {
            return .iWatch
        }
        return .nativeMac
    }
}
