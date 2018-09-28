//
//  SoupOrderDataManager.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation

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
}

extension SoupOrderDataManager {
    
    ///总下单历史
    public var orderHistory: [Order] {
        return dataAccessQueue.sync {
            return managedData
        }
    }
    
    ///在数据管理器中存储订单。
    ///此项目不在iOS和watchOS之间共享数据。手表上的订单不会显示在iOS订单历史记录中。
    public func placeOrder(order: Order) {
        dataAccessQueue.sync {
            managedData.insert(order, at: 0)
        }
        writeData()
        
        //FIXME: --
    }
}

private extension UserDefaults {
    @objc var orderHistory: Data? {
        return data(forKey: StorageKeys.orderHistory.rawValue)
    }
}
