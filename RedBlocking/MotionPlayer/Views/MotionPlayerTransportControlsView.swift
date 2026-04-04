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

    let playerModel: MotionPlayerModel

    @Binding private var scrubbedFrame: Double
    @Binding private var isScrubbing: Bool
    @State private var showsSpeedControls = false

    private let frameNumberFormat = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3...))

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

            playbackCluster(playerModel: playerModel)

            speedControls(playerModel: playerModel)

            if playerModel.framesPerSecond == 0 {
                Text("Playback is paused at the current frame until you raise the speed again.")
                    .font(.footnote)
                    .foregroundStyle(Color.rbAmber.opacity(0.74))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if reduceMotion {
                Text("Reduce Motion is enabled, so continuous playback is paused. Use the frame slider or step controls to inspect the motion.")
                    .font(.footnote)
                    .foregroundStyle(Color.rbAmber.opacity(0.74))
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

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }

    private var transportButtonGrid: some View {
        HStack(spacing: 0) {
            stripButton(
                systemImage: "backward.frame.fill",
                accessibilityLabel: "Previous Frame",
                accessibilityHint: "Moves to the previous frame.",
                action: playerModel.stepBackward
            )

            transportSeparator

            stripButton(
                systemImage: playerModel.isPlaying ? "pause.fill" : "play.fill",
                accessibilityLabel: playerModel.isPlaying ? "Pause" : "Play",
                accessibilityHint: reduceMotion ? "Playback is unavailable while Reduce Motion is enabled." : "Plays or pauses the preview.",
                prominent: true,
                action: togglePlayback
            )

            transportSeparator

            stripButton(
                systemImage: "stop.fill",
                accessibilityLabel: "Stop",
                accessibilityHint: "Returns to the first frame.",
                action: playerModel.stop
            )

            transportSeparator

            stripButton(
                systemImage: "forward.frame.fill",
                accessibilityLabel: "Next Frame",
                accessibilityHint: "Moves to the next frame.",
                action: playerModel.stepForward
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .redBlockingControlSurface(cornerRadius: 20)
    }

    private var transportSeparator: some View {
        Rectangle()
            .fill(Color.rbPanelBorder.opacity(0.34))
            .frame(width: 1, height: dynamicTypeSize.isAccessibilitySize ? 44 : 36)
            .padding(.vertical, 2)
    }

    private func stripButton(
        systemImage: String,
        accessibilityLabel: String,
        accessibilityHint: String,
        prominent: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            transportButtonLabel(systemImage: systemImage, prominent: prominent)
        }
        .disabled(playerModel.totalFrames == 0 || (prominent && reduceMotion))
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .buttonStyle(RedBlockingPressableButtonStyle(pressedScale: 0.96, pressedOpacity: 0.92))
    }

    @ViewBuilder
    private func playbackCluster(playerModel: MotionPlayerModel) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("Frame Position")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.rbAmber.opacity(0.92))

                    Spacer(minLength: 12)

                    Text("\(formattedFrame(playerModel.currentFrameIndex)) / \(formattedFrame(playerModel.totalFrames))")
                        .font(.headline.monospacedDigit().weight(.semibold))
                        .foregroundStyle(.primary)
                }

                if playerModel.totalFrames > 1 {
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
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .redBlockingControlSurface(cornerRadius: 18, highlighted: true)

            transportButtonGrid
        }
    }

    @ViewBuilder
    private func speedControls(playerModel: MotionPlayerModel) -> some View {
        let framesPerSecond = Binding(
            get: { playerModel.framesPerSecond },
            set: { playerModel.framesPerSecond = $0 }
        )

        VStack(alignment: .leading, spacing: 12) {
            Button(action: { toggleSpeedControls() }) {
                HStack(spacing: 12) {
                    Text("Speed")
                        .redBlockingSectionTag()

                    Spacer(minLength: 12)

                    Text(speedSummary(for: playerModel))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.rbAmber.opacity(0.74))
                        .contentTransition(reduceMotion ? .identity : .numericText())

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.rbAmber.opacity(0.9))
                        .rotationEffect(.degrees(showsSpeedControls ? -180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .redBlockingControlSurface(cornerRadius: 18)
                .contentShape(Rectangle())
            }
            .buttonStyle(RedBlockingPressableButtonStyle())
            .accessibilityValue(showsSpeedControls ? "Expanded" : "Collapsed")
            .accessibilityHint(showsSpeedControls ? "Collapses the speed controls." : "Expands the speed controls.")

            if showsSpeedControls {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 12) {
                        Text("FPS")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.rbAmber.opacity(0.92))

                        Spacer()

                        TextField("Frames Per Second", value: framesPerSecond, format: .number)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                            .frame(minWidth: 84, maxWidth: 100)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .redBlockingControlSurface(cornerRadius: 14)

                        Stepper("Frames Per Second", value: framesPerSecond, in: PlaybackSettings.supportedFPSRange)
                            .labelsHidden()
                            .accessibilityLabel("Frames Per Second")
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .redBlockingControlSurface(cornerRadius: 18)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("FPS")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.rbAmber.opacity(0.92))

                        TextField("Frames Per Second", value: framesPerSecond, format: .number)
                            .textFieldStyle(.plain)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .redBlockingControlSurface(cornerRadius: 14)

                        Stepper("Frames Per Second", value: framesPerSecond, in: PlaybackSettings.supportedFPSRange)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .redBlockingControlSurface(cornerRadius: 18)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))
            }
        }
    }

    @ViewBuilder
    private func transportButtonLabel(systemImage: String, prominent: Bool) -> some View {
        let baseLabel = Image(systemName: systemImage)
            .font(.system(size: prominent ? 24 : 18, weight: .black, design: .rounded))
            .foregroundStyle(prominent ? Color.rbCoal : Color.rbAmber.opacity(0.96))
            .frame(maxWidth: .infinity)
            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 60 : 48)
            .background {
                if prominent {
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.rbGold.opacity(0.98),
                                    Color.rbAmber.opacity(0.96)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            Capsule(style: .continuous)
                                .strokeBorder(Color.rbGold.opacity(0.44), lineWidth: 1)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                }
            }
            .contentShape(Rectangle())

        if reduceMotion {
            baseLabel
        } else {
            baseLabel.contentTransition(.symbolEffect(.replace.offUp))
        }
    }

    private func toggleSpeedControls() {
        if reduceMotion {
            showsSpeedControls.toggle()
        } else {
            withAnimation(.snappy(duration: 0.26, extraBounce: 0)) {
                showsSpeedControls.toggle()
            }
        }
    }

    private func speedSummary(for playerModel: MotionPlayerModel) -> String {
        if playerModel.framesPerSecond == 0 {
            return "0 FPS"
        }

        return "\(playerModel.framesPerSecond) FPS"
    }
}
