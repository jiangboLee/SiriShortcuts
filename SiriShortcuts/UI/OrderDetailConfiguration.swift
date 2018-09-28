//
//  OrderDetailConfiguration.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/28.
//  Copyright © 2018 Lee. All rights reserved.
//

import Foundation

struct OrderDetailConfiguration {
    
    enum OrderType {
        case new, historical
    }
    
    enum SectionType: String {
        case price = "价格"
        case quantity = "数量"
        case options = "额外选项"
        case total = "总价"
    }
    
    enum ReuseIdentifiers: String {
        case basic = "BasicCell"
        case quantity = "QuantityCell"
    }
    
    public let orderType: OrderType
    
    init(orderType: OrderType) {
        self.orderType = orderType
    }
    
    typealias SectionModel = (type: SectionType, rowCount: Int, cellReuseIdentifier: String)
    
    private static let newOrderSectionModel: [SectionModel] = [SectionModel(type: .price, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.basic.rawValue), SectionModel(type: .quantity, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.quantity.rawValue), SectionModel(type: .options, rowCount: Order.MenuItemOption.all.count, cellReuseIdentifier: ReuseIdentifiers.basic.rawValue), SectionModel(type: .total, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.basic.rawValue)]
    
    private static let historicalOrderSectionModel: [SectionModel] = [SectionModel(type: .quantity, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.quantity.rawValue), SectionModel(type: .options, rowCount: Order.MenuItemOption.all.count, cellReuseIdentifier: ReuseIdentifiers.basic.rawValue), SectionModel(type: .total, rowCount: 1, cellReuseIdentifier: ReuseIdentifiers.basic.rawValue)]
    
    var sections: [SectionModel] {
        switch orderType {
        case .new:
            return OrderDetailConfiguration.newOrderSectionModel
        case .historical:
            return OrderDetailConfiguration.historicalOrderSectionModel
        }
    }
}
