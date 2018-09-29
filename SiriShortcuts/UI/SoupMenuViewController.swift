//
//  SoupMenuViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import SoupKit

class SoupMenuViewController: UITableViewController {

    private static let cellReuseIdentifier = "SoupMenuItemDetailCell"
    
    private enum SegueIdentifiers: String {
        case newOrder = "soupMenuDetail"
    }
    
    private var menuItems: [MenuItem] = SoupMenuManager().availableItems
    
    override var userActivity: NSUserActivity? {
        didSet {
            ///如果从OrderSoupIntent过来就跳到下单页
            if userActivity?.activityType == NSStringFromClass(OrderSoupIntent.self) {
                performSegue(withIdentifier: SegueIdentifiers.newOrder.rawValue, sender: userActivity)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.newOrder.rawValue {
            guard let destination = segue.destination as? OrderDetailViewController else {return}
            
            var order: Order?
            if sender as? UITableViewCell? != nil,
                let indexPath = tableView.indexPathForSelectedRow {
                    order = Order(quantity: 1, menuItem: menuItems[indexPath.row], menuItemOptions: [])
            } else if let activity = sender as? NSUserActivity,
                let orderIntent = activity.interaction?.intent as? OrderSoupIntent {
                order = Order(from: orderIntent)
            }
            
            if let order = order {
                let orderType = OrderDetailConfiguration(orderType: .new)
                destination.configure(tableConfiguration: orderType, order: order)
            }
        }
    }

}
// MARK: - Table view data source
extension SoupMenuViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SoupMenuViewController.cellReuseIdentifier, for: indexPath)
        let menuItem = menuItems[indexPath.row]
        cell.imageView?.image = UIImage(named: menuItem.iconImageName)
        cell.imageView?.applyRoundedCorners()
        cell.textLabel?.text = menuItem.itemName
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
