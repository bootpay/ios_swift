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
        
        bootpayWebView.translatesAutoresizingMaskIntoConstraints = false
        
        let constrains = [
            bootpayWebView.topAnchor.constraint(equalTo: self.view.safeTopAnchor),
            bootpayWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bootpayWebView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor),
            bootpayWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
 
        ]
        NSLayoutConstraint.activate(constrains)
        self.view.backgroundColor = .white
        
        
        bootpayWebView.startBootpay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Bootpay.shared.debounceClose()
    }
}
