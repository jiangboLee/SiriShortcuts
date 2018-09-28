//
//  SoupMenuManager.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit

public typealias SoupMenu = Set<MenuItem>

public class SoupMenuManager: DataManager<SoupMenu> {
    
    private static let defaultMenu: SoupMenu = [
        MenuItem(itemName: "鸡肉面(今日特色)",
                 shortcutNameKey: "鸡肉面面",
                 price: 4.55, iconImageName: "chicken_noodle_soup",
                 isAvailable: true,
                 isDailySpecial: true),
        MenuItem(itemName: "蛤蜊面",
                 shortcutNameKey: "蛤蜊面面",
                 price: 3.75,
                 iconImageName: "clam_chowder",
                 isAvailable: true,
                 isDailySpecial: false),
        MenuItem(itemName: "西红柿蛋汤",
                 shortcutNameKey: "西红柿蛋汤汤",
                 price: 2.95,
                 iconImageName: "tomato_soup",
                 isAvailable: true,
                 isDailySpecial: false)
    ]
    
    public var orderManager: SoupOrderDataManager?
    
    public convenience init() {
        let storageInfo = UserDefaultsStorageDescriptor(key: UserDefaults.StorageKeys.soupMenu.rawValue,
                                                        keyPath: \UserDefaults.menu)
        self.init(storageDescriptor: storageInfo)
    }
    
    override func deployInitialData() {
        dataAccessQueue.sync {
            managedData = SoupMenuManager.defaultMenu
        }
        
        //TODO: daixu
    }
   
}

extension SoupMenuManager {
    
    public var availableItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isAvailable == true }.sortedByName()
        }
    }
    
    public var availableDailySpecialItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == true && $0.isAvailable == true }.sortedByName()
        }
    }
    
    public var dailySpecialItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == true }.sortedByName()
        }
    }
    
    public var regularItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == false }.sortedByName()
        }
    }
    
    public var availableRegularItems: [MenuItem] {
        return dataAccessQueue.sync {
            return managedData.filter { $0.isDailySpecial == false && $0.isAvailable == true }.sortedByName()
        }
    }
    
    public func replaceMenuItem(_ previousMenuItem: MenuItem, with menuItem: MenuItem) {
        dataAccessQueue.sync {
            managedData.remove(previousMenuItem)
            managedData.insert(menuItem)
        }
        
        ///对用户默认值的访问是在单独的访问队列后面进行的
        writeData()
        
        //FIXME: --
    }
}


/// 为`soupMenuStorage`键启用`UserDefaults`观察
private extension UserDefaults {
    
    @objc var menu: Data? {
        return data(forKey: StorageKeys.soupMenu.rawValue)
    }
}

private extension Array where Element == MenuItem {
    func sortedByName() -> [MenuItem] {
        return sorted(by: { (item1, item2) -> Bool in
            item1.itemName.localizedCaseInsensitiveCompare(item2.itemName) == .orderedAscending
        })
    }
}
