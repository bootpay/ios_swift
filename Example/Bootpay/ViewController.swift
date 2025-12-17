//
//  ViewController.swift
//  Bootpay
//
//  Created by bootpay on 06/02/2021.
//  Copyright (c) 2021 bootpay. All rights reserved.
//

import UIKit
import Bootpay

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "부트페이 예제"
        setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white

        let buttons: [(String, Selector)] = [
            ("PG일반 테스트", #selector(goPgPayment)),
            ("통합결제 테스트", #selector(goTotalPayment)),
            ("정기결제 테스트", #selector(goSubscription)),
            ("본인인증 테스트", #selector(goAuthentication)),
            ("WebApp 연동 예제", #selector(goWebApp)),
            ("Widget 연동 예제", #selector(goWidget))
        ]

        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 10
        let totalHeight = CGFloat(buttons.count) * buttonHeight + CGFloat(buttons.count - 1) * buttonSpacing
        let startY = (self.view.frame.height - totalHeight) / 2

        for (i, buttonInfo) in buttons.enumerated() {
            let btn = UIButton()
            btn.setTitle(buttonInfo.0, for: .normal)
            btn.addTarget(self, action: buttonInfo.1, for: .touchUpInside)

            btn.frame = CGRect(
                x: self.view.frame.width/2 - 100,
                y: startY + CGFloat(i) * (buttonHeight + buttonSpacing),
                width: 200,
                height: buttonHeight
            )
            btn.setTitleColor(.darkGray, for: .normal)
            self.view.addSubview(btn)
        }
    }


    @objc func goPgPayment() {
        let vc = PgPaymentController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goTotalPayment() {
        let vc = TotalPaymentController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goSubscription() {
        let vc = SubscriptionController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goAuthentication() {
        let vc = AuthenticationController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goWebApp() {
        let vc = WebAppController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func goWidget() {
        let vc = WidgetController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

