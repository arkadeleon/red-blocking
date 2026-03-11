//
//  MotionPlayerPreviewCardView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerPreviewCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(AppModel.self) private var appModel

    let motionData: MotionPlaybackData
    let playerModel: MotionPlayerModel

    private let frameNumberFormat = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3...))

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    headerText
                    Spacer()
                    currentFrameLabel
                }

                VStack(alignment: .leading, spacing: 8) {
                    headerText
                    currentFrameLabel
                }
            }

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
                    description: Text("The motion data decoded successfully, but the current sprite frame is missing.")
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("\(motionData.frameCount) motion frames", systemImage: "film.stack")
                Label("\(motionData.spriteFrameCount) sprite frames", systemImage: "photo.stack")
                Label("\(motionData.characterCode) / \(motionData.skillCode)", systemImage: "shippingbox")

                if let previewSize = motionData.previewSize {
                    Label(
                        "\(Int(previewSize.width)) x \(Int(previewSize.height)) sprite size",
                        systemImage: "rectangle.expand.vertical"
                    )
                }

                if motionData.hasSpriteCountMismatch {
                    Text("Sprite frame count differs from motion data. Playback uses the best available image for each frame.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
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

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Motion Preview")
                .font(.headline)

            Text(playbackStateLabel(for: playerModel.state))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var currentFrameLabel: some View {
        Text("Frame \(formattedFrame(playerModel.currentFrameIndex))")
            .font(dynamicTypeSize.isAccessibilitySize ? .title3.monospacedDigit() : .headline.monospacedDigit())
            .foregroundStyle(.secondary)
    }
}
