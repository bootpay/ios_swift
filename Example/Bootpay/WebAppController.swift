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
        let webview = BootpayWebView()
        
        var topPadding = CGFloat(0)
        var bottomPadding = CGFloat(0)
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window?.safeAreaInsets.top ?? CGFloat(0)
            bottomPadding = window?.safeAreaInsets.bottom ?? CGFloat(0)
        }
        
        webview.frame = CGRect(x: 0,
                               y: topPadding,
                               width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height - topPadding - bottomPadding)
        webview.webview.frame = CGRect(x: 0,
                               y: 0,
                               width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height - topPadding - bottomPadding)
        
        let urlString = "https://www.yourdomain.com/"

        if let url = URL(string: urlString) {
            webview.webview.load(URLRequest(url: url))
        }
        
        self.view.addSubview(webview)
    }
}


