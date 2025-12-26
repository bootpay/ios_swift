//
//  AppDelegate.swift
//  Bootpay
//
//  Created by bootpay on 06/02/2021.
//  Copyright (c) 2021 bootpay. All rights reserved.
//

import UIKit
import Bootpay

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // WebView 프로세스 프리워밍 - 첫 결제 화면 로딩 속도 개선
        Bootpay.warmUp()
        return true
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        // 메모리 부족 시 프리워밍 리소스 해제
        Bootpay.releaseWarmUp()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
