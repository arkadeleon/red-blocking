//
//  MotionPlayerTransportControlsView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerTransportControlsView: View {
    let motionData: MotionPlaybackData
    let playerModel: MotionPlayerModel

    @Binding private var scrubbedFrame: Double
    @Binding private var isScrubbing: Bool

    private let frameNumberFormat = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3...))

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
        @Bindable var playerModel = playerModel

        VStack(alignment: .leading, spacing: 18) {
            Text("Playback")
                .font(.headline)

            LabeledContent(
                "Frame",
                value: "\(formattedFrame(playerModel.currentFrameIndex)) / \(formattedFrame(motionData.frameCount))"
            )
            .font(.body.monospacedDigit())

            if playerModel.totalFrames > 1 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frame Position")
                        .font(.subheadline.weight(.medium))

                    Slider(
                        value: $scrubbedFrame,
                        in: 0...Double(playerModel.totalFrames - 1),
                        step: 1,
                        onEditingChanged: handleScrubbingChange
                    )
                    .accessibilityLabel("Frame Position")
                    .onChange(of: scrubbedFrame) { _, newValue in
                        guard isScrubbing else {
                            return
                        }

                        playerModel.seek(to: Int(newValue))
                    }

                    HStack {
                        Text(formattedFrame(0))
                        Spacer()
                        Text(formattedFrame(playerModel.totalFrames - 1))
                    }
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button("Previous Frame", systemImage: "backward.frame", action: playerModel.stepBackward)
                    .disabled(playerModel.totalFrames == 0)

                Button(
                    playerModel.isPlaying ? "Pause" : "Play",
                    systemImage: playerModel.isPlaying ? "pause.circle" : "play.circle",
                    action: togglePlayback
                )
                .disabled(playerModel.totalFrames == 0)

                Button("Stop", systemImage: "stop.circle", action: playerModel.stop)
                    .disabled(playerModel.totalFrames == 0)

                Button("Next Frame", systemImage: "forward.frame", action: playerModel.stepForward)
                    .disabled(playerModel.totalFrames == 0)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderedProminent)
            .accessibilityElement(children: .contain)

            HStack(spacing: 12) {
                Text("FPS")
                    .font(.subheadline.weight(.medium))

                Spacer()

                TextField("Frames Per Second", value: $playerModel.framesPerSecond, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 84)
                    .keyboardType(.numberPad)

                Stepper("Frames Per Second", value: $playerModel.framesPerSecond, in: PlaybackSettings.supportedFPSRange)
                    .labelsHidden()
            }

            if playerModel.framesPerSecond == 0 {
                Text("0 FPS freezes the preview on the current frame until the speed is raised again.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func togglePlayback() {
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

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }
}
