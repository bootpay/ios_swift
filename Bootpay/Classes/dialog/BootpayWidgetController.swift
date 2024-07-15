////
////  widget 내부에서 호출하는 뷰
////  BootpayWidgetController.swift
////  Bootpay
////
////  Created by TaeSup Yoon on 7/9/24.
////
//
//class BootpayWidgetController: BTViewController {
////    let bootpayWebView = BootpayWebView()
//    
////    var bootpayWebView: BootpayWebView22?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.view.backgroundColor = .white
//        if let view = BootpayWebViewHandler.shared.bootpayView {
//           view.translatesAutoresizingMaskIntoConstraints = false
//           self.view.addSubview(view)
//           
//           NSLayoutConstraint.activate([
//               view.topAnchor.constraint(equalTo: self.view.topAnchor),
//               view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//               view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
//               view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//           ])
//        }
//    }
//    
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated) 
//        BootpayWebViewHandler.debounceClose()
//    }
//}
