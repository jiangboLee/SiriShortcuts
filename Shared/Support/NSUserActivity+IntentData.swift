//
//  NSUserActivity+IntentData.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/28.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation
import MobileCoreServices

#if canImport(CoreSpotlight)
    import CoreSpotlight
    import UIKit
#endif

extension NSUserActivity {
    
    public enum ActivityKeys: String {
        case orderID
    }
    
    public static let viewMenuActivityType = "com.ljb.SiriShortcuts.viewMenu"
    public static let orderCompleteActivityType = "com.ljb.SiriShortcuts.orderComplete"
    
    public static var viewMenuActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: NSUserActivity.viewMenuActivityType)
        
        //用户活动应尽可能丰富，并为适当的内容属性提供图标和本地化字符串。
        userActivity.title = "ACTIVITY下单"
        ///用于确定Siri将用户活动建议为用户的快捷方式。
        userActivity.isEligibleForPrediction = true
        
        #if canImport(CoreSpotlight)
        let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        ///用作搜索中的图标
        attributes.thumbnailData = UIImage(named: "tomato")?.pngData()
        attributes.keywords = ["李", "江", "波"]
        attributes.displayName = "CoreSpotlight下单"
        attributes.contentDescription = "搜到时的说明，lee好帅~"
        
        userActivity.contentAttributeSet = attributes
        #endif
        ///siri参考说明
        userActivity.suggestedInvocationPhrase = "lee好帅"
        return userActivity
    }
}
