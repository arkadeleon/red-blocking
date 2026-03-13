//
//  CharacterRosterGillSlotView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterRosterGillSlotView: View {
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.rbCoal)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.rbGold,
                            Color.rbAmber,
                            Color.rbCobalt
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(diameter * 0.13)
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: diameter * 0.018)
                        .padding(diameter * 0.13)
                }

            Circle()
                .strokeBorder(Color.rbPanelBorder.opacity(0.62), lineWidth: diameter * 0.035)
                .padding(diameter * 0.06)

            Image(systemName: "lock.fill")
                .font(.system(size: diameter * 0.26, weight: .black, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.94))
                .shadow(color: Color.black.opacity(0.35), radius: diameter * 0.03, x: 0, y: diameter * 0.02)
        }
        .frame(width: diameter, height: diameter)
        .opacity(0.94)
        .accessibilityHidden(true)
    }
}
