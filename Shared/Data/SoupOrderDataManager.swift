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
    
}

private extension UserDefaults {
    @objc var orderHistory: Data? {
        return data(forKey: StorageKeys.orderHistory.rawValue)
    }
}
