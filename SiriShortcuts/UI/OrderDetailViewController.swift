//
//  OrderDetailViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import os

class OrderDetailViewController: UITableViewController {

    private(set) var order: Order!
    
    private var tableConfiguration: OrderDetailConfiguration = OrderDetailConfiguration(orderType: .new)
    
    private weak var quantityLabel: UILabel?
    
    private weak var totalLabel: UILabel?
    
    private var optionMap: [String: String] = [:]
    
    @IBOutlet var tableViewHeader: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet var tableViewFooter: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if tableConfiguration.orderType == .historical {
            navigationItem.rightBarButtonItem = nil
        }
        configureTableViewHeader()
        configureTableViewFooter()
    }

    private func configureTableViewHeader() {
        headerImageView.image = UIImage(named: order.menuItem.iconImageName)
        headerImageView.applyRoundedCorners()
        headerLabel.text = order.menuItem.itemName
        tableView.tableHeaderView = tableViewHeader
    }
    
    private func configureTableViewFooter() {
        
    }
    
    func configure(tableConfiguration: OrderDetailConfiguration, order: Order) {
        self.tableConfiguration = tableConfiguration
        self.order = order
    }
    
    
    @IBAction func placeOrder(_ sender: UIBarButtonItem) {
        
        if order.quantity == 0 {
            os_log("数量必须大于0")
            return
        }
        performSegue(withIdentifier: "dismissPlaceOrder", sender: self)
    }
    
    @objc private func stepperDidChange(_ sender: UIStepper) {
        order.quantity = Int(sender.value)
        quantityLabel?.text = "\(order.quantity)"
        updateTotalLabel()
    }
    
    private func updateTotalLabel() {
        totalLabel?.text = order.localizedCurrencyValue
    }
}
// MARK: - Table view data source
extension OrderDetailViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableConfiguration.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableConfiguration.sections[section].rowCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableConfiguration.sections[section].type.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = tableConfiguration.sections[indexPath.section]
        let reuseIdentifier = sectionModel.cellReuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        configure(cell: cell, at: indexPath, with: sectionModel)
        return cell
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath, with sectionModel: OrderDetailConfiguration.SectionModel) {
        switch sectionModel.type {
        case .price:
            cell.textLabel?.text = NumberFormatter.currencyFormatter.string(from: order.menuItem.price as NSDecimalNumber)
        case .quantity:
            if let cell = cell as? QuantityTableViewCell {
                if tableConfiguration.orderType == .new {
                    quantityLabel = cell.quantityLabel
                    cell.stepper.addTarget(self, action: #selector(stepperDidChange(_:)), for: .valueChanged)
                } else {
                    cell.quantityLabel.text = "\(order.quantity)"
                    cell.stepper.isHidden = true
                }
            }
        case .options:
            let option = Order.MenuItemOption.all[indexPath.row]
            let localizedValue = option.rawValue
            optionMap[localizedValue] = option.rawValue
            
            cell.textLabel?.text = localizedValue
            cell.accessoryType = order.menuItemOptions.contains(option) ? .checkmark : .none
        case .total:
            totalLabel = cell.textLabel
            updateTotalLabel()
        }
    }
}

extension OrderDetailViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableConfiguration.sections[indexPath.section].type == .options && tableConfiguration.orderType == .new {
            guard let cell = tableView.cellForRow(at: indexPath),
                let cellText = cell.textLabel?.text,
                let optionRawValue = optionMap[cellText],
                let option = Order.MenuItemOption(rawValue: optionRawValue) else {return}
            
            if order.menuItemOptions.contains(option) {
                order.menuItemOptions.remove(option)
                cell.accessoryType = .none
            } else {
                order.menuItemOptions.insert(option)
                cell.accessoryType = .checkmark
            }
        }
    }
}


class QuantityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
}
