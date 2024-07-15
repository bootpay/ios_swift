//
//  WidgetController.swift
//  Bootpay_Example
//
//  Created by TaeSup Yoon on 7/5/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Bootpay

class WidgetController: BTViewController {
 
   private lazy var button = UIButton()
   var payload = Payload()

   var widgetView: UIView?
   
   override func viewDidLoad() {
       super.viewDidLoad()
       
       let label = UILabel()
       label.text = "위젯 테스트"
       
       

       self.view.backgroundColor = .brown
       view.addSubview(button)
       button.backgroundColor = .systemBlue
       button.setTitle("결제하기", for: .normal)
       button.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
       updatePaymentButtonState()
     
        
//       payload.applicationId = "5b9f51264457636ab9a07cdd"
       payload.applicationId = "5b8f6a4d396fa665fdc2b5e9"
       payload.orderName = "부트페이 결제테스트"
       payload.orderId = String(NSTimeIntervalSince1970)
       payload.widgetSandbox = true
       payload.widgetUseTerms = true
       payload.price = 1000
//       payload.userToken = "6667b08b04ab6d03f274d32e"
       payload.widgetKey = "default-widget"
       
       payload.extra = BootExtra()
       payload.extra?.displaySuccessResult = true

       
       widgetView = BootpayWidget.render(
        payload: payload,
        onWidgetResize: { height in
            print("onWidgetResize: \(height)")
        },
        onWidgetReady: {
            print("onWidgetReady")
        },
        onWidgetChangePayment: { widgetData in
            print("onWidgetChangePayment: \(widgetData.toJSON())")
            self.payload.mergeWidgetData(data: widgetData)
            self.updatePaymentButtonState()
        },
        onWidgetChangeAgreeTerm: { widgetData in
            print("onWidgetChangeAgreeTerm: \(widgetData.toJSON())")
            self.payload.mergeWidgetData(data: widgetData)
            self.updatePaymentButtonState()
        },
        needReloadWidget: {
            if self.widgetView != nil { self.stackView.addArrangedSubview(self.widgetView!) }
        }
       )
       
//       guard let widgetView = widgetView else { return }

       stackView.addArrangedSubview(label)
       stackView.addArrangedSubview(button)
       if self.widgetView != nil { self.stackView.addArrangedSubview(self.widgetView!) }
       
   }
    
    func updatePaymentButtonState() {
//        button.isEnabled = payload.getWidgetIsCompleted()
        
        button.backgroundColor = payload.getWidgetIsCompleted() == true ? .systemBlue : .darkGray
    }

   @objc func requestPayment() {
       print("requestPayment click")
       
       BootpayWidget.requestPayment(
          payload: self.payload
          
       ).onCancel { data in
           print("-- cancel: \(data)")
       }
       .onIssued { data in
           print("-- issued: \(data)")
       }
       .onConfirm { data in
           print("-- confirm: \(data)")
           return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                Bootpay.transactionConfirm()
//                return false //재고가 없어서 결제를 승인하지 않을때
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
 
