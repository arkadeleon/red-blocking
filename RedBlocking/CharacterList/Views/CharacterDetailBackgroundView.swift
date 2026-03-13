//
//  CharacterDetailBackgroundView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterDetailBackgroundView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    let selection: CharacterSelection?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: imageAlignment) {
                LinearGradient(
                    colors: [
                        Color.rbCoal,
                        Color.rbBurgundy,
                        Color.rbCoal
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color.rbAmber.opacity(0.26),
                        Color.rbScarlet.opacity(0.12),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: min(proxy.size.width, proxy.size.height) * 0.88
                )
                .blendMode(.screen)

                if let selection {
                    LinearGradient(
                        colors: overlayColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )

                    Image(selection.backgroundAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(
                            maxWidth: proxy.size.width * imageWidthMultiplier,
                            maxHeight: max(proxy.size.height - topPadding, 0)
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: imageAlignment
                        )
                        .padding(.top, topPadding)
                        .padding(.horizontal, horizontalPadding)
                        .opacity(imageOpacity)
                        .accessibilityHidden(true)
                }
            }
            .ignoresSafeArea()
        }
    }

    private var imageAlignment: Alignment {
        horizontalSizeClass == .regular ? .trailing : .center
    }

    private var overlayColors: [Color] {
        if horizontalSizeClass == .compact {
            [
                Color.rbPanel.opacity(0.98),
                Color.rbPanelElevated.opacity(0.86),
                Color.rbCoal.opacity(0.58)
            ]
        } else {
            [
                Color.rbPanel.opacity(0.92),
                Color.rbPanelElevated.opacity(0.60),
                Color.rbCoal.opacity(0.18)
            ]
        }
    }

    private var imageWidthMultiplier: CGFloat {
        horizontalSizeClass == .regular ? 0.72 : 0.94
    }

    private var imageOpacity: Double {
        if horizontalSizeClass == .compact {
            return verticalSizeClass == .compact ? 0.22 : 0.28
        }

        return 0.72
    }

    private var topPadding: CGFloat {
        if horizontalSizeClass == .regular {
            return 44
        }

        return verticalSizeClass == .compact ? 8 : 20
    }

    private var horizontalPadding: CGFloat {
        horizontalSizeClass == .regular ? 24 : 12
    }
}
