//
//  MotionFrameResource.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import CoreGraphics

struct MotionFrameResource {
    let index: Int

    private let imageStore: MotionFrameImageStore

    init(index: Int, imageStore: MotionFrameImageStore) {
        self.index = index
        self.imageStore = imageStore
    }

    var cgImage: CGImage? {
        imageStore.image(at: index)
    }

    var pixelSize: CGSize? {
        imageStore.pixelSize(at: index)
    }
}
