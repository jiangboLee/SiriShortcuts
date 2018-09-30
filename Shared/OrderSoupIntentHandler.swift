//
//  OrderSoupIntentHandler.swift
//  SoupKit
//
//  Created by Lee on 2018/9/29.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

public class OrderSoupIntentHandler: NSObject, OrderSoupIntentHandling {
    
    ///确认下单回调方法
    public func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        
        guard let soup = intent.soup,
            let order = Order(from: intent) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }
        //下单
        let ordermanager = SoupOrderDataManager()
        ordermanager.placeOrder(order: order)
        
        let orderdate = Date()
        let readydate = Date(timeInterval: 10 * 60, since: orderdate)
        
        let userActivity = NSUserActivity(activityType: NSUserActivity.orderCompleteActivityType)
        userActivity.addUserInfoEntries(from: [NSUserActivity.ActivityKeys.orderID.rawValue: order.identifier])
        print(order.identifier)
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        if let formattedWaitTime = formatter.string(from: orderdate, to: readydate) {
            let response = OrderSoupIntentResponse.success(soup: soup, waitTime: formattedWaitTime)
            response.userActivity = userActivity
            
            completion(response)
        } else {
            // A fallback success code with a less specific message string
            let response = OrderSoupIntentResponse.successReadySoon(soup: soup)
            response.userActivity = userActivity
            
            completion(response)
        }
    }
    
    public func confirm(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        ///确认阶段为您提供了对意图参数进行任何最终验证的机会,验证是否有任何所需的服务。您可能确认可以与公司的服务器通信
        let soupMenuManager = SoupMenuManager()
        guard let soup = intent.soup,
            let identifier = soup.identifier,
            let menuItem = soupMenuManager.findItem(identifier: identifier) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }
        
        if menuItem.isAvailable == false {
            completion(OrderSoupIntentResponse.failureOutOfStock(soup: soup))
            return
        }
        //验证意图后，指示意图已准备好处理
        completion(OrderSoupIntentResponse(code: .ready, userActivity: nil))
    }
}
