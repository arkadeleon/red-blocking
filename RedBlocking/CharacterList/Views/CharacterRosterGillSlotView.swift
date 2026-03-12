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
                .fill(Color.black.opacity(0.96))

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.78, blue: 0.16),
                            Color(red: 0.92, green: 0.37, blue: 0.10),
                            Color(red: 0.35, green: 0.54, blue: 0.92)
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
                .strokeBorder(Color.black.opacity(0.72), lineWidth: diameter * 0.035)
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
