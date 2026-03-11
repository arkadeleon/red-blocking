//
//  MotionPlayerView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MotionPlayerView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let characterCode: String
    let skillCode: String

    @State private var loadState: MotionPlayerLoadState = .idle
    @State private var playerModel: MotionPlayerModel?
    @State private var scrubbedFrame = 0.0
    @State private var isScrubbing = false

    var body: some View {
        ZStack {
            CharacterDetailBackgroundView(selection: appModel.navigation.selectedCharacter)

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
                .padding(24)
            case let .loaded(motionData):
                if let playerModel {
                    MotionPlayerLoadedView(
                        motionData: motionData,
                        playerModel: playerModel,
                        scrubbedFrame: $scrubbedFrame,
                        isScrubbing: $isScrubbing
                    )
                    .onChange(of: playerModel.currentFrameIndex, initial: true) { _, newValue in
                        guard isScrubbing == false else {
                            return
                        }

                        scrubbedFrame = Double(newValue)
                    }
                    .onDisappear(perform: playerModel.pause)
                } else {
                    ProgressView("Configuring player...")
                        .padding(24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: taskID, loadMotion)
        .onChange(of: reduceMotion, initial: true) { _, newValue in
            guard newValue else {
                return
            }

            playerModel?.pause()
        }
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
}
