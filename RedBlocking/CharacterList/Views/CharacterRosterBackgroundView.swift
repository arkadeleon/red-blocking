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
                        Color(red: 0.98, green: 0.77, blue: 0.07),
                        Color(red: 0.76, green: 0.31, blue: 0.02),
                        Color(red: 0.26, green: 0.07, blue: 0.01),
                        Color(red: 0.10, green: 0.02, blue: 0.00)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color(red: 1.00, green: 0.89, blue: 0.39).opacity(0.55),
                        Color(red: 1.00, green: 0.56, blue: 0.08).opacity(0.22),
                        .clear
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
                                Color(red: 0.49, green: 0.17, blue: 0.00).opacity(0.0),
                                Color(red: 0.16, green: 0.03, blue: 0.00).opacity(0.32)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                Color.black.opacity(0.18),
                                Color(red: 0.11, green: 0.02, blue: 0.00).opacity(0.50)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.14),
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
