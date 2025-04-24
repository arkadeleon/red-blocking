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

class MotionPlayer: ObservableObject {
    var motionInfo: MotionInfo

    var currentFPS = UserDefaults.standard.integer(forKey: PreferredFramesPerSecondKey) {
        didSet {
            UserDefaults.standard.set(currentFPS, forKey: PreferredFramesPerSecondKey)

            if state == .playing {
                playTimer?.invalidate()
                playTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(currentFPS), repeats: true) { [unowned self] _ in
                    self.currentFrame = (self.currentFrame + 1) % self.totalFrames
                }
            }
        }
    }

    @Published private(set) var currentFrame = 0
    private var totalFrames: Int { motionInfo.frames.count }

    private(set) var state: State = .stopped

    private var playTimer: Timer?
    private var seekForwardTimer: Timer?
    private var seekBackwardTimer: Timer?

    init(motionInfo: MotionInfo) {
        self.motionInfo = motionInfo
    }

    deinit {
        playTimer?.invalidate()
        playTimer = nil

        seekBackwardTimer?.invalidate()
        seekBackwardTimer = nil

        seekBackwardTimer?.invalidate()
        seekBackwardTimer = nil
    }

    func play() {
        state = .playing

        currentFrame = (currentFrame + 1) % totalFrames

        if playTimer == nil {
            playTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(currentFPS), repeats: true) { [unowned self] _ in
                self.currentFrame = (self.currentFrame + 1) % self.totalFrames
            }
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
            seekForwardTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(self.currentFPS), repeats: true) { [unowned self] _ in
                self.currentFrame = (self.currentFrame + 1) % self.totalFrames
            }
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
            seekBackwardTimer = Timer.scheduledTimer(withTimeInterval: 1 / Double(self.currentFPS), repeats: true) { [unowned self] _ in
                self.currentFrame = (self.currentFrame - 1 + self.totalFrames) % self.totalFrames
            }
        }
    }

    func endSeekingBackward() {
        state = .paused

        seekBackwardTimer?.invalidate()
        seekBackwardTimer = nil
    }
}
