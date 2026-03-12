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

final class MotionFrameImageStore {
    private let imageSource: CGImageSource
    private var imageCache: [Int: CGImage] = [:]

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

        if let cachedImage = imageCache[index] {
            return cachedImage
        }

        guard let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
            return nil
        }

        imageCache[index] = image
        return image
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
}
