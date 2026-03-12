//
//  MotionRepository.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import ImageIO

enum MotionRepositoryError: LocalizedError {
    case emptyMotionData(path: String)
    case emptySpriteSheet(path: String)

    var errorDescription: String? {
        switch self {
        case let .emptyMotionData(path):
            "Motion data is empty at path: \(path)"
        case let .emptySpriteSheet(path):
            "Sprite sheet has no decodable frames at path: \(path)"
        }
    }
}

struct MotionRepository {
    private let resourceLoader: BundleResourceLoader

    init(bundle: Bundle = .main) {
        resourceLoader = BundleResourceLoader(bundle: bundle)
    }

    func prepareMotion(characterCode: String, skillCode: String) throws -> MotionPlaybackData {
        let path = "FrameData/\(characterCode)/\(characterCode)_\(skillCode)"
        let data = try resourceLoader.data(at: "\(path).json")
        let motionInfo = try MotionInfo(data: data)

        guard motionInfo.frames.isEmpty == false else {
            throw MotionRepositoryError.emptyMotionData(path: "\(path).json")
        }

        let imageStore = MotionFrameImageStore(
            imageSource: try resourceLoader.imageSource(at: "\(path).png")
        )

        guard imageStore.frameCount > 0 else {
            throw MotionRepositoryError.emptySpriteSheet(path: "\(path).png")
        }

        let frames = motionInfo.frames.enumerated().map { index, frame in
            MotionFrame(
                index: index,
                player1: frame.player1,
                player2: frame.player2,
                resource: MotionFrameResource(index: index, imageStore: imageStore)
            )
        }

        return MotionPlaybackData(
            characterCode: characterCode,
            skillCode: skillCode,
            spriteFrameCount: imageStore.frameCount,
            frames: frames
        )
    }
}
