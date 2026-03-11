//
//  MotionPlayerLoadedView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerLoadedView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let motionData: MotionPlaybackData
    let playerModel: MotionPlayerModel

    @Binding private var scrubbedFrame: Double
    @Binding private var isScrubbing: Bool

    init(
        motionData: MotionPlaybackData,
        playerModel: MotionPlayerModel,
        scrubbedFrame: Binding<Double>,
        isScrubbing: Binding<Bool>
    ) {
        self.motionData = motionData
        self.playerModel = playerModel
        _scrubbedFrame = scrubbedFrame
        _isScrubbing = isScrubbing
    }

    var body: some View {
        ScrollView {
            layout {
                MotionPlayerPreviewCardView(
                    motionData: motionData,
                    playerModel: playerModel
                )
                .frame(maxWidth: 520)

                VStack(spacing: 20) {
                    MotionPlayerTransportControlsView(
                        motionData: motionData,
                        playerModel: playerModel,
                        scrubbedFrame: $scrubbedFrame,
                        isScrubbing: $isScrubbing
                    )

                    MotionPlayerHitboxControlsView()
                }
                .frame(maxWidth: 380)
            }
            .padding(24)
            .frame(maxWidth: 1040, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .scrollIndicators(.hidden)
    }

    private var layout: AnyLayout {
        if horizontalSizeClass == .compact {
            AnyLayout(VStackLayout(spacing: 20))
        } else {
            AnyLayout(HStackLayout(alignment: .top, spacing: 24))
        }
    }
}
