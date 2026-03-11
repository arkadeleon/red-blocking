//
//  MotionPlaybackData.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import CoreGraphics

struct MotionPlaybackData {
    let characterCode: String
    let skillCode: String
    let spriteFrameCount: Int
    let frames: [MotionFrame]

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
}
