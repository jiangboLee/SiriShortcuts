//
//  UIImageView+Extension.swift
//  SiriShortcuts
//
//  Created by Lee on 2018/9/28.
//  Copyright © 2018 Lee. All rights reserved.
//

import UIKit

extension UIImageView {
    public func applyRoundedCorners() {
        layer.cornerRadius = 8
        clipsToBounds = true
    }
}
