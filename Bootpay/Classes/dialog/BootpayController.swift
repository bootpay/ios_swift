//
//  BootpayController.swift
//  SwiftBootpay
//
//  Created by Taesup Yoon on 2021/05/12.
//

class BootpayController: BTViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BootpayWebViewHandler.initWebView()
        
        self.view.backgroundColor = .white
        if let view = BootpayWebViewHandler.shared.bootpayView {
           view.translatesAutoresizingMaskIntoConstraints = false
           self.view.addSubview(view)
           
           NSLayoutConstraint.activate([
               view.topAnchor.constraint(equalTo: self.view.topAnchor),
               view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
               view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
               view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
           ])
//            view.load
        }
        BootpayWebViewHandler.loadBootpayUrl()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BootpayWebViewHandler.debounceClose()
    }
}

