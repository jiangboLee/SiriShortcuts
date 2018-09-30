//
//  UserDefaults+DataSource.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    
    /// 注意：此项目不在iOS和watchOS之间共享数据。手表上的订单不会显示在iOS订单历史记录中。
    private static let APPGroup = "group.com.lijiangbo.LEERandom"
    
    enum StorageKeys: String {
        case soupMenu
        case orderHistory
        case voiceShortcutHistory
    }
    
    static let dataSuite = { () -> UserDefaults in
        guard let dataSuite = UserDefaults(suiteName: APPGroup) else {
            fatalError("Could not load UserDefaults for app group \(APPGroup)")
        }
        return dataSuite
    }()
}
