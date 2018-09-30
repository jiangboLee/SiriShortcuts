//
//  InvoiceViewController.swift
//  SiriShortcutsIntentsUI
//
//  Created by Lee on 2018/9/30.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import SoupKit

class InvoiceViewController: UIViewController {

    private let intent: OrderSoupIntent
    
    @IBOutlet var invoiceView: InvoiceView!
    
    init(for soupIntent: OrderSoupIntent) {
        intent = soupIntent
        super.init(nibName: "InvoiceView", bundle: Bundle(for: InvoiceViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let order = Order(from: intent) {
            invoiceView.itemNameLabel.text = order.menuItem.itemName
            invoiceView.imageView.applyRoundedCorners()
            invoiceView.totalPriceLabel.text = order.localizedCurrencyValue
            invoiceView.unitPriceLabel.text = "\(order.quantity) @ \(order.menuItem.localizedCurrencyValue)"
            
            let intentImage = intent.image(forParameterNamed: \OrderSoupIntent.soup)
            intentImage?.fetchUIImage { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.invoiceView.imageView.image = image
                }
            }
            
            let flattenedOptions = order.menuItemOptions.map { (option) -> String in
                return option.rawValue
            }.joined(separator: ", ")
            
            invoiceView.optionsLabel.text = flattenedOptions
        }
    }
    

}

class InvoiceView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var unitPriceLabel: UILabel!
    @IBOutlet weak var optionsLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
}
