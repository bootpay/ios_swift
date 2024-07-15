//
//  WKUserContentController.Extension.swift
//  Bootpay
//
//  Created by TaeSup Yoon on 7/11/24.
//

import WebKit

extension WKUserContentController {
    private struct AssociatedKeys {
        static var eventHandlers = "eventHandlers"
    }

    private var eventHandlers: [String] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.eventHandlers) as? [String] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.eventHandlers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addUniqueScriptMessageHandler(_ scriptMessageHandler: WKScriptMessageHandler, name: String) {
        if !eventHandlers.contains(name) {
            add(scriptMessageHandler, name: name)
            
            
            eventHandlers.append(name)
        }
    }
}
