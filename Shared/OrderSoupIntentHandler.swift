//
//  OrderSoupIntentHandler.swift
//  SoupKit
//
//  Created by Lee on 2018/9/29.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

public class OrderSoupIntentHandler: NSObject, OrderSoupIntentHandling {
    public func handle(intent: OrderSoupIntent, completion: @escaping (OrderSoupIntentResponse) -> Void) {
        
        guard let soup = intent.soup,
            let order = Order(from: intent) else {
                completion(OrderSoupIntentResponse(code: .failure, userActivity: nil))
                return
        }
        
        let ordermanager = SoupOrderDataManager()
        ordermanager.placeOrder(order: order)
        
        let orderdate = Date()
        let readydate = Date(timeInterval: 10 * 60, since: orderdate)
        
        let userActivity = NSUserActivity(activityType: NSUserActivity.orderCompleteActivityType)
        userActivity.addUserInfoEntries(from: [NSUserActivity.ActivityKeys.orderID.rawValue: order.identifier])
        
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
}
