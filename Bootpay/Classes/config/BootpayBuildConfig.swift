//
//  BootpayBuildConfig.swift
//  SwiftUIBootpay (iOS)
//
//  Created by Taesup Yoon on 2021/05/10.
//
 

#if os(macOS)
import AppKit
public typealias BTNavigationController = NSPageController
public typealias BTView = NSView
public typealias BTViewController = NSViewController
#elseif os(iOS)
import UIKit
public typealias BTNavigationController = UINavigationController
public typealias BTView = UIView
public typealias BTViewController = UIViewController
#endif

struct BootpayBuildConfig { 
    static let DEBUG = false
    static let VERSION = "4.4.0"
}
