//
//  IntentViewController.swift
//  SiriShortcutsIntentsUI
//
//  Created by LEE on 2018/9/28.
//  Copyright © 2018年 Lee. All rights reserved.
//

import IntentsUI
import SoupKit

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    
    // 准备视图控制器以进行交互处理
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // 在此处进行配置，包括准备视图和计算所需的演示文稿大小
        
        guard let intent = interaction.intent as? OrderSoupIntent else {
            completion(false, Set(), .zero)
            return
        }
        //可以显示不同的UI，这取决于意图是在确认阶段还是处理阶段。此示例使用视图控制器包含来通过专用视图控制器管理每个不同的视图
        if interaction.intentHandlingStatus == .ready {
            let invoiceVC = InvoiceViewController(for: intent)
            attachChild(invoiceVC)
            completion(true, parameters, desiredSize)
        } else if interaction.intentHandlingStatus == .success {
            if let response = interaction.intentResponse as? OrderSoupIntentResponse {
                let confirmedVC = OrderConfirmedViewController(for: intent, with: response)
                attachChild(confirmedVC)
                completion(true, parameters, desiredSize)
            }
        }
        completion(false, parameters, .zero)
    }
    
    /// UI尺寸
    var desiredSize: CGSize {
        let width = self.extensionContext!.hostedViewMaximumAllowedSize.width
        
        return CGSize(width: width, height: 170)
    }
    
    private func attachChild(_ viewController: UIViewController) {
        addChild(viewController)
        
        if let subview = viewController.view {
            view.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
            
            // Set the child controller's view to be the exact same size as the parent controller's view.
            subview.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            subview.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            
            subview.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            subview.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        
        viewController.didMove(toParent: self)
    }
}
