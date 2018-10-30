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
    static let shared = DownloadManager()
    
    static let sharedQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    weak var delegate: DownloadManagerDelegate?
    
    let localBaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    let remoteBaseURL = URL(string: "http://game-institute.leonandvane.date/games/sf33")!
    
    func jsonObjectWithFileAtRelativePath(_ relativePath: String) -> Any? {
        let localURL = localBaseURL.appendingPathComponent(relativePath)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            if let jsonData = try? Data(contentsOf: localURL),
                let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
                return jsonObject
            } else {
                return nil
            }
        } else {
            let remoteURL = remoteBaseURL.appendingPathComponent(relativePath)
            let request = URLRequest(url: remoteURL)
            if let responseData = try? NSURLConnection.sendSynchronousRequest(request, returning: nil),
                let jsonObject = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                try? FileManager.default.createDirectory(atPath: localURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                try? responseData.write(to: localURL)
                return jsonObject
            } else {
                return nil
            }
        }
    }
    
    func imageWithFileAtRelativePath(_ relativePath: String) -> UIImage? {
        let localURL = localBaseURL.appendingPathComponent(relativePath)
        
        if FileManager.default.fileExists(atPath: localURL.path) {
            if let imageData = try? Data(contentsOf: localURL),
                let image = UIImage(data: imageData) {
                return image
            } else {
                return nil
            }
        } else {
            let remoteURL = remoteBaseURL.appendingPathComponent(relativePath)
            let request = URLRequest(url: remoteURL)
            if let responseData = try? NSURLConnection.sendSynchronousRequest(request, returning: nil),
                let image = UIImage(data: responseData) {
                try? FileManager.default.createDirectory(atPath: localURL.deletingLastPathComponent().path, withIntermediateDirectories: true, attributes: nil)
                try? responseData.write(to: localURL)
                return image
            } else {
                return nil
            }
        }
    }
    
    func downloadJSONObjectWithFileAtRelativePath(_ relativePath: String) {
        DownloadManager.sharedQueue.addOperation {
            if let jsonObject = self.jsonObjectWithFileAtRelativePath(relativePath) {
                OperationQueue.main.addOperation {
                    self.delegate?.downloadManager?(self, didFinishDownloadingJSONObject: jsonObject, atRelativePath: relativePath)
                }
            } else {
                OperationQueue.main.addOperation {
                    self.delegate?.downloadManager?(self, didFailToDownloadJSONObjectAtRelativePath: relativePath)
                }
            }
        }
    }
    
    func downloadImageWithFileAtRelativePath(_ relativePath: String) {
        DownloadManager.sharedQueue.addOperation {
            if let image = self.imageWithFileAtRelativePath(relativePath) {
                OperationQueue.main.addOperation {
                    self.delegate?.downloadManager?(self, didFinishDownloadingImage: image, atRelativePath: relativePath)
                }
            } else {
                OperationQueue.main.addOperation {
                    self.delegate?.downloadManager?(self, didFailToDownloadJSONObjectAtRelativePath: relativePath)
                }
            }
        }
    }
}
