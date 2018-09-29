//
//  Order+Intents.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/28.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation
import Intents

extension Order {
    public var intent: OrderSoupIntent {
        let orderSoupIntent = OrderSoupIntent()
        
        //给intents的属性一一赋值
        orderSoupIntent.quantity = quantity as NSNumber
        
        let displayString = NSString.deferredLocalizedIntentsString(with: menuItem.shortcutLocalizationKey) as String
        orderSoupIntent.soup = INObject(identifier: menuItem.itemName, display: displayString)
        orderSoupIntent.setImage(INImage(named: menuItem.iconImageName), forParameterNamed: \OrderSoupIntent.soup)
        
        orderSoupIntent.options = menuItemOptions.map { (option) -> INObject in
            let displayString = NSString.deferredLocalizedIntentsString(with: option.shortcutLocalizationKey) as String
            return INObject(identifier: option.rawValue, display: displayString)
        }
        
        ///你可以这样说下面的文字：
        orderSoupIntent.suggestedInvocationPhrase = NSString.deferredLocalizedIntentsString(with: "我长得帅吗？") as String
        
        return orderSoupIntent
    }
    
    public init?(from intent: OrderSoupIntent) {
        let menuManager = SoupMenuManager()
        guard let soupID = intent.soup?.identifier,
        let menyItem = menuManager.findItem(identifier: soupID),
        let quantity = intent.quantity else { return nil }
        
        let rawOptions = intent.options?.compactMap { (option) -> MenuItemOption? in
            guard let optionID = option.identifier else { return nil }
            return MenuItemOption(rawValue: optionID)
        } ?? [MenuItemOption]()
        
        self.init(quantity: quantity.intValue, menuItem: menyItem, menuItemOptions: Set(rawOptions))
    }
    
    
}
