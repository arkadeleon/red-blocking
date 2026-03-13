//
//  CharacterRosterBackgroundView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterRosterBackgroundView: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.rbGold,
                        Color.rbAmber,
                        Color.rbEmber,
                        Color.rbCoal
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color.rbGold.opacity(0.55),
                        Color.rbAmber.opacity(0.22),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: min(proxy.size.width, proxy.size.height) * 0.92
                )
                .blendMode(.screen)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.rbScarlet.opacity(0.0),
                                Color.rbBurgundy.opacity(0.32)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.black.opacity(0.18),
                                Color.rbCoal.opacity(0.50)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.rbAmber.opacity(0.14),
                                Color.black.opacity(0.05),
                                Color.black.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: proxy.size.width * 0.52)
                    .rotationEffect(.degrees(-14))
                    .offset(x: proxy.size.width * 0.09, y: -proxy.size.height * 0.08)
                    .blur(radius: 10)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    CharacterRosterBackgroundView()
}
