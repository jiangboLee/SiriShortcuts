//
//  NumberFormatter+Currency.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/28.
//  Copyright © 2018 Lee. All rights reserved.
//

import Foundation

extension NumberFormatter {
    public static var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
}
