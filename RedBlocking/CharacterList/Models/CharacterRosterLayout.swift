//
//  CharacterRosterLayout.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

struct CharacterRosterLayout: Hashable {
    let rows: [CharacterRosterRow]

    static let streetFighterIIIThirdStrike = CharacterRosterLayout(
        rows: [
            CharacterRosterRow(characters: [nil, .yun, nil]),
            CharacterRosterRow(characters: [.gouki, .remy, .ryu]),
            CharacterRosterRow(characters: [.urien, .q, .oro]),
            CharacterRosterRow(characters: [.necro, .chunLi, .dudley]),
            CharacterRosterRow(characters: [.ibuki, .makoto, .elena]),
            CharacterRosterRow(characters: [.sean, .twelve, .hugo]),
            CharacterRosterRow(characters: [.alex, .yang, .ken]),
            CharacterRosterRow(characters: [nil, .gill, nil]),
        ]
    )

    func defaultCharacter(from selections: [CharacterSelection]) -> CharacterSelection? {
        guard let character = rows.flatMap(\.characters).compactMap({ $0 }).first(where: { !$0.isLocked }) else {
            return nil
        }

        return selections.first { $0.title == character.name }
    }
}
