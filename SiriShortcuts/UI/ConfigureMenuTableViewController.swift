//
//  ConfigureMenuTableViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

class ConfigureMenuTableViewController: UITableViewController {
    
    enum SectionType {
        case regularItems, specialItems
    }
    
    private typealias SectionModel = (sectionType: SectionType, sectionHeaderText: String, sectionFooterText: String, rowContent: [MenuItem])
    
    public var soupMenuManager: SoupMenuManager!
    
    public var soupOrderDataManager: SoupOrderDataManager! {
        didSet {
            soupMenuManager.orderManager = soupOrderDataManager
        }
    }
    
    private var sectionData: [SectionModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadData()
    }

    private func reloadData() {
        
        sectionData = [SectionModel(sectionType: .regularItems,
                                    sectionHeaderText: "家常菜",
                                    sectionFooterText: "取消选中一行以删除与菜单项关联的任何捐赠的快捷方式",
                                    rowContent: soupMenuManager.regularItems),
                       SectionModel(sectionType: .specialItems, sectionHeaderText: "今日加餐", sectionFooterText: "检查本节中的一行以提供相关的快捷方式。", rowContent: soupMenuManager.dailySpecialItems)]
        
        tableView.reloadData()
    }
}

extension ConfigureMenuTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionData[section].rowContent.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        let menuItem = sectionData[indexPath.section].rowContent[indexPath.row]
        cell.textLabel?.text = menuItem.itemName
        cell.accessoryType = menuItem.isAvailable ? .checkmark : .none
        return cell
    }
}

extension ConfigureMenuTableViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionData[section].sectionHeaderText
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionData[section].sectionFooterText
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
