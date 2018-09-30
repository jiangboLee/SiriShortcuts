//
//  OrderHistoryTableViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import SoupKit

class OrderHistoryTableViewController: UITableViewController {

    private static let cellReuseIdentifier = "SoupOrderDtailCell"
    
    private enum SegueIdentifiers: String {
        case orderDetail = "OrderDetails"
        case soupMenu = "SoupMenu"
        case configureMenu = "ConfigureMenu"
    }
    
    private let soupMenuManager = SoupMenuManager()
    private let soupOrderManager = SoupOrderDataManager()
    private var notificationToken: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationToken = NotificationCenter.default.addObserver(forName: dataChangedNotificationKey, object: soupOrderManager, queue: OperationQueue.main) { [weak self] (_) in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    //MARK: - target Action
    /// 用于返回此控制器
    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {
        
    }
    @IBAction func placeNewOrder(segue: UIStoryboardSegue) {
        if let source = segue.source as? OrderDetailViewController {
            soupOrderManager.placeOrder(order: source.order)
        }
    }

    //MARK: - Nacigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.orderDetail.rawValue {
            var order: Order? = nil
            
            if sender as? UITableViewCell != nil,
            let selectdIndexPaths = tableView.indexPathsForSelectedRows,
                let selectedIndexPath = selectdIndexPaths.first {
                order = soupOrderManager.orderHistory[selectedIndexPath.row]
            } else if let activity = sender as? NSUserActivity,
                let orderID = activity.userInfo?[NSUserActivity.ActivityKeys.orderID.rawValue] as? UUID {
                
                order = soupOrderManager.order(matching: orderID)
            }
           
            if let destination = segue.destination as? OrderDetailViewController, let order = order {
                destination.configure(tableConfiguration: OrderDetailConfiguration(orderType: .historical), order: order)
            }
            
        } else if segue.identifier == SegueIdentifiers.soupMenu.rawValue {
            if let navController = segue.destination as? UINavigationController,
                let soupMenuVC = navController.viewControllers.first as? SoupMenuViewController {
                if let activity = sender as? NSUserActivity, activity.activityType == NSStringFromClass(OrderSoupIntent.self) {
                    soupMenuVC.userActivity = activity
                } else {
                    soupMenuVC.userActivity = NSUserActivity.viewMenuActivity
                }
            }
        } else if segue.identifier == SegueIdentifiers.configureMenu.rawValue {
            if let navController = segue.destination as? UINavigationController,
               let configureMenuTableVC = navController.viewControllers.first as? ConfigureMenuTableViewController {
                configureMenuTableVC.soupMenuManager = soupMenuManager
                configureMenuTableVC.soupOrderDataManager = soupOrderManager
            }
        }
    }
    ///当通过恢复处理程序继续用户活动时，将调用此方法
    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
        
        if activity.activityType == NSUserActivity.viewMenuActivityType {
            driveContinueActivitySegue(SegueIdentifiers.soupMenu.rawValue, sender: nil)
        } else if activity.activityType == NSStringFromClass(OrderSoupIntent.self) {
            //订单未完成，允许订单自定义
            driveContinueActivitySegue(SegueIdentifiers.soupMenu.rawValue, sender: activity)
        } else if activity.activityType == NSUserActivity.orderCompleteActivityType, activity.userInfo?[NSUserActivity.ActivityKeys.orderID.rawValue] as? UUID != nil {
            //订单完成
            driveContinueActivitySegue(SegueIdentifiers.orderDetail.rawValue, sender: activity)
        }
    }
    
    ///通过弹出推送的订单历史记录确保此视图控制器可见，并在启动segue之前解除以模态方式呈现的任何内容。
    private func driveContinueActivitySegue(_ segueID: String, sender: Any?) {
        ///封装跳转
        let encapsulatedSegue = {
            self.performSegue(withIdentifier: segueID, sender: sender)
        }
        
        navigationController?.popToRootViewController(animated: false)
        if presentedViewController != nil {
            dismiss(animated: false) {
                encapsulatedSegue()
            }
        } else {
            encapsulatedSegue()
        }
    }
}

extension OrderHistoryTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soupOrderManager.orderHistory.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OrderHistoryTableViewController.cellReuseIdentifier, for: indexPath)
        let order = soupOrderManager.orderHistory[indexPath.row]
        cell.imageView?.image = UIImage(named: order.menuItem.iconImageName)
        cell.imageView?.applyRoundedCorners()
        
        cell.textLabel?.text = "\(order.quantity) \(order.menuItem.itemName)"
        cell.detailTextLabel?.text = dateFormatter.string(from: order.date)
        return cell
    }
}
