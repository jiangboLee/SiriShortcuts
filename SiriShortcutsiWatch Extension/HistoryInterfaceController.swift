//
//  HistoryInterfaceController.swift
//  SiriShortcutsiWatch Extension
//
//  Created by LEE on 2018/10/4.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit
import WatchKit
import SoupKitWatch
import os

class HistoryInterfaceController: WKInterfaceController {
    static let controllerIdentifier = "history"
    let tableData = SoupOrderDataManager().orderHistory
    
    @IBOutlet weak var interfaceTable: WKInterfaceTable!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadTableRows()
    }
    
    func loadTableRows() {
        guard !tableData.isEmpty else {
            return
        }
        interfaceTable.setNumberOfRows(self.tableData.count, withRowType: HistoryInterfaceController.controllerIdentifier)
        
        for rowIndex in 0 ..< tableData.count {
            guard let elementRow = interfaceTable.rowController(at: rowIndex) as? HistoryItemRowController  else {
                os_log("Unexpected row controller")
                return
            }
            
            let rowData = tableData[rowIndex]
            let dateString = dateFormatter.string(from: rowData.date)
            elementRow.itemOrderedLabel.setText(rowData.menuItem.itemName)
            elementRow.orderedTimeLabel.setText(dateString)
        }
    }
}

class HistoryItemRowController: NSObject {
    @IBOutlet weak var itemOrderedLabel: WKInterfaceLabel!
    @IBOutlet weak var orderedTimeLabel: WKInterfaceLabel!
}
