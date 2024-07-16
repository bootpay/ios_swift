//
//  BaseController.swift
//  Bootpay_Example
//
//  Created by TaeSup Yoon on 7/16/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//


import UIKit
import Bootpay
  

open class BaseController: BTViewController {
    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    public var scrollViewBottomAnchorConstraint: NSLayoutConstraint?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    private func setupConstraints() {
        scrollViewBottomAnchorConstraint = scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollViewBottomAnchorConstraint!,
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor), 
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}
