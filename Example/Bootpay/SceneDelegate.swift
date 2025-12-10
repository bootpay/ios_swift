//
//  SceneDelegate.swift
//  Bootpay
//
//  Created by bootpay on 2024/01/01.
//  Copyright © 2024 bootpay. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        // 앱이 종료된 상태에서 URL로 실행된 경우 처리
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    // 앱이 실행 중일 때 URL 스킴으로 돌아온 경우 처리
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) {
        // 카드사 앱에서 돌아올 때 아무 처리 안함 (웹뷰가 이전 상태 유지)
        // 필요시 여기서 추가 처리 가능
        print("Bootpay: App returned with URL: \(url.absoluteString)")
    }
}
