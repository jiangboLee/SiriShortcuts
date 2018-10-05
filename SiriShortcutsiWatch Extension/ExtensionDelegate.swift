//
//  ExtensionDelegate.swift
//  SiriShortcutsiWatch Extension
//
//  Created by LEE on 2018/10/4.
//  Copyright © 2018年 Lee. All rights reserved.
//

import WatchKit
import SoupKitWatch

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func handle(_ userActivity: NSUserActivity) {
        guard let rootController = WKExtension.shared().rootInterfaceController else { return }
        
        rootController.popToRootController()
        
        if userActivity.activityType == NSUserActivity.viewMenuActivityType || userActivity.activityType == NSStringFromClass(OrderSoupIntent.self) {
            rootController.pushController(withName: MenuInterfaceController.controllerIdentifier, context: nil)
        } else if userActivity.activityType == NSUserActivity.orderCompleteActivityType, (userActivity.userInfo?[NSUserActivity.ActivityKeys.orderID.rawValue] as? UUID) != nil {
            rootController.pushController(withName: HistoryInterfaceController.controllerIdentifier, context: nil)
        }
    }

}
