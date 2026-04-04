//
//  MotionPlayerHitboxToggleView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerHitboxToggleView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let description: String
    let symbolName: String
    let tintColor: Color

    @Binding private var isOn: Bool

    init(
        title: String,
        description: String,
        symbolName: String,
        tintColor: Color,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.description = description
        self.symbolName = symbolName
        self.tintColor = tintColor
        _isOn = isOn
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isOn)
    }
}
