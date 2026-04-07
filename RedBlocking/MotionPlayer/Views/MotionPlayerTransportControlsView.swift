//
//  MotionPlayerTransportControlsView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerTransportControlsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let playerModel: MotionPlayerModel

    @Binding private var scrubbedFrame: Double
    @Binding private var isScrubbing: Bool

    init(
        playerModel: MotionPlayerModel,
        scrubbedFrame: Binding<Double>,
        isScrubbing: Binding<Bool>
    ) {
        self.playerModel = playerModel
        _scrubbedFrame = scrubbedFrame
        _isScrubbing = isScrubbing
    }

    var body: some View {
        @Bindable var playerModel = playerModel

        VStack(alignment: .leading, spacing: 16) {
            Text("Playback")
                .redBlockingSectionTag(prominent: true)

            MotionPlayerFrameScrubberView(
                currentFrameIndex: playerModel.currentFrameIndex,
                totalFrames: playerModel.totalFrames,
                scrubbedFrame: $scrubbedFrame,
                isScrubbing: $isScrubbing,
                onScrubbingChanged: handleScrubbingChange,
                onSeek: { playerModel.seek(to: $0) }
            )

            MotionPlayerTransportButtonStripView(
                isPlaying: playerModel.isPlaying,
                totalFrames: playerModel.totalFrames,
                reduceMotionEnabled: reduceMotion,
                onStepBackward: playerModel.stepBackward,
                onTogglePlayback: togglePlayback,
                onStop: playerModel.stop,
                onStepForward: playerModel.stepForward
            )

            MotionPlayerSpeedControlsView(framesPerSecond: $playerModel.framesPerSecond)

            if playerModel.framesPerSecond == 0 {
                Text("Playback is paused at the current frame until you raise the speed again.")
                    .font(.footnote)
                    .redBlockingText(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if reduceMotion {
                Text("Reduce Motion is enabled, so continuous playback is paused. Use the frame slider or step controls to inspect the motion.")
                    .font(.footnote)
                    .redBlockingText(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .redBlockingPanel(cornerRadius: 22)
    }

    private func togglePlayback() {
        guard reduceMotion == false else {
            playerModel.pause()
            return
        }

        if playerModel.isPlaying {
            playerModel.pause()
        } else {
            playerModel.play()
        }
    }

    private func handleScrubbingChange(_ isEditing: Bool) {
        isScrubbing = isEditing

        if isEditing {
            playerModel.beginSeeking()
            playerModel.seek(to: Int(scrubbedFrame))
        } else {
            playerModel.seek(to: Int(scrubbedFrame))
            playerModel.endSeeking()
        }
    }
}

#Preview("Motion Player Transport Controls") {
    @Previewable @State var scrubbedFrame = 0.0
    @Previewable @State var isScrubbing = false

    if let preview = PreviewAppModel.motionPlayerLoaded() {
        MotionPlayerTransportControlsView(
            playerModel: preview.playerModel,
            scrubbedFrame: $scrubbedFrame,
            isScrubbing: $isScrubbing
        )
        .padding()
        .background(Color.rbCoal)
    } else {
        ContentUnavailableView(
            "Preview Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text("No motion preview data is available.")
        )
    }
}
