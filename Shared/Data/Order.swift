//
//  Order.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation

public struct Order: Codable {
    
    public enum MenuItemOption: String, Codable, LocalizableShortcutString {
        case cheese = "奶酪"
        case redPepper = "红辣椒"
        case croutons = "巴豆"
        
        public static let all: [MenuItemOption] = [.cheese, .redPepper, .croutons]
        
        var shortcutLocalizationKey: String {
            switch self {
            case .cheese:
                return "奶酪"
            case .redPepper:
                return "红辣椒"
            case .croutons:
                return "巴豆"
            }
        }
    }
    
    public let date: Date
    public let identifier: UUID
    public let menuItem: MenuItem
    public var quantity: Int
    public var menuItemOptions: Set<MenuItemOption>
    public var total: Decimal {
        return Decimal(quantity) * menuItem.price
    }
    
    public init(date: Date = Date(), identifier: UUID = UUID(), quantity: Int, menuItem: MenuItem, menuItemOptions: Set<MenuItemOption>) {
        self.date = date
        self.identifier = identifier
        self.quantity = quantity
        self.menuItem = menuItem
        self.menuItemOptions = menuItemOptions
    }
}


extension Order: LocalizableCurrency {
    var localizedCurrencyValue: String {
        return NumberFormatter.currencyFormatter.string(from: total as NSDecimalNumber) ?? ""
    }
}
