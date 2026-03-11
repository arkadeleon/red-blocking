//
//  CharacterSelection.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

struct CharacterSelection: Hashable, Identifiable {
    let title: String
    let moveResourceName: String
    let rowImageName: String
    let backgroundImageName: String

    var id: String {
        moveResourceName
    }

    var rowAssetName: String {
        (rowImageName as NSString).deletingPathExtension
    }

    var backgroundAssetName: String {
        (backgroundImageName as NSString).deletingPathExtension
    }

    init(character: Character) {
        title = character.rowTitle
        moveResourceName = character.next
        rowImageName = character.rowImage
        backgroundImageName = character.nextBackgroundImage
    }
}
