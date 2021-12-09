//
//  BootpayController.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//

class BootpayController: BTViewController {
    let bootpayWebView = BootpayWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(bootpayWebView)
        bootpayWebView.startBootpay()
    }
}
