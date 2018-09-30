//
//  AppDelegate.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import os
import SoupKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSStringFromClass(OrderSoupIntent.self) ||
            userActivity.activityType == NSUserActivity.viewMenuActivityType || userActivity.activityType == NSUserActivity.orderCompleteActivityType else {
                os_log("Can't continue unknown NSUserActivity type %@", userActivity.activityType)
                return false
        }
        
        guard let window = window,
            let rootViewController = window.rootViewController as? UINavigationController else {
                os_log("Failed to access root view controller.")
                return false
        }
        
        
        //`restorationHandler`将用户活动传递给传入的视图控制器，以将用户路由到应用程序的一部分
        restorationHandler(rootViewController.viewControllers)
        return true
    }


}

