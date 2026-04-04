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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let motionData: MotionPlaybackData
    let playerModel: MotionPlayerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerText

            if let currentFrame = playerModel.currentFrame {
                previewCanvas(for: currentFrame)
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
                    .redBlockingText(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .redBlockingControlSurface(cornerRadius: 16)
            }
        }
        .padding(16)
        .redBlockingPanel(cornerRadius: 22, elevated: true)
        .accessibilityElement(children: .contain)
    }

    private func previewCanvas(for currentFrame: MotionFrame) -> some View {
        MotionCanvasView(
            motionFrame: currentFrame,
            hitboxVisibilitySettings: appModel.settings.hitboxVisibility,
            hitboxColorSettings: appModel.settings.hitboxColors
        )
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Move Preview")
        .accessibilityValue(previewAccessibilityValue(for: currentFrame))
        .accessibilityHint(previewAccessibilityHint)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                playerModel.stepForward()
            case .decrement:
                playerModel.stepBackward()
            @unknown default:
                break
            }
        }
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

            playbackStateText
        }
    }

    @ViewBuilder
    private var playbackStateText: some View {
        let stateText = Text(playbackStateLabel(for: playerModel.state))
            .font(.subheadline.weight(.medium))
            .redBlockingText(.secondary)

        if reduceMotion {
            stateText
        } else {
            stateText
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.2), value: playerModel.state)
        }
    }

    private func previewAccessibilityValue(for currentFrame: MotionFrame) -> String {
        let frameSummary = "Frame \(currentFrame.index + 1) of \(motionData.frameCount)."
        let playbackSummary = "\(playbackStateLabel(for: playerModel.state))."
        let hitboxSummary = visibleHitboxSummary
        let mismatchSummary = motionData.hasSpriteCountMismatch
            ? "Some preview frames use the nearest available sprite."
            : nil

        return [playbackSummary, frameSummary, hitboxSummary, mismatchSummary]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    private var previewAccessibilityHint: String {
        if motionData.frameCount <= 1 {
            return "Playback controls appear below."
        }

        if reduceMotion {
            return "Swipe up or down with VoiceOver to inspect frames one at a time. Continuous playback is paused while Reduce Motion is enabled."
        }

        return "Swipe up or down with VoiceOver to move between frames. Playback controls and hitbox toggles appear below."
    }

    private var visibleHitboxSummary: String {
        let summaries = [
            playerHitboxSummary(title: "Player 1", visibleCount: player1VisibleHitboxCount),
            playerHitboxSummary(title: "Player 2", visibleCount: player2VisibleHitboxCount)
        ]

        return summaries.joined(separator: " ")
    }

    private func playerHitboxSummary(title: String, visibleCount: Int) -> String {
        switch visibleCount {
        case 0:
            return "\(title) hitboxes hidden."
        case 6:
            return "\(title) all hitbox layers visible."
        case 1:
            return "\(title) 1 hitbox layer visible."
        default:
            return "\(title) \(visibleCount) hitbox layers visible."
        }
    }

    private var player1VisibleHitboxCount: Int {
        countVisibleHitboxes(
            appModel.settings.hitboxVisibility.player1PassiveVisible,
            appModel.settings.hitboxVisibility.player1OtherVulnerabilityVisible,
            appModel.settings.hitboxVisibility.player1ActiveVisible,
            appModel.settings.hitboxVisibility.player1ThrowVisible,
            appModel.settings.hitboxVisibility.player1ThrowableVisible,
            appModel.settings.hitboxVisibility.player1PushVisible
        )
    }

    private var player2VisibleHitboxCount: Int {
        countVisibleHitboxes(
            appModel.settings.hitboxVisibility.player2PassiveVisible,
            appModel.settings.hitboxVisibility.player2OtherVulnerabilityVisible,
            appModel.settings.hitboxVisibility.player2ActiveVisible,
            appModel.settings.hitboxVisibility.player2ThrowVisible,
            appModel.settings.hitboxVisibility.player2ThrowableVisible,
            appModel.settings.hitboxVisibility.player2PushVisible
        )
    }

    private func countVisibleHitboxes(_ values: Bool...) -> Int {
        values.filter { $0 }.count
    }
}
