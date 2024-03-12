//
//  MotionDownloader.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import Combine
import UIKit

class MotionDownloader {
    typealias Output = (motionInfo: MotionInfo, progress: Progress)
    
    let characterCode: String
    let skillCode: String
    
    init(characterCode: String, skillCode: String) {
        self.characterCode = characterCode
        self.skillCode = skillCode
    }
    
    func downloadPublisher() -> AnyPublisher<Output, Error> {
        Future<MotionInfo, Error> { (promise) in
            self.downloadJSON(promise)
        }.flatMap { (motionInfo) -> AnyPublisher<Output, Error> in
            var motionInfo = motionInfo
            var merge = Empty<(Int, UIImage?), Error>().eraseToAnyPublisher()
            for index in 0..<motionInfo.frames.count {
                let future = Future { (promise) in
                    self.downloadImage(at: index, promise)
                }.handleEvents(receiveOutput: { value in
                    motionInfo.frames[value.0].image = value.1
                })
                merge = merge.merge(with: future).eraseToAnyPublisher()
            }
            return merge.scan([]) { $0 + [$1] }.map { (images) -> Output in
                let progress = Progress(totalUnitCount: Int64(motionInfo.frames.count))
                progress.completedUnitCount = Int64(images.count)
                return (motionInfo, progress)
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    private func downloadJSON(_ promise: @escaping (Result<MotionInfo, Error>) -> ()) {
        let path = "FrameData/\(characterCode)/\(skillCode)/\(characterCode)_\(skillCode).json"
        let url = Bundle.main.resourceURL!.appendingPathComponent(path)
        let data = try! Data(contentsOf: url)
        let motionInfo = try! MotionInfo(data: data)
        promise(.success(motionInfo))
    }
    
    private func downloadImage(at index: Int, _ promise: @escaping (Result<(Int, UIImage?), Error>) -> ()) {
        let path = String(format: "FrameData/%@/%@/%@_%@_%03d.png", characterCode, skillCode, characterCode, skillCode, index)
        let url = Bundle.main.resourceURL!.appendingPathComponent(path)
        let data = try! Data(contentsOf: url)
        let image = UIImage(data: data)
        promise(.success((index, image)))
    }
}
