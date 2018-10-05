//
//  MenuInterfaceController.swift
//  SiriShortcutsiWatch Extension
//
//  Created by LEE on 2018/10/5.
//  Copyright © 2018年 Lee. All rights reserved.
//
import WatchKit
import UIKit
import os
import SoupKitWatch

class MenuInterfaceController: WKInterfaceController {
    
    static let controllerIdentifier = "menu"
    private static let confirmOrderSegue = "confirmOrderSegue"
    
    let tableData = SoupMenuManager().availableItems
    
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadTableRows()
    }
    
    override func didAppear() {
        
        let userActivity = NSUserActivity.viewMenuActivity
        update(userActivity)
    }
    
    private func loadTableRows() {
        guard !tableData.isEmpty else {
            return
        }
        
        interfaceTable.setNumberOfRows(self.tableData.count, withRowType: MenuInterfaceController.controllerIdentifier)
        
        for rowIndex in 0 ..< tableData.count {
            guard let elementRow = interfaceTable.rowController(at: rowIndex) as? MenuItemRowController else {
                os_log("Unexpected row controller")
                return
            }
            let rowData = tableData[rowIndex]
            elementRow.soupName.setText(rowData.itemName)
            elementRow.soupImage.setImage(UIImage(named: rowData.iconImageName))
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        guard segueIdentifier == MenuInterfaceController.confirmOrderSegue else {
            return nil
        }
        
        let menuItem = tableData[rowIndex]
        let newOrder = Order(quantity: 1, menuItem: menuItem, menuItemOptions: [])
        return newOrder
    }
}


class MenuItemRowController: NSObject {
    @IBOutlet var soupImage: WKInterfaceImage!
    @IBOutlet var soupName: WKInterfaceLabel!
}
