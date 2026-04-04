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

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }

    private func displayedFrameNumber(_ frameIndex: Int, totalFrames: Int) -> Int {
        guard totalFrames > 0 else {
            return 0
        }

        return min(max(frameIndex + 1, 1), totalFrames)
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
                        .redBlockingText(.secondary)

                    Spacer(minLength: 12)

                    Text(
                        "\(formattedFrame(displayedFrameNumber(playerModel.currentFrameIndex, totalFrames: playerModel.totalFrames))) / \(formattedFrame(playerModel.totalFrames))"
                    )
                    .font(.headline.monospacedDigit().weight(.semibold))
                    .redBlockingText(.primary)
                }

                if playerModel.totalFrames > 1 {
                    Slider(
                        value: $scrubbedFrame,
                        in: 0...Double(playerModel.totalFrames - 1),
                        step: 1,
                        onEditingChanged: handleScrubbingChange
                    )
                    .accessibilityLabel("Frame Position")
                    .accessibilityValue(
                        "Frame \(formattedFrame(displayedFrameNumber(playerModel.currentFrameIndex, totalFrames: playerModel.totalFrames))) of \(formattedFrame(playerModel.totalFrames))"
                    )
                    .onChange(of: scrubbedFrame) { _, newValue in
                        guard isScrubbing else {
                            return
                        }

                        playerModel.seek(to: Int(newValue))
                    }

                    HStack {
                        Text(formattedFrame(1))
                        Spacer()
                        Text(formattedFrame(playerModel.totalFrames))
                    }
                    .font(.caption.monospacedDigit())
                    .redBlockingText(.secondary)
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
                speedToggleLabel(for: playerModel)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .redBlockingControlSurface(cornerRadius: 18)
                    .contentShape(Rectangle())
            }
            .buttonStyle(RedBlockingPressableButtonStyle())
            .accessibilityValue(showsSpeedControls ? "Expanded" : "Collapsed")
            .accessibilityHint(showsSpeedControls ? "Collapses the speed controls." : "Expands the speed controls.")

            if showsSpeedControls {
                speedEditor(framesPerSecond: framesPerSecond)
                    .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))
            }
        }
    }

    @ViewBuilder
    private func transportButtonLabel(systemImage: String, prominent: Bool) -> some View {
        let baseLabel = Image(systemName: systemImage)
            .font(.system(size: prominent ? 24 : 18, weight: .black, design: .rounded))
            .redBlockingText(prominent ? .inverse : .accent)
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

    @ViewBuilder
    private func speedToggleLabel(for playerModel: MotionPlayerModel) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("Speed")
                    .redBlockingSectionTag()

                speedSummaryLabel(for: playerModel, lineLimit: 1)
                    .fixedSize(horizontal: true, vertical: false)

                Spacer(minLength: 12)

                speedChevron
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    Text("Speed")
                        .redBlockingSectionTag()

                    Spacer(minLength: 12)

                    speedChevron
                }

                speedSummaryLabel(for: playerModel, lineLimit: dynamicTypeSize.isAccessibilitySize ? 3 : 2)
            }
        }
    }

    private func speedSummaryLabel(for playerModel: MotionPlayerModel, lineLimit: Int) -> some View {
        Text(speedSummary(for: playerModel))
            .font(.subheadline.weight(.medium))
            .redBlockingText(.secondary)
            .lineLimit(lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .contentTransition(reduceMotion ? .identity : .numericText())
    }

    private var speedChevron: some View {
        Image(systemName: "chevron.down")
            .font(.caption.weight(.bold))
            .redBlockingText(.accentSoft)
            .rotationEffect(.degrees(showsSpeedControls ? -180 : 0))
    }

    @ViewBuilder
    private func speedEditor(framesPerSecond: Binding<Int>) -> some View {
        ViewThatFits(in: .horizontal) {
            compactSpeedEditor(framesPerSecond: framesPerSecond)
            expandedSpeedEditor(framesPerSecond: framesPerSecond)
        }
    }

    private func compactSpeedEditor(framesPerSecond: Binding<Int>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            fpsLabel
                .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                fpsTextField(framesPerSecond: framesPerSecond, alignment: .trailing)
                    .frame(width: compactFPSFieldWidth)

                fpsStepper(framesPerSecond: framesPerSecond)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .redBlockingControlSurface(cornerRadius: 18)
    }

    private func expandedSpeedEditor(framesPerSecond: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            fpsLabel

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 10) {
                    fpsTextField(framesPerSecond: framesPerSecond, alignment: .leading)
                    fpsStepper(framesPerSecond: framesPerSecond)
                }

                VStack(alignment: .leading, spacing: 12) {
                    fpsTextField(framesPerSecond: framesPerSecond, alignment: .leading)
                    fpsStepper(framesPerSecond: framesPerSecond)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .redBlockingControlSurface(cornerRadius: 18)
    }

    private var fpsLabel: some View {
        Text("FPS")
            .font(.subheadline.weight(.medium))
            .redBlockingText(.secondary)
    }

    private func fpsTextField(framesPerSecond: Binding<Int>, alignment: TextAlignment) -> some View {
        TextField("Frames Per Second", value: framesPerSecond, format: .number)
            .textFieldStyle(.plain)
            .multilineTextAlignment(alignment)
            .keyboardType(.numberPad)
            .padding(.horizontal, 10)
            .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 48 : 40)
            .redBlockingControlSurface(cornerRadius: 14)
            .accessibilityLabel("Frames Per Second")
    }

    private func fpsStepper(framesPerSecond: Binding<Int>) -> some View {
        Stepper("Frames Per Second", value: framesPerSecond, in: PlaybackSettings.supportedFPSRange)
            .labelsHidden()
            .accessibilityLabel("Frames Per Second")
            .fixedSize(horizontal: true, vertical: false)
    }

    private var compactFPSFieldWidth: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 104 : 84
    }
}
