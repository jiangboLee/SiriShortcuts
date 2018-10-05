//
//  SoupOrderDataManager.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation
import Intents
import os

public class SoupOrderDataManager: DataManager<[Order]> {
    
    public convenience init() {
        let storageInfo = UserDefaultsStorageDescriptor(key: UserDefaults.StorageKeys.orderHistory.rawValue, keyPath: \UserDefaults.orderHistory)
        self.init(storageDescriptor: storageInfo)
    }
    
    override func deployInitialData() {
        dataAccessQueue.sync {
            ///首次使用该应用时，订单历史记录为空。
            managedData = []
        }
    }
    ///将`Order`转换为`OrderSoupIntent`并将其作为与系统的交互捐赠
    ///这样可以在将来此订单被建议或转换为语音快捷方式来快速下订单。
    private func donateInteraction(for order: Order) {
        let interaction = INInteraction(intent: order.intent, response: nil)
        
        ///订单标识符用于与捐赠匹配
        //如果从菜单中删除汤，可以删除交互。
        interaction.identifier = order.identifier.uuidString
        interaction.donate { (error) in
            if error != nil {
                if let error = error as NSError? {
                    os_log("Interaction donation failed: %@", log: OSLog.default, type: .error, error)
                }
            } else {
                os_log("Successfully donated interaction")
            }
        }
    }
}

extension SoupOrderDataManager {
    
    ///总下单历史
    public var orderHistory: [Order] {
        print(userDefaults.value(forKey: "hehe")) 
        return dataAccessQueue.sync {
            return managedData
        }
    }
    
    public func order(matching identifier: UUID) -> Order? {
        return orderHistory.first { $0.identifier == identifier }
    }
    
    ///在数据管理器中存储订单。
    ///此项目不在iOS和watchOS之间共享数据。手表上的订单不会显示在iOS订单历史记录中。
    public func placeOrder(order: Order) {
        dataAccessQueue.sync {
            managedData.insert(order, at: 0)
        }
        writeData()
        
        //向系统捐赠互动
        donateInteraction(for: order)
    }
}

private extension UserDefaults {
    @objc var orderHistory: Data? {
        return data(forKey: StorageKeys.orderHistory.rawValue)
    }
}
