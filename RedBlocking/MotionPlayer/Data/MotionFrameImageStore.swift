//
//  MotionFrameImageStore.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import CoreGraphics
import Foundation
import ImageIO
import Synchronization

final class MotionFrameImageStore: @unchecked Sendable {
    private struct State {
        var imageCache: [Int: CGImage] = [:]
    }

    private let imageSource: CGImageSource
    private let state = Mutex(State())
    private let decodeLock = Mutex(())

    init(imageSource: CGImageSource) {
        self.imageSource = imageSource
    }

    var frameCount: Int {
        CGImageSourceGetCount(imageSource)
    }

    func image(at index: Int) -> CGImage? {
        guard index >= 0, index < frameCount else {
            return nil
        }

        if let cachedImage = state.withLock({ $0.imageCache[index] }) {
            return cachedImage
        }

        return decodeLock.withLock { _ in
            if let cachedImage = state.withLock({ $0.imageCache[index] }) {
                return cachedImage
            }

            let decodeOptions = [
                kCGImageSourceShouldCache: true,
                kCGImageSourceShouldCacheImmediately: true
            ] as CFDictionary

            guard let image = CGImageSourceCreateImageAtIndex(imageSource, index, decodeOptions) else {
                return nil
            }

            state.withLock { $0.imageCache[index] = image }
            return image
        }
    }

    func pixelSize(at index: Int) -> CGSize? {
        guard index >= 0, index < frameCount else {
            return nil
        }

        guard
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
            let height = properties[kCGImagePropertyPixelHeight] as? NSNumber
        else {
            return nil
        }

        return CGSize(width: width.doubleValue, height: height.doubleValue)
    }

    func prepareFrame(at index: Int) async {
        _ = image(at: index)
    }

    func prepareAllFrames() async {
        for index in 0..<frameCount {
            guard Task.isCancelled == false else {
                return
            }

            _ = image(at: index)

            if index.isMultiple(of: 6) {
                await Task.yield()
            }
        }
    }
}
