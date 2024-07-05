//
//  BTViewController.swift
//  Bootpay_Example
//
//  Created by TaeSup Yoon on 7/5/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

open class BTViewController: UIViewController {
    public lazy var scrollView = UIScrollView()
    public lazy var stackView = UIStackView()
    
    public var scrollViewBottomAnchorConstraint: NSLayoutConstraint?
    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
        stackView.spacing = 24
        stackView.axis = .vertical
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}
