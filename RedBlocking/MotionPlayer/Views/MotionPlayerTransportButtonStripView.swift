//
//  MotionPlayerTransportButtonStripView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/4/4.
//

import SwiftUI

struct MotionPlayerTransportButtonStripView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let isPlaying: Bool
    let totalFrames: Int
    let reduceMotionEnabled: Bool
    let onStepBackward: () -> Void
    let onTogglePlayback: () -> Void
    let onStop: () -> Void
    let onStepForward: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            MotionPlayerTransportButtonView(
                systemImage: "backward.frame.fill",
                accessibilityLabel: "Previous Frame",
                accessibilityHint: "Moves to the previous frame.",
                prominent: false,
                isDisabled: totalFrames == 0,
                action: onStepBackward
            )

            separator

            MotionPlayerTransportButtonView(
                systemImage: isPlaying ? "pause.fill" : "play.fill",
                accessibilityLabel: isPlaying ? "Pause" : "Play",
                accessibilityHint: reduceMotionEnabled
                    ? "Playback is unavailable while Reduce Motion is enabled."
                    : "Plays or pauses the preview.",
                prominent: true,
                isDisabled: totalFrames == 0 || reduceMotionEnabled,
                action: onTogglePlayback
            )

            separator

            MotionPlayerTransportButtonView(
                systemImage: "stop.fill",
                accessibilityLabel: "Stop",
                accessibilityHint: "Returns to the first frame.",
                prominent: false,
                isDisabled: totalFrames == 0,
                action: onStop
            )

            separator

            MotionPlayerTransportButtonView(
                systemImage: "forward.frame.fill",
                accessibilityLabel: "Next Frame",
                accessibilityHint: "Moves to the next frame.",
                prominent: false,
                isDisabled: totalFrames == 0,
                action: onStepForward
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .redBlockingControlSurface(cornerRadius: 20)
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.rbPanelBorder.opacity(0.34))
            .frame(width: 1, height: dynamicTypeSize.isAccessibilitySize ? 44 : 36)
            .padding(.vertical, 2)
    }
}

#Preview("Motion Player Transport Button Strip") {
    MotionPlayerTransportButtonStripView(
        isPlaying: true,
        totalFrames: 42,
        reduceMotionEnabled: false,
        onStepBackward: {},
        onTogglePlayback: {},
        onStop: {},
        onStepForward: {}
    )
    .padding()
    .background(Color.rbCoal)
}
