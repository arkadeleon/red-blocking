//
//  MotionPlayerContentView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerContentView: View {
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
            LazyVStack(spacing: 24) {
                MotionPlayerPreviewCardView(
                    motionData: motionData,
                    playerModel: playerModel
                )

                MotionPlayerTransportControlsView(
                    playerModel: playerModel,
                    scrubbedFrame: $scrubbedFrame,
                    isScrubbing: $isScrubbing
                )

                MotionPlayerHitboxControlsView()
            }
        }
        .scrollIndicators(.hidden)
        .contentMargins(.top, 20, for: .scrollContent)
        .contentMargins(.horizontal, horizontalContentMargin, for: .scrollContent)
        .contentMargins(.bottom, 28, for: .scrollContent)
        .task(id: "\(motionData.characterCode)-\(motionData.skillCode)") {
            await motionData.prepareAllFrames()
        }
    }

    private var horizontalContentMargin: CGFloat {
        horizontalSizeClass == .regular ? 24 : 16
    }
}

#Preview("Motion Player Content") {
    @Previewable @State var scrubbedFrame = 0.0
    @Previewable @State var isScrubbing = false

    if let preview = PreviewAppModel.motionPlayerLoaded() {
        MotionPlayerContentView(
            motionData: preview.motionData,
            playerModel: preview.playerModel,
            scrubbedFrame: $scrubbedFrame,
            isScrubbing: $isScrubbing
        )
        .environment(preview.appModel)
    } else {
        ContentUnavailableView(
            "Preview Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text("No motion preview data is available.")
        )
    }
}
