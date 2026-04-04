//
//  MotionPlaybackData.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import CoreGraphics

struct MotionPlaybackData: Sendable {
    let characterCode: String
    let skillCode: String
    let spriteFrameCount: Int
    let frames: [MotionFrame]

    private let imageStore: MotionFrameImageStore

    init(
        characterCode: String,
        skillCode: String,
        spriteFrameCount: Int,
        frames: [MotionFrame],
        imageStore: MotionFrameImageStore
    ) {
        self.characterCode = characterCode
        self.skillCode = skillCode
        self.spriteFrameCount = spriteFrameCount
        self.frames = frames
        self.imageStore = imageStore
    }

    var frameCount: Int {
        frames.count
    }

    var previewFrame: MotionFrame? {
        frames.first
    }

    var previewSize: CGSize? {
        previewFrame?.resource.pixelSize
    }

    var hasSpriteCountMismatch: Bool {
        spriteFrameCount != frameCount
    }

    func prepareFrame(at index: Int) async {
        await imageStore.prepareFrame(at: index)
    }

    func prepareAllFrames() async {
        await imageStore.prepareAllFrames()
    }
}
