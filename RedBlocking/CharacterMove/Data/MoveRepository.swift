//
//  MoveRepository.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation
import Yams

struct MoveRepository {
    private let resourceLoader: BundleResourceLoader
    private let decoder = YAMLDecoder()

    init(bundle: Bundle = .main) {
        resourceLoader = BundleResourceLoader(bundle: bundle)
    }

    func loadSections(for character: Character) throws -> [CharacterMove.Section] {
        try loadSections(resourceName: character.next)
    }

    func loadSections(resourceName: String) throws -> [CharacterMove.Section] {
        let data = try resourceLoader.data(at: "CharacterData/\(resourceName)")
        return try decoder.decode([CharacterMove.Section].self, from: data)
    }
}
