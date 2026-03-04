//
//  CommerceController.swift
//  Bootpay
//
//  Created by Taesup Yoon on 2024/12/23.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

class CommerceController: UIViewController {
    let commerceWebView = CommerceWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(commerceWebView)

        commerceWebView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            commerceWebView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            commerceWebView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            commerceWebView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            commerceWebView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        self.view.backgroundColor = .white

        commerceWebView.startCommerce()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BootpayCommerce.shared.debounceClose()
    }
}
