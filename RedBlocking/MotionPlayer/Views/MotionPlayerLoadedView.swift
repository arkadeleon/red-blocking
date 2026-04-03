//
//  MotionPlayerLoadedView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerLoadedView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                leadingColumn

                if usesTwoColumnLayout {
                    trailingColumn
                }
            }
            .padding(24)
            .frame(maxWidth: 1080, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .scrollIndicators(.hidden)
    }

    private var layout: AnyLayout {
        if usesTwoColumnLayout == false {
            AnyLayout(VStackLayout(spacing: 24))
        } else {
            AnyLayout(HStackLayout(alignment: .top, spacing: 28))
        }
    }

    private var usesTwoColumnLayout: Bool {
        horizontalSizeClass == .regular && dynamicTypeSize.isAccessibilitySize == false
    }

    private var leadingColumn: some View {
        VStack(spacing: 24) {
            MotionPlayerPreviewCardView(
                motionData: motionData,
                playerModel: playerModel
            )
            .frame(maxWidth: 560)

            MotionPlayerTransportControlsView(
                motionData: motionData,
                playerModel: playerModel,
                scrubbedFrame: $scrubbedFrame,
                isScrubbing: $isScrubbing
            )
            .frame(maxWidth: 560)

            if usesTwoColumnLayout == false {
                MotionPlayerHitboxControlsView()
            }
        }
        .frame(maxWidth: 560)
    }

    private var trailingColumn: some View {
        VStack(spacing: 18) {
            MotionPlayerHitboxControlsView()
        }
        .frame(maxWidth: 400)
    }
}
