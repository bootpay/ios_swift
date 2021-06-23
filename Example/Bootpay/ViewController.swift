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
        setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        let btn = UIButton()
        btn.setTitle("Pay", for: .normal)
        btn.addTarget(self, action: #selector(showBootpay), for: .touchUpInside)
        btn.frame = CGRect(
            x: self.view.frame.width/2 - 40,
            y: self.view.frame.height/2 - 40,
            width: 80,
            height: 80
        )
        btn.setTitleColor(.darkGray, for: .normal)
        self.view.addSubview(btn)
    }
    
    @objc func showBootpay() {
//        Bootpay
        let payload = Payload()
        #if os(macOS)
        payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
        #elseif os(iOS)
        payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
        #endif
        
        payload.price = 1000
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.pg = "kcp"
        payload.method = "npay"
        payload.name = "테스트 아이템"
        payload.extra = BootExtra()
        payload.extra?.popup = 1
        payload.extra?.quickPopup = 1
        

        let user = BootUser()
        user.username = "테스트 유저"
        user.phone = "01040334678"
        payload.userInfo = user
                
        Bootpay.requestPayment(viewController: self, payload: payload)
            .onCancel { data in
                print("-- cancel: \(data)")
            }
            .onReady { data in
                print("-- ready: \(data)")
            }
            .onConfirm { data in
                print("-- confirm: \(data)")
                return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return false //재고가 없어서 결제를 승인하지 않을때
            }
            .onDone { data in
                print("-- done: \(data)")
            }
            .onError { data in
                print("-- error: \(data)")
            }
            .onClose {
                print("-- close")
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

