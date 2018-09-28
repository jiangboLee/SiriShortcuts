//
//  SoupMenuViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

class SoupMenuViewController: UITableViewController {

    private static let cellReuseIdentifier = "SoupMenuItemDetailCell"
    
    private var menuItems: [MenuItem] = SoupMenuManager().availableItems
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
