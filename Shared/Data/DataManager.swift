//
//  DataManager.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation
import os

/// 为`DataManager`提供存储配置信息
struct UserDefaultsStorageDescriptor {
    
    /// 读取和写入“UserDefaults”时用作键名的`String`值
    let key: String
    
    /// “UserDefaults”上用于观察更改的属性的关键路径
    let keyPath: KeyPath<UserDefaults, Data?>
}

/// 想要知道数据何时发生变化的`DataManager`的客户端可以监听此通知。
public let dataChangedNotificationKey = NSNotification.Name(rawValue: "DataChangedNotification")

/// `DataManager`是一个抽象类，它将符合`Codable`的数据保存到`UserDefaults`。
public class DataManager<ManagedDataType: Codable> {
    
    /// 此示例使用应用程序组在主应用程序和不同扩展之间共享一组数据。
    let userDefaults = UserDefaults.dataSuite
    
    /// 为防止数据争用，对“UserDefaults”的所有访问都使用此队列。
    private let userDefaultsAccessQueue = DispatchQueue(label: "User Defaults Access Queue")
    
    /// 存储和观察信息
    private let storageDescriptor: UserDefaultsStorageDescriptor
    
    /// 一个标志，用于避免接收有关此实例刚写入“UserDefaults”的数据的通知。
    private var ignoreLocalUserDefaultsChanges = false
    
    /// 观察者对象在注册观察属性后返还。
    private var userDefaultsObserver: NSKeyValueObservation?
    
    /// 这个`DataManager`管理的数据。只能在`dataAccessQueue`上访问此通道。
    var managedData: ManagedDataType!
    
    /// 需要在专用队列上访问`managedData`以避免数据争用。
    let dataAccessQueue = DispatchQueue(label: "Data Access Queue")
    
    init(storageDescriptor: UserDefaultsStorageDescriptor) {
        self.storageDescriptor = storageDescriptor
        loadData()
        
        if managedData == nil {
            deployInitialData()
            writeData()
        }
        
        observeChangesInUserDefaults()
    }
    
    /// 期望子类实现此方法并为`managedData`设置自己的初始数据。
    func deployInitialData() {
        
    }
    
    ///监听
    private func observeChangesInUserDefaults() {
        userDefaultsObserver = userDefaults.observe(storageDescriptor.keyPath) { [weak self] (_, _) in
            //忽略来自此实例刚刚保存到“UserDefaults”的数据的任何更改通知。
            guard self?.ignoreLocalUserDefaultsChanges == false else { return }
            
            //基础数据在“UserDefaults”中更改，因此请使用更改更新此实例并通知客户端更改。
            self?.loadData()
            self?.notifyClientsDataChanged()
        }
    }
    
    /// 通过使用键“dataChangedNotificationKey”发布“Notification”来通知客户端数据已更改
    private func notifyClientsDataChanged() {
        NotificationCenter.default.post(name: dataChangedNotificationKey, object: self)
    }
    
    /// 从“UserDefaults”加载数据。
    private func loadData() {
        
        userDefaultsAccessQueue.sync {
            guard let archivedData = userDefaults.data(forKey: storageDescriptor.key) else { return }
            
            do {
                let decoder = PropertyListDecoder()
                managedData = try decoder.decode(ManagedDataType.self, from: archivedData)
            } catch let error as NSError {
                os_log("Error decoding data: %@", log: OSLog.default, type: .error, error)
            }
        }
    }
    
    ///将数据写入`UserDefaults`
    func writeData() {
        userDefaultsAccessQueue.async {
            self.userDefaults.setValue("你好啊aaa", forKey: "hehe")
            do {
                let encoder = PropertyListEncoder()
                let encoderData = try encoder.encode(self.managedData)
                
                self.ignoreLocalUserDefaultsChanges = true
                self.userDefaults.set(encoderData, forKey: self.storageDescriptor.key)
                self.ignoreLocalUserDefaultsChanges = false
                
                self.notifyClientsDataChanged()
                
            } catch let error as NSError {
                os_log("Error decoding data: %@", log: OSLog.default, type: .error, error)
            }
            
            
        }
    }
}
