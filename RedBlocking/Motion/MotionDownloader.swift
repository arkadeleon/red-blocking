//
//  MotionDownloader.swift
//  RedBlocking
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

class MotionDownloader {
    let characterCode: String
    let skillCode: String

    private let repository: MotionRepository

    init(
        characterCode: String,
        skillCode: String,
        repository: MotionRepository = MotionRepository()
    ) {
        self.characterCode = characterCode
        self.skillCode = skillCode
        self.repository = repository
    }

    func download() async throws -> MotionPlaybackData {
        try repository.prepareMotion(characterCode: characterCode, skillCode: skillCode)
    }
}
