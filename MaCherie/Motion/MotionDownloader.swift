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
    
    private let session = URLSession(configuration: .default)
    private let localBaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    private let remoteBaseURL = URL(string: "http://game-institute.leonandvane.date/games/sf33")!
    
    init(characterCode: String, skillCode: String) {
        self.characterCode = characterCode
        self.skillCode = skillCode
    }
    
    deinit {
        session.invalidateAndCancel()
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
        let path = String(format: "motions/%@/%@/%@_%@.json", characterCode, skillCode, characterCode, skillCode)
        let localURL = localBaseURL.appendingPathComponent(path)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            do {
                let data = try Data(contentsOf: localURL)
                let motionInfo = try MotionInfo(data: data)
                promise(.success(motionInfo))
            } catch {
                promise(.failure(error))
            }
            return
        }
        
        let remoteURL = remoteBaseURL.appendingPathComponent(path)
        session.dataTask(with: remoteURL) { (data, response, error) in
            guard let data = data else {
                promise(.failure(error!))
                return
            }
            
            do {
                try FileManager.default.createDirectory(atPath: localURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: localURL)
                let motionInfo = try MotionInfo(data: data)
                promise(.success(motionInfo))
            } catch {
                promise(.failure(error))
            }
        }.resume()
    }
    
    private func downloadImage(at index: Int, _ promise: @escaping (Result<(Int, UIImage?), Error>) -> ()) {
        let path = String(format: "motions/%@/%@/%@_%@_%03d.png", characterCode, skillCode, characterCode, skillCode, index)
        let localURL = localBaseURL.appendingPathComponent(path)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            do {
                let imageData = try Data(contentsOf: localURL)
                let image = UIImage(data: imageData)
                promise(.success((index, image)))
            } catch {
                promise(.failure(error))
            }
            return
        }
        
        let remoteURL = remoteBaseURL.appendingPathComponent(path)
        session.dataTask(with: remoteURL) { (data, response, error) in
            guard let data = data else {
                promise(.failure(error!))
                return
            }
            
            do {
                try FileManager.default.createDirectory(atPath: localURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: localURL)
                let image = UIImage(data: data)
                promise(.success((index, image)))
            } catch {
                promise(.failure(error))
            }
        }.resume()
    }
}
