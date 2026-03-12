//
//  Color+Integer.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

extension Color {
    init(rgb: Int, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((rgb & 0xFF0000) >> 16) / 0xFF,
            green: Double((rgb & 0x00FF00) >> 8) / 0xFF,
            blue: Double(rgb & 0x0000FF) / 0xFF,
            opacity: alpha
        )
    }
}
