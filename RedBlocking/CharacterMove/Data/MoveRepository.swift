//
//  MoveRepository.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Yams

enum MoveRepositoryError: LocalizedError {
    case invalidStructuredProfile(path: String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidStructuredProfile:
            return "This character profile couldn't be loaded."
        }
    }
}

struct MoveRepository {
    private let resourceLoader: BundleResourceLoader
    private let decoder = YAMLDecoder()
    private let browserProjector = MoveBrowserProjector()

    init(bundle: Bundle = .main, resourceRootURL: URL? = nil) {
        resourceLoader = BundleResourceLoader(bundle: bundle, rootURL: resourceRootURL)
    }

    func loadSections(for character: Character) throws -> [CharacterMove.Section] {
        try loadSections(resourceName: character.next)
    }

    func loadSections(resourceName: String) throws -> [CharacterMove.Section] {
        let data = try loadMoveData(resourceName: resourceName)
        return try decoder.decode([CharacterMove.Section].self, from: data)
    }

    func loadProfile(for character: Character) throws -> CharacterProfile {
        try loadProfile(resourceName: character.next)
    }

    func loadProfile(resourceName: String) throws -> CharacterProfile {
        let path = "CharacterData/\(resourceName)"
        let data = try loadMoveData(resourceName: resourceName)

        do {
            return try decoder.decode(CharacterProfile.self, from: data)
        } catch {
            throw MoveRepositoryError.invalidStructuredProfile(path: path, underlying: error)
        }
    }

    func loadBrowserPage(for character: Character) throws -> MoveBrowserPage {
        try loadBrowserPage(resourceName: character.next)
    }

    func loadBrowserPage(resourceName: String) throws -> MoveBrowserPage {
        let profile = try loadProfile(resourceName: resourceName)
        return browserProjector.project(profile: profile)
    }

    private func loadMoveData(resourceName: String) throws -> Data {
        try resourceLoader.data(at: "CharacterData/\(resourceName)")
    }
}
