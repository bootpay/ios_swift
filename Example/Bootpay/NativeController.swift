//
//  NativeController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class NativeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        let btn = UIButton()
        btn.setTitle("결제하기", for: .normal)
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
        let payload = Payload()
        payload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
                
        payload.price = 1000
        payload.orderId = String(NSTimeIntervalSince1970)
        payload.pg = "payletter"
        payload.method = "card"
        payload.name = "테스트 아이템"
        payload.extra = BootExtra()
        payload.extra?.popup = 0
        payload.extra?.quickPopup = 0
        
        let item1 = BootItem()
        item1.itemName = "나는 아이템1"
        item1.qty = 1
        item1.unique = "item_01"
        item1.price = 500
        item1.cat1 = "TOP"
        item1.cat2 = "티셔츠"
        item1.cat3 = "반팔티"
        
        let item2 = BootItem()
        item2.itemName = "나는 아이템1"
        item2.qty = 2
        item2.unique = "item_02"
        item2.price = 250
        item2.cat1 = "TOP"
        item2.cat2 = "데님"
        item2.cat3 = "청자켓"
        payload.items = [item1, item2]
        

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
}


