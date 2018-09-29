//
//  IntentHandler.swift
//  SiriShortcutsIntents
//
//  Created by LEE on 2018/9/28.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Intents
import SoupKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        
        guard intent is OrderSoupIntent else {
            fatalError("Unhandled intent type: \(intent)")
        }
        
        return OrderSoupIntentHandler()
    }
}
