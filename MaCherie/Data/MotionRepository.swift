//
//  MotionRepository.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import ImageIO
import UIKit

struct MotionRepository {
    private let resourceLoader: BundleResourceLoader

    init(bundle: Bundle = .main) {
        resourceLoader = BundleResourceLoader(bundle: bundle)
    }

    func loadMotion(characterCode: String, skillCode: String) throws -> MotionInfo {
        let path = "FrameData/\(characterCode)/\(characterCode)_\(skillCode)"
        let data = try resourceLoader.data(at: "\(path).json")
        var motionInfo = try MotionInfo(data: data)
        let images = try loadImages(at: "\(path).png")

        for (index, image) in images.enumerated() where motionInfo.frames.indices.contains(index) {
            motionInfo.frames[index].image = image.map(UIImage.init(cgImage:))
        }

        return motionInfo
    }

    private func loadImages(at path: String) throws -> [CGImage?] {
        let imageSource = try resourceLoader.imageSource(at: path)
        let count = CGImageSourceGetCount(imageSource)
        var images: [CGImage?] = []
        images.reserveCapacity(count)

        for index in 0..<count {
            let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            images.append(image)
        }

        return images
    }
}
