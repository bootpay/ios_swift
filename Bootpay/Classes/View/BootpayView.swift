//
//  BootpayView.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

import WebKit
import NVActivityIndicatorView


@objc open class BootpayView: BTView {
    @objc public var webView: BootpayWebView?
    
    var circleView: NVActivityIndicatorView?
    var circleBG: BTView?
    
    @objc public init() {
        #if os(macOS)
        super.init(frame: NSScreen.main!.frame)
        #elseif os(iOS)
        super.init(frame: UIScreen.main.bounds)
        #endif
        
        self.backgroundColor = .white
        initComponent()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    public func showProgressBar(_ isShow: Bool) {
        circleBG?.isHidden = !isShow
        isShow ? circleView?.startAnimating() : circleView?.stopAnimating()
    }
    
    private func initComponent() {
//        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
//        
//        
        configureWebView()
        configureCircleView()
//        
//        setupConstraints()
//        Bootpay.shared.webview = webview
        showProgressBar(false)
    }
    
    private func configureWebView() {
        print("configureWebView")
        let configuration = WKWebViewConfiguration()
        webView = nil 
            
        #if os(macOS)
        webView = BootpayWebView(frame: self.bounds, configuration: configuration)
        webView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(webView!)
        
        NSLayoutConstraint.activate([
            webView!.topAnchor.constraint(equalTo: self.topAnchor),
            webView!.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView!.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            webView!.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        #elseif os(iOS)
        webView = BootpayWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView!.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(webView!)
        
        NSLayoutConstraint.activate([
            webView!.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            webView!.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView!.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            webView!.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        #endif
        
//        let configuration = WKWebViewConfiguration()
        
//        webView = BootpayWebView(frame: self.bounds, configuration: configuration)
        
//        self.addSubview(webView!)
//        webView?.loadUrl("https://www.naver.com")
    }
    
    private func configureCircleView() {
       circleBG = BTView()
       if let circleBG = circleBG {
           circleBG.backgroundColor = .black.withAlphaComponent(0.25)
           circleBG.translatesAutoresizingMaskIntoConstraints = false
           self.addSubview(circleBG)
           
           NSLayoutConstraint.activate([
               circleBG.topAnchor.constraint(equalTo: self.topAnchor),
               circleBG.bottomAnchor.constraint(equalTo: self.bottomAnchor),
               circleBG.leadingAnchor.constraint(equalTo: self.leadingAnchor),
               circleBG.trailingAnchor.constraint(equalTo: self.trailingAnchor)
           ])
       }
       
        circleView = NVActivityIndicatorView(frame: .zero)
       if let circleView = circleView, let circleBG = circleBG {
           circleView.translatesAutoresizingMaskIntoConstraints = false
           circleBG.addSubview(circleView)
           
           NSLayoutConstraint.activate([
               circleView.centerXAnchor.constraint(equalTo: circleBG.centerXAnchor),
               circleView.centerYAnchor.constraint(equalTo: circleBG.centerYAnchor, constant: -60),
               circleView.widthAnchor.constraint(equalToConstant: 40),
               circleView.heightAnchor.constraint(equalToConstant: 40)
           ])
           
           circleView.startAnimating()
       }
    }
}
