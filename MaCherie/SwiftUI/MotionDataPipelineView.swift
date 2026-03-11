//
//  MotionDataPipelineView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionDataPipelineView: View {
    @Environment(AppModel.self) private var appModel

    let title: String
    let characterCode: String
    let skillCode: String

    @State private var loadState: LoadState = .idle
    @State private var playerModel: MotionPlayerModel?
    @State private var scrubbedFrame = 0.0
    @State private var isScrubbing = false

    private let frameNumberFormat = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3...))

    var body: some View {
        ZStack {
            CharacterDetailBackgroundView(selection: appModel.navigation.selectedCharacter)

            content
                .padding(24)
        }
        .navigationTitle(title)
        .task(id: taskID, loadMotion)
    }

    @ViewBuilder
    private var content: some View {
        switch loadState {
        case .idle, .loading:
            ProgressView("Preparing motion data...")
                .padding(24)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        case let .failed(message):
            ContentUnavailableView(
                "Motion Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        case let .loaded(motionData):
            if let playerModel {
                loadedContent(motionData: motionData, playerModel: playerModel)
            } else {
                ProgressView("Configuring player...")
                    .padding(24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        }
    }

    private func loadedContent(
        motionData: MotionPlaybackData,
        playerModel: MotionPlayerModel
    ) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                previewCard(for: playerModel)

                VStack(alignment: .leading, spacing: 16) {
                    LabeledContent("Playback State", value: playbackStateLabel(for: playerModel.state))
                    LabeledContent(
                        "Frame",
                        value: "\(formattedFrame(playerModel.currentFrameIndex)) / \(formattedFrame(motionData.frameCount))"
                    )
                    LabeledContent("FPS", value: "\(playerModel.framesPerSecond)")

                    if motionData.frameCount > 1 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Seek")
                                .font(.headline)

                            Slider(
                                value: $scrubbedFrame,
                                in: 0...Double(motionData.frameCount - 1),
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
                                Text(formattedFrame(motionData.frameCount - 1))
                            }
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 12) {
                        Button(action: playerModel.stepBackward) {
                            Image(systemName: "backward.frame")
                        }
                        .accessibilityLabel("Previous Frame")

                        Button {
                            if playerModel.isPlaying {
                                playerModel.pause()
                            } else {
                                playerModel.play()
                            }
                        } label: {
                            Image(systemName: playerModel.isPlaying ? "pause.circle" : "play.circle")
                        }
                        .accessibilityLabel(playerModel.isPlaying ? "Pause" : "Play")

                        Button(action: playerModel.stop) {
                            Image(systemName: "stop.circle")
                        }
                        .accessibilityLabel("Stop")

                        Button(action: playerModel.stepForward) {
                            Image(systemName: "forward.frame")
                        }
                        .accessibilityLabel("Next Frame")
                    }
                    .buttonStyle(.borderedProminent)

                    Stepper {
                        Label("\(playerModel.framesPerSecond) FPS", systemImage: "gauge.with.dots.needle.33percent")
                    } onIncrement: {
                        playerModel.framesPerSecond += 1
                    } onDecrement: {
                        playerModel.framesPerSecond -= 1
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Label("\(motionData.frameCount) motion frames", systemImage: "list.number")
                        Label("\(motionData.spriteFrameCount) sprite frames", systemImage: "photo.stack")
                        Label("\(motionData.characterCode) / \(motionData.skillCode)", systemImage: "shippingbox")

                        if let previewSize = motionData.previewSize {
                            Label(
                                "\(Int(previewSize.width)) x \(Int(previewSize.height)) preview size",
                                systemImage: "rectangle.expand.vertical"
                            )
                        }

                        if motionData.hasSpriteCountMismatch {
                            Text("Sprite frame count differs from motion data. Playback will use the available image for each frame index.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        if playerModel.framesPerSecond == 0 {
                            Text("0 FPS keeps the player on the current frame until the playback speed is raised.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Text("Phase 10 now drives frame advancement through MotionPlayerModel, using a single clock-based task instead of multiple UIKit timers.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Phase 11 renders the sprite and hitbox overlays through a SwiftUI Canvas, so hitbox visibility and color settings refresh directly inside the preview.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            }
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .onChange(of: playerModel.currentFrameIndex, initial: true) { _, newValue in
            guard !isScrubbing else {
                return
            }

            scrubbedFrame = Double(newValue)
        }
        .onDisappear {
            playerModel.pause()
        }
    }

    @ViewBuilder
    private func previewCard(for playerModel: MotionPlayerModel) -> some View {
        VStack(spacing: 16) {
            if let currentFrame = playerModel.currentFrame {
                VStack(spacing: 12) {
                    MotionCanvasView(
                        motionFrame: currentFrame,
                        hitboxVisibilitySettings: appModel.settings.hitboxVisibility,
                        hitboxColorSettings: appModel.settings.hitboxColors
                    )
                    .frame(maxWidth: 420)

                    Text("Current frame: \(formattedFrame(playerModel.currentFrameIndex))")
                        .font(.headline.monospacedDigit())
                }
            } else {
                ContentUnavailableView(
                    "Preview Unavailable",
                    systemImage: "photo",
                    description: Text("The motion data decoded successfully, but the current sprite frame is missing.")
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var taskID: String {
        "\(characterCode)-\(skillCode)"
    }

    @MainActor
    private func loadMotion() async {
        playerModel?.pause()
        playerModel = nil
        scrubbedFrame = 0
        isScrubbing = false
        loadState = .loading

        do {
            let motionData = try appModel.motionRepository.prepareMotion(
                characterCode: characterCode,
                skillCode: skillCode
            )
            playerModel = MotionPlayerModel(
                motionData: motionData,
                playbackSettings: appModel.settings.playback
            )
            loadState = .loaded(motionData)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    private func handleScrubbingChange(_ isEditing: Bool) {
        guard let playerModel else {
            return
        }

        isScrubbing = isEditing

        if isEditing {
            playerModel.beginSeeking()
            playerModel.seek(to: Int(scrubbedFrame))
        } else {
            playerModel.seek(to: Int(scrubbedFrame))
            playerModel.endSeeking()
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

    private func formattedFrame(_ frame: Int) -> String {
        frame.formatted(frameNumberFormat)
    }
}

private extension MotionDataPipelineView {
    enum LoadState {
        case idle
        case loading
        case loaded(MotionPlaybackData)
        case failed(String)
    }
}
