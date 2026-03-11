//
//  CharacterDetailBackgroundView.swift
//  MaCherie
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
                Color(uiColor: .systemGroupedBackground)

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
                Color(uiColor: .systemBackground).opacity(0.96),
                Color(uiColor: .systemBackground).opacity(0.82),
                Color(uiColor: .systemBackground).opacity(0.52)
            ]
        } else {
            [
                Color(uiColor: .systemBackground).opacity(0.88),
                Color(uiColor: .systemBackground).opacity(0.56),
                Color(uiColor: .systemBackground).opacity(0.18)
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
