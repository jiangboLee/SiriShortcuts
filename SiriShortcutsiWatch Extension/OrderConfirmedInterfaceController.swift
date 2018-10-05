//
//  OrderConfirmedInterfaceController.swift
//  SiriShortcutsiWatch Extension
//
//  Created by LEE on 2018/10/4.
//  Copyright © 2018年 Lee. All rights reserved.
//

import UIKit
import WatchKit
import SoupKitWatch

class OrderConfirmedInterfaceController: WKInterfaceController {

    @IBOutlet weak var image: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        
        guard let order = context as? Order else { return }
        image.setImage(UIImage(named: order.menuItem.iconImageName))
        
        //下单
        let orderManager = SoupOrderDataManager()
        orderManager.placeOrder(order: order)
    }
}
