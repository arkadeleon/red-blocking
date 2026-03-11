//
//  CharacterRepository.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import UIKit
import Yams

struct CharacterRepository {
    private let resourceLoader: BundleResourceLoader
    private let decoder = YAMLDecoder()

    init(bundle: Bundle = .main) {
        resourceLoader = BundleResourceLoader(bundle: bundle)
    }

    func loadCharacters() throws -> [Character] {
        let data = try resourceLoader.data(at: "CharacterData/Characters.yml")
        return try decoder.decode([Character].self, from: data)
    }

    func rowImage(for character: Character) -> UIImage? {
        resourceLoader.image(named: character.rowImage)
    }

    func backgroundImage(for character: Character) -> UIImage? {
        resourceLoader.image(named: character.nextBackgroundImage)
    }
}
