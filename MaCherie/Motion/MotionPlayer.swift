//
//  MotionPlayer.swift
//  MaCherie
//
//  Created by Li, Junlin on 2019/11/14.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import Foundation
import Combine

extension MotionPlayer {
    enum State {
        case stopped
        case playing
        case paused
        case interrupted
        case seeking
        case seekingForward
        case seekingBackward
    }
}

@MainActor
final class MotionPlayer: NSObject, ObservableObject {
    let motionData: MotionPlaybackData

    private let playbackSettings: PlaybackSettings

    var currentFPS: Int {
        didSet {
            let clampedFPS = min(max(currentFPS, 0), 60)
            if currentFPS != clampedFPS {
                currentFPS = clampedFPS
                return
            }

            playbackSettings.framesPerSecond = clampedFPS

            if state == .playing {
                playTimer?.invalidate()
                playTimer = Timer.scheduledTimer(timeInterval: 1 / Double(clampedFPS), target: self, selector: #selector(advanceFrame), userInfo: nil, repeats: true)
            }
        }
    }

    @Published private(set) var currentFrame = 0
    private var totalFrames: Int { motionData.frames.count }

    private(set) var state: State = .stopped

    private var playTimer: Timer?
    private var seekForwardTimer: Timer?
    private var seekBackwardTimer: Timer?

    init(motionData: MotionPlaybackData, playbackSettings: PlaybackSettings = AppSettings.standard.playback) {
        self.motionData = motionData
        self.playbackSettings = playbackSettings
        self.currentFPS = playbackSettings.framesPerSecond
        super.init()
    }

    deinit {
        MainActor.assumeIsolated {
            playTimer?.invalidate()
            playTimer = nil

            seekForwardTimer?.invalidate()
            seekForwardTimer = nil

            seekBackwardTimer?.invalidate()
            seekBackwardTimer = nil
        }
    }

    func play() {
        state = .playing

        currentFrame = (currentFrame + 1) % totalFrames

        if playTimer == nil {
            playTimer = Timer.scheduledTimer(timeInterval: 1 / Double(currentFPS), target: self, selector: #selector(advanceFrame), userInfo: nil, repeats: true)
        }
    }

    func pause() {
        state = .paused

        playTimer?.invalidate()
        playTimer = nil
    }

    func stop() {
        state = .stopped

        playTimer?.invalidate()
        playTimer = nil

        currentFrame = 0
    }

    func beginSeeking() {
        state = .seeking
    }

    func seek(to frame: Int) {
        currentFrame = frame
    }

    func endSeeking() {
        state = .paused
    }

    func forward() {
        state = .paused

        playTimer?.invalidate()
        playTimer = nil

        currentFrame = (currentFrame + 1) % totalFrames
    }

    func beginSeekingForward() {
        state = .seekingForward

        playTimer?.invalidate()
        playTimer = nil

        currentFrame = (currentFrame + 1) % totalFrames

        if seekForwardTimer == nil {
            seekForwardTimer = Timer.scheduledTimer(timeInterval: 1 / Double(currentFPS), target: self, selector: #selector(advanceFrame), userInfo: nil, repeats: true)
        }
    }

    func endSeekingForward() {
        state = .paused

        seekForwardTimer?.invalidate()
        seekForwardTimer = nil
    }

    func backward() {
        state = .paused

        playTimer?.invalidate()
        playTimer = nil

        currentFrame = (currentFrame - 1 + totalFrames) % totalFrames
    }

    func beginSeekingBackward() {
        state = .seekingBackward

        currentFrame = (currentFrame - 1 + totalFrames) % totalFrames

        if seekBackwardTimer == nil {
            seekBackwardTimer = Timer.scheduledTimer(timeInterval: 1 / Double(currentFPS), target: self, selector: #selector(rewindFrame), userInfo: nil, repeats: true)
        }
    }

    func endSeekingBackward() {
        state = .paused

        seekBackwardTimer?.invalidate()
        seekBackwardTimer = nil
    }

    @objc private func advanceFrame() {
        currentFrame = (currentFrame + 1) % totalFrames
    }

    @objc private func rewindFrame() {
        currentFrame = (currentFrame - 1 + totalFrames) % totalFrames
    }
}
