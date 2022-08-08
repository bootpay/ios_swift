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
        
        for i in 0...1 {
            let btn = UIButton()
            if(i == 0) {
                btn.setTitle("Native 연동 예제", for: .normal)
                btn.addTarget(self, action: #selector(goNative), for: .touchUpInside)
            } else {
                btn.setTitle("WebApp 연동 예제", for: .normal)
                btn.addTarget(self, action: #selector(goWebApp), for: .touchUpInside)
            }
            
            
            btn.frame = CGRect(
                x: self.view.frame.width/2 - 100,
                y: self.view.frame.height/2 - 120 + CGFloat(90 * i),
                width: 200,
                height: 80
            )
            btn.setTitleColor(.darkGray, for: .normal)
            self.view.addSubview(btn)
        }
    }
    
    
    @objc func goNative() {
        let vc = NativeController()
//        vc.modalPresentationStyle = .fullScreen
//        self.navigationController?.present(vc, animated: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goWebApp() {
        let vc = WebAppController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

