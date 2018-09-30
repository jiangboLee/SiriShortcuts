//
//  OrderConfirmedViewController.swift
//  SiriShortcutsIntentsUI
//
//  Created by Lee on 2018/9/30.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit
import SoupKit

class OrderConfirmedViewController: UIViewController {

    private let intent: OrderSoupIntent
    private let intentResponse: OrderSoupIntentResponse
    
    @IBOutlet var confirmationView: OrderConfirmedView!
    
    init(for soupIntent: OrderSoupIntent, with response: OrderSoupIntentResponse) {
        intent = soupIntent
        intentResponse = response
        super.init(nibName: "OrderConfirmedView", bundle: Bundle(for: OrderConfirmedViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let order = Order(from: intent) {
            confirmationView.itemNameLabel.text = order.menuItem.itemName
            confirmationView.imageView.applyRoundedCorners()
            if let waitTime = intentResponse.waitTime {
                confirmationView.timeLabel.text = waitTime
            }
            
            let intentImage = intent.image(forParameterNamed: \OrderSoupIntent.soup)
            intentImage?.fetchUIImage { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.confirmationView.imageView.image = image
                }
            }
        }
    }
}

class OrderConfirmedView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
