//
//  MotionDownloader.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import ImageIO
import UIKit

class MotionDownloader {
    typealias Output = (motionInfo: MotionInfo, progress: Progress)

    let characterCode: String
    let skillCode: String

    init(characterCode: String, skillCode: String) {
        self.characterCode = characterCode
        self.skillCode = skillCode
    }

    func download() async throws -> MotionInfo {
        var motionInfo = try await downloadJSON()

        let images = try await downloadImages()

        for index in 0..<motionInfo.frames.count {
            motionInfo.frames[index].image = images[index].flatMap(UIImage.init)
        }

        return motionInfo
    }

    private func downloadJSON() async throws -> MotionInfo {
        let path = "FrameData/\(characterCode)/\(characterCode)_\(skillCode).json"
        let url = Bundle.main.resourceURL!.appendingPathComponent(path)
        let data = try Data(contentsOf: url)
        let motionInfo = try MotionInfo(data: data)
        return motionInfo
    }

    private func downloadImages() async throws -> [CGImage?] {
        let path = String(format: "FrameData/%@/%@_%@.png", characterCode, characterCode, skillCode)
        let url = Bundle.main.resourceURL!.appendingPathComponent(path)
        let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)!
        let count = CGImageSourceGetCount(imageSource)
        var images: [CGImage?] = []
        for index in 0..<count {
            let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            images.append(image)
        }
        return images
    }
}
