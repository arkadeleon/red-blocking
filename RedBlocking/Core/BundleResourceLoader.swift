//
//  BundleResourceLoader.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import ImageIO

enum BundleResourceLoaderError: LocalizedError {
    case missingResource(path: String)
    case unreadableImageSource(path: String)

    var errorDescription: String? {
        switch self {
        case let .missingResource(path):
            _ = path
            return "Required app data is missing."
        case let .unreadableImageSource(path):
            _ = path
            return "A required preview image couldn't be loaded."
        }
    }
}

struct BundleResourceLoader {
    let bundle: Bundle
    let rootURL: URL?

    init(bundle: Bundle = .main, rootURL: URL? = nil) {
        self.bundle = bundle
        self.rootURL = rootURL
    }

    func data(at path: String) throws -> Data {
        let url = try resourceURL(at: path)
        return try Data(contentsOf: url)
    }

    func imageSource(at path: String) throws -> CGImageSource {
        let url = try resourceURL(at: path)
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw BundleResourceLoaderError.unreadableImageSource(path: path)
        }

        return imageSource
    }

    private func resourceURL(at path: String) throws -> URL {
        let baseURL = rootURL ?? bundle.resourceURL ?? bundle.bundleURL
        let url = baseURL.appendingPathComponent(path)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw BundleResourceLoaderError.missingResource(path: path)
        }

        return url
    }
}
