//
//  UIColor+Integer.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: Int, alpha: CGFloat) {
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 0xFF
        let blue = CGFloat(rgb & 0x0000FF) / 0xFF
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
