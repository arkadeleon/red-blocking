//
//  DownloadManager.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/14.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

import UIKit
import PromiseKit

@objc protocol DownloadManagerDelegate {
    @objc optional func downloadManager(_ downloadManager: DownloadManager, didFinishDownloadingJSONObject jsonObject: Any, atRelativePath relativePath: String)
    @objc optional func downloadManager(_ downloadManager: DownloadManager, didFailToDownloadJSONObjectAtRelativePath relativePath: String)
    @objc optional func downloadManager(_ downloadManager: DownloadManager, didFinishDownloadingImage image: UIImage, atRelativePath relativePath: String)
    @objc optional func downloadManager(_ downloadManager: DownloadManager, didFailToDownloadImageAtRelativePath relativePath: String)
}

class DownloadManager: NSObject {
    weak var delegate: DownloadManagerDelegate?
    
    private let session = URLSession(configuration: .default)
    
    let localBaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let remoteBaseURL = URL(string: "http://game-institute.leonandvane.date/games/sf33")!
    
    deinit {
        session.invalidateAndCancel()
    }
    
    func jsonObjectWithFileAtRelativePath(_ relativePath: String) -> Promise<Any> {
        let localURL = localBaseURL.appendingPathComponent(relativePath)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            do {
                let jsonData = try Data(contentsOf: localURL)
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                return .value(jsonObject)
            } catch {
                return .init(error: error)
            }
        } else {
            let remoteURL = remoteBaseURL.appendingPathComponent(relativePath)
            return session.dataTask(.promise, with: remoteURL).then { (data, _) -> Promise<Any> in
                do {
                    try FileManager.default.createDirectory(atPath: localURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                    try data.write(to: localURL)
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    return .value(jsonObject)
                } catch {
                    return .init(error: error)
                }
            }
        }
    }
    
    func imageWithFileAtRelativePath(_ relativePath: String) -> Promise<UIImage?> {
        let localURL = localBaseURL.appendingPathComponent(relativePath)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            do {
                let imageData = try Data(contentsOf: localURL)
                let image = UIImage(data: imageData)
                return .value(image)
            } catch {
                return .init(error: error)
            }
        } else {
            let remoteURL = remoteBaseURL.appendingPathComponent(relativePath)
            return session.dataTask(.promise, with: remoteURL).then { (data, _) -> Promise<UIImage?> in
                do {
                    try FileManager.default.createDirectory(atPath: localURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                    try data.write(to: localURL)
                    let image = UIImage(data: data)
                    return .value(image)
                } catch {
                    return .init(error: error)
                }
            }
        }
    }
    
    func downloadJSONObjectWithFileAtRelativePath(_ relativePath: String) {
        firstly { [unowned self] in
            self.jsonObjectWithFileAtRelativePath(relativePath)
        }.done { [unowned self] jsonObject in
            self.delegate?.downloadManager?(self, didFinishDownloadingJSONObject: jsonObject, atRelativePath: relativePath)
        }.catch { [unowned self] error in
            self.delegate?.downloadManager?(self, didFailToDownloadJSONObjectAtRelativePath: relativePath)
        }
    }
    
    func downloadImageWithFileAtRelativePath(_ relativePath: String) {
        firstly { [unowned self] in
            self.imageWithFileAtRelativePath(relativePath)
        }.done { [unowned self] image in
            if let image = image {
                self.delegate?.downloadManager?(self, didFinishDownloadingImage: image, atRelativePath: relativePath)
            } else {
                self.delegate?.downloadManager?(self, didFailToDownloadJSONObjectAtRelativePath: relativePath)
            }
        }.catch { [unowned self] error in
            self.delegate?.downloadManager?(self, didFailToDownloadJSONObjectAtRelativePath: relativePath)
        }
    }
}
