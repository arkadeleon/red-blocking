//
//  MotionPlayerTransportControlsView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerTransportControlsView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                    .accessibilityValue("Frame \(formattedFrame(playerModel.currentFrameIndex)) of \(formattedFrame(playerModel.totalFrames))")
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

            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    transportButtonGrid
                        .labelStyle(.titleAndIcon)
                } else {
                    transportButtonGrid
                        .labelStyle(.iconOnly)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    Text("FPS")
                        .font(.subheadline.weight(.medium))

                    Spacer()

                    TextField("Frames Per Second", value: $playerModel.framesPerSecond, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(minWidth: 84, maxWidth: 100)
                        .keyboardType(.numberPad)

                    Stepper("Frames Per Second", value: $playerModel.framesPerSecond, in: PlaybackSettings.supportedFPSRange)
                        .labelsHidden()
                        .accessibilityLabel("Frames Per Second")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("FPS")
                        .font(.subheadline.weight(.medium))

                    TextField("Frames Per Second", value: $playerModel.framesPerSecond, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)

                    Stepper("Frames Per Second", value: $playerModel.framesPerSecond, in: PlaybackSettings.supportedFPSRange)
                }
            }

            if playerModel.framesPerSecond == 0 {
                Text("0 FPS keeps the preview on the current frame until you increase the speed again.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if reduceMotion {
                Text("Reduce Motion is enabled, so continuous playback is paused. Use the frame slider or step controls to inspect the motion.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
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

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }

    private var transportColumns: [GridItem] {
        let count = dynamicTypeSize.isAccessibilitySize ? 1 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 12), count: count)
    }

    private var transportButtonGrid: some View {
        LazyVGrid(columns: transportColumns, alignment: .leading, spacing: 12) {
            Button("Previous Frame", systemImage: "backward.frame", action: playerModel.stepBackward)
                .disabled(playerModel.totalFrames == 0)
                .frame(maxWidth: .infinity, minHeight: 44)

            Button(
                playerModel.isPlaying ? "Pause" : "Play",
                systemImage: playerModel.isPlaying ? "pause.circle" : "play.circle",
                action: togglePlayback
            )
            .disabled(playerModel.totalFrames == 0 || reduceMotion)
            .accessibilityHint(reduceMotion ? "Playback is unavailable while Reduce Motion is enabled." : "Plays or pauses the preview.")
            .frame(maxWidth: .infinity, minHeight: 44)
            .buttonStyle(.borderedProminent)

            Button("Stop", systemImage: "stop.circle", action: playerModel.stop)
                .disabled(playerModel.totalFrames == 0)
                .frame(maxWidth: .infinity, minHeight: 44)

            Button("Next Frame", systemImage: "forward.frame", action: playerModel.stepForward)
                .disabled(playerModel.totalFrames == 0)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
    }
}
