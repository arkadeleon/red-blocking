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
            ScrollView {
                VStack(spacing: 20) {
                    previewCard(for: motionData)

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

                        Text("Phase 9 is now loading and assembling motion playback data without going through UIKit views or controllers.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private func previewCard(for motionData: MotionPlaybackData) -> some View {
        VStack(spacing: 16) {
            if let previewImage = motionData.previewFrame?.resource.cgImage {
                Image(decorative: previewImage, scale: 1)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: 420)
                    .accessibilityHidden(true)
            } else {
                ContentUnavailableView(
                    "Preview Unavailable",
                    systemImage: "photo",
                    description: Text("The motion data decoded successfully, but the first sprite frame is missing.")
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
        loadState = .loading

        do {
            let motionData = try appModel.motionRepository.prepareMotion(
                characterCode: characterCode,
                skillCode: skillCode
            )
            loadState = .loaded(motionData)
        } catch {
            loadState = .failed(error.localizedDescription)
        }
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
