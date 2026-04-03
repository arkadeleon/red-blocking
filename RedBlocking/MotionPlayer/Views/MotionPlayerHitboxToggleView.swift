//
//  MotionPlayerHitboxToggleView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerHitboxToggleView: View {
    let title: String
    let symbolName: String
    let tintColor: Color

    @Binding private var isOn: Bool

    init(
        title: String,
        symbolName: String,
        tintColor: Color,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.symbolName = symbolName
        self.tintColor = tintColor
        _isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: symbolName)
                    .foregroundStyle(tintColor)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }
        }
        .tint(tintColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .redBlockingControlSurface(cornerRadius: 16, highlighted: isOn)
        .animation(.easeOut(duration: 0.18), value: isOn)
    }
}
