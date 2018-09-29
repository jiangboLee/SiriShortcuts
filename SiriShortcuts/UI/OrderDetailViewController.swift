//
//  OrderDetailViewController.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/27.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import os
import IntentsUI
import SoupKit

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
    
    /// 添加siri按钮
    private func configureTableViewFooter() {
        
        if tableConfiguration.orderType == .historical {
            let addShortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
            addShortcutButton.shortcut = INShortcut(intent: order.intent)
            addShortcutButton.delegate = self
            
            addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
            tableViewFooter.addSubview(addShortcutButton)
            tableViewFooter.centerXAnchor.constraint(equalTo: addShortcutButton.centerXAnchor).isActive = true
            tableViewFooter.centerYAnchor.constraint(equalTo: addShortcutButton.centerYAnchor).isActive = true
            
            tableView.tableFooterView = tableViewFooter
        }
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

// MARK: - INUIAddVoiceShortcutButtonDelegate 这些代理都很简单明白
extension OrderDetailViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

// MARK: - 增加sirid控制器代理
extension OrderDetailViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - INUIEditVoiceShortcutViewControllerDelegate  编辑siri代理
extension OrderDetailViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

class QuantityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
}
