//
//  SoupMenuManager+Intents.swift
//  SoupKit
//
//  Created by Lee on 2018/9/29.
//  Copyright © 2018 Lee. All rights reserved.
//

import Foundation
import os
import Intents

extension SoupMenuManager {
    
    ///告知Siri菜单的更改
    func updateShortcuts() {
        updateMenuItemShortcuts()
//        updateSuggestions()
    }
    
    func removeDonation(for menuItem: MenuItem) {
        if menuItem.isAvailable == false {
            guard let orderHistory = orderManager?.orderHistory else {return}
            let ordersAssociatedWithRemoveMenuItem = orderHistory.filter { $0.menuItem.itemName == menuItem.itemName }
            let orderIdentifiersToRemove = ordersAssociatedWithRemoveMenuItem.map { $0.identifier.uuidString }
            //删除Ininteraction
            INInteraction.delete(with: orderIdentifiersToRemove) { (error) in
                if error != nil {
                    if let error = error as NSError? {
                        os_log("Failed to delete interactions with error: %@", log: OSLog.default, type: .error, error)
                    }
                } else {
                    os_log("Successfully deleted interactions")
                }
            }
            
        }
    }
    
    private func updateMenuItemShortcuts() {
        
        ///INShortcut:您的应用中可用的操作,系统可能建议用户或用户可以添加到Siri。
        let avilableShortcuts = availableRegularItems.compactMap { (menuItem) -> INShortcut? in
            let order = Order(quantity: 1, menuItem: menuItem, menuItemOptions: [])
            return INShortcut(intent: order.intent)
        }
        
        INVoiceShortcutCenter.shared.setShortcutSuggestions(avilableShortcuts)
    }
    
    ////配置每日特色汤作为相关快捷方式。 常规菜单上没有此项目，以演示相关快捷方式如何能够建议用户可能想要启动的任务，但之前未在应用程序中使用过。
    private func updateSuggestions() {
        
        ///定义快捷方式及其与用户的相关性的对象。
        let dailySpecialSuggestedShortcuts = availableDailySpecialItems.compactMap { (menuItem) -> INRelevantShortcut? in
            let order = Order(quantity: 1, menuItem: menuItem, menuItemOptions: [])
            let orderIntent = order.intent
            
            guard let shortcut = INShortcut(intent: orderIntent) else { return nil }
            
            let suggestedShortcut = INRelevantShortcut(shortcut: shortcut)
            
            let template = INDefaultCardTemplate(title: "配置每日特色汤")
            template.subtitle = menuItem.shortcutNameKey + "_SUBTITLE"
            template.image = INImage(named: menuItem.iconImageName)
            
            suggestedShortcut.watchTemplate = template
            
            ///到达工作岗位时提出午餐建议
            let routineRelevanceProvider = INDailyRoutineRelevanceProvider(situation: .work)
            ///此示例使用单个相关性提供程序，但支持使用多个相关性提供程序。
            suggestedShortcut.relevanceProviders = [routineRelevanceProvider]
            
            return suggestedShortcut
        }
        
        INRelevantShortcutStore.default.setRelevantShortcuts(dailySpecialSuggestedShortcuts) { (error) in
            if let error = error as NSError? {
                os_log("Providing relevant shortcut failed. \n%@", log: OSLog.default, type: .error, error)
            } else {
                os_log("Providing relevant shortcut succeeded.")
            }
        }
    }
}
