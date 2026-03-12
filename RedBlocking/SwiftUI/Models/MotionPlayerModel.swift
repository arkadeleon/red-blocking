//
//  MotionPlayerModel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Observation

@MainActor
@Observable
final class MotionPlayerModel {
    enum State: Equatable {
        case stopped
        case playing
        case paused
        case seeking
    }

    let motionData: MotionPlaybackData

    private let playbackSettings: PlaybackSettings
    private let clock = ContinuousClock()

    var framesPerSecond: Int {
        didSet {
            let clampedValue = PlaybackSettings.clamp(framesPerSecond)
            if framesPerSecond != clampedValue {
                framesPerSecond = clampedValue
                return
            }

            playbackSettings.framesPerSecond = clampedValue

            if state == .playing {
                restartPlaybackLoop()
            }
        }
    }

    private(set) var currentFrameIndex = 0
    private(set) var state: State = .stopped

    private var playbackTask: Task<Void, Never>?

    var currentFrame: MotionFrame? {
        guard totalFrames > 0 else {
            return nil
        }

        return motionData.frames[currentFrameIndex]
    }

    var totalFrames: Int {
        motionData.frameCount
    }

    var isPlaying: Bool {
        state == .playing
    }

    init(
        motionData: MotionPlaybackData,
        playbackSettings: PlaybackSettings
    ) {
        self.motionData = motionData
        self.playbackSettings = playbackSettings
        self.framesPerSecond = playbackSettings.framesPerSecond
    }

    deinit {
        MainActor.assumeIsolated {
            playbackTask?.cancel()
        }
    }

    func play() {
        guard totalFrames > 0 else {
            state = .stopped
            return
        }

        state = .playing
        restartPlaybackLoop()
    }

    func pause() {
        stopPlaybackLoop()
        state = totalFrames == 0 ? .stopped : .paused
    }

    func stop() {
        stopPlaybackLoop()
        currentFrameIndex = 0
        state = .stopped
    }

    func beginSeeking() {
        guard totalFrames > 0 else {
            return
        }

        stopPlaybackLoop()
        state = .seeking
    }

    func seek(to frameIndex: Int) {
        guard totalFrames > 0 else {
            currentFrameIndex = 0
            return
        }

        currentFrameIndex = min(max(frameIndex, 0), totalFrames - 1)
    }

    func endSeeking() {
        state = totalFrames == 0 ? .stopped : .paused
    }

    func stepForward() {
        guard totalFrames > 0 else {
            return
        }

        stopPlaybackLoop()
        state = .paused
        advanceFrame(by: 1)
    }

    func stepBackward() {
        guard totalFrames > 0 else {
            return
        }

        stopPlaybackLoop()
        state = .paused
        advanceFrame(by: -1)
    }

    private func restartPlaybackLoop() {
        stopPlaybackLoop()

        guard state == .playing, totalFrames > 0, framesPerSecond > 0 else {
            return
        }

        playbackTask = Task { [weak self] in
            await self?.runPlaybackLoop()
        }
    }

    private func stopPlaybackLoop() {
        playbackTask?.cancel()
        playbackTask = nil
    }

    private func runPlaybackLoop() async {
        while !Task.isCancelled, state == .playing {
            let fps = framesPerSecond

            guard fps > 0 else {
                return
            }

            try? await clock.sleep(for: .seconds(1.0 / Double(fps)))

            guard !Task.isCancelled, state == .playing else {
                return
            }

            advanceFrame(by: 1)
        }
    }

    private func advanceFrame(by step: Int) {
        guard totalFrames > 0 else {
            currentFrameIndex = 0
            return
        }

        let nextFrameIndex = (currentFrameIndex + step) % totalFrames
        currentFrameIndex = nextFrameIndex >= 0 ? nextFrameIndex : nextFrameIndex + totalFrames
    }
}
