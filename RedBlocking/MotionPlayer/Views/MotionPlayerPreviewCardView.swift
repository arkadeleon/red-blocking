//
//  MotionPlayerPreviewCardView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerPreviewCardView: View {
    @Environment(AppModel.self) private var appModel

    let motionData: MotionPlaybackData
    let playerModel: MotionPlayerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerText

            if let currentFrame = playerModel.currentFrame {
                MotionCanvasView(
                    motionFrame: currentFrame,
                    hitboxVisibilitySettings: appModel.settings.hitboxVisibility,
                    hitboxColorSettings: appModel.settings.hitboxColors
                )
                .frame(maxWidth: .infinity)
            } else {
                ContentUnavailableView(
                    "Preview Unavailable",
                    systemImage: "photo",
                    description: Text("The move loaded, but the current preview image is missing.")
                )
            }

            if motionData.hasSpriteCountMismatch {
                Label("Some frames are missing. The nearest available image is shown instead.", systemImage: "exclamationmark.triangle")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.rbAmber.opacity(0.92))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .redBlockingControlSurface(cornerRadius: 16)
            }
        }
        .padding(16)
        .redBlockingPanel(cornerRadius: 22, elevated: true)
        .accessibilityElement(children: .contain)
    }

    private func playbackStateLabel(for state: MotionPlayerModel.State) -> String {
        switch state {
        case .stopped:
            "Stopped"
        case .playing:
            "Playing"
        case .paused:
            "Paused"
        case .seeking:
            "Seeking"
        }
    }

    private var headerText: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Preview")
                .redBlockingSectionTag(prominent: true)

            Text(playbackStateLabel(for: playerModel.state))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.rbAmber.opacity(0.88))
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.2), value: playerModel.state)
        }
    }
}
