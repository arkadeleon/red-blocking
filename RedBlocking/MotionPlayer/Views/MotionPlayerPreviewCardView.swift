//
//  MotionPlayerPreviewCardView.swift
//  RedBlocking
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
        VStack(alignment: .leading, spacing: 18) {
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
                    description: Text("The move loaded, but the current preview image is missing.")
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                metadataRow("\(motionData.frameCount) motion frames", systemImage: "film.stack")
                metadataRow("\(motionData.spriteFrameCount) sprite frames", systemImage: "photo.stack")
                metadataRow("\(motionData.characterCode) / \(motionData.skillCode)", systemImage: "shippingbox")

                if let previewSize = motionData.previewSize {
                    metadataRow(
                        "\(Int(previewSize.width)) x \(Int(previewSize.height)) sprite size",
                        systemImage: "rectangle.expand.vertical"
                    )
                }

                if motionData.hasSpriteCountMismatch {
                    Text("Some preview frames are missing, so the closest available image is used.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(22)
        .redBlockingPanel(cornerRadius: 28, elevated: true)
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
                .redBlockingSectionTag(prominent: true)

            Text(playbackStateLabel(for: playerModel.state))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.rbAmber.opacity(0.88))
        }
    }

    private var currentFrameLabel: some View {
        Text("Frame \(formattedFrame(playerModel.currentFrameIndex))")
            .font(dynamicTypeSize.isAccessibilitySize ? .title3.monospacedDigit() : .headline.monospacedDigit())
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .redBlockingControlSurface(cornerRadius: 18, highlighted: true)
    }

    private func metadataRow(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .redBlockingControlSurface(cornerRadius: 16)
    }
}
