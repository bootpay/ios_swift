//
//  WebAppController.swift
//  Bootpay_Example
//
//  Created by Taesup Yoon on 2021/07/16.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

//
//  ViewController.swift
//  Bootpay
//
//  Created by bootpay on 06/02/2021.
//  Copyright (c) 2021 bootpay. All rights reserved.
//

import UIKit
import Bootpay

class WebAppController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUIWebView()
    }
    
    func setUIWebView() {
        self.view.backgroundColor = .white
        let bootpayWebView = BootpayWebView()
        
//        var topPadding = CGFloat(0)
//        var bottomPadding = CGFloat(0)
//        if #available(iOS 11.0, *) {
//            let window = UIApplication.shared.keyWindow
//            topPadding = window?.safeAreaInsets.top ?? CGFloat(0)
//            bottomPadding = window?.safeAreaInsets.bottom ?? CGFloat(0)
//        }
        
        NSLayoutConstraint.activate([
            bootpayWebView.topAnchor.constraint(equalTo: self.view.topAnchor),
            bootpayWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bootpayWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bootpayWebView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
//        bootpayView.frame = CGRect(x: 0,
//                               y: topPadding,
//                               width: UIScreen.main.bounds.width,
//                               height: UIScreen.main.bounds.height - topPadding - bottomPadding)
//        bootpayView.webView?.frame = CGRect(x: 0,
//                               y: 0,
//                               width: UIScreen.main.bounds.width,
//                               height: UIScreen.main.bounds.height - topPadding - bottomPadding)
        
        let urlString = "https://webview.bootpay.co.kr/5.0.0-rc.13/widget.html"
//        bootpayView.

        if let url = URL(string: urlString) {
            bootpayWebView.load(URLRequest(url: url))
        }
        
        self.view.addSubview(bootpayWebView)
    }
}


