//
//  OrderHistoryTableViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

class OrderHistoryTableViewController: UITableViewController {

    private static let cellReuseIdentifier = "SoupOrderDetailCell"
    
    private enum SegueIdentifiers: String {
        case orderDetail = "OrderDetails"
        case soupMenu = "SoupMenu"
        case configureMenu = "ConfigureMenu"
    }
    
    private let soupMenuManager = SoupMenuManager()
    private let soupOrderManager = SoupOrderDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    //MARK: - target Action
    /// 用于返回此控制器
    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
        
    }
    @IBAction func placeNewOrder(segue: UIStoryboardSegue) {
        
    }

    //MARK: - Nacigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.orderDetail.rawValue {
            
        } else if segue.identifier == SegueIdentifiers.soupMenu.rawValue {
            if let navController = segue.destination as? UINavigationController,
                let soupMenuVC = navController.viewControllers.first as? SoupMenuViewController {
                
            }
        } else if segue.identifier == SegueIdentifiers.configureMenu.rawValue {
            if let navController = segue.destination as? UINavigationController,
               let configureMenuTableVC = navController.viewControllers.first as? ConfigureMenuTableViewController {
                configureMenuTableVC.soupMenuManager = soupMenuManager
                configureMenuTableVC.soupOrderDataManager = soupOrderManager
            }
        }
    }
}

