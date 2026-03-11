//
//  CharacterSelection.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

struct CharacterSelection: Hashable, Identifiable {
    let title: String
    let moveResourceName: String
    let rowImageName: String
    let backgroundImageName: String

    var id: String {
        moveResourceName
    }

    init(character: Character) {
        title = character.rowTitle
        moveResourceName = character.next
        rowImageName = character.rowImage
        backgroundImageName = character.nextBackgroundImage
    }
}
