//
//  Localizable.swift
//  SiriShortcuts
//
//  Created by LEE on 2018/9/27.
//  Copyright © 2018年 Lee. All rights reserved.
//

import Foundation


/// 具有本地化字符串的类型，该字符串将为快捷方式加载适当的本地化值。
protocol LocalizableShortcutString {
    
    /// 返回：本地化值的字符串键
    var shortcutLocalizationKey: String { get }
}

/// 具有适合在UI中显示的本地化货币字符串的类型。
protocol LocalizableCurrency {
    
    /// 返回：显示区域设置敏感货币格式的字符串。
    var localizedCurrencyValue: String { get }
}
