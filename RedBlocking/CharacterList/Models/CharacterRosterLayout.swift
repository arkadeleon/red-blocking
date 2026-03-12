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
            CharacterRosterRow(slots: [nil, .character("Yun"), nil]),
            CharacterRosterRow(slots: [.character("Gouki"), .character("Remy"), .character("Ryu")]),
            CharacterRosterRow(slots: [.character("Urien"), .character("Q"), .character("Oro")]),
            CharacterRosterRow(slots: [.character("Necro"), .character("Chun-Li"), .character("Dudley")]),
            CharacterRosterRow(slots: [.character("Ibuki"), .character("Makoto"), .character("Elena")]),
            CharacterRosterRow(slots: [.character("Sean"), .character("Twelve"), .character("Hugo")]),
            CharacterRosterRow(slots: [.character("Alex"), .character("Yang"), .character("Ken")]),
            CharacterRosterRow(slots: [nil, .gillPlaceholder, nil]),
        ]
    )

    var defaultCharacterTitle: String? {
        rows
            .flatMap(\.slots)
            .compactMap { $0 }
            .compactMap(\.playableCharacterTitle)
            .first
    }

    func defaultCharacter(from characters: [CharacterSelection]) -> CharacterSelection? {
        guard let defaultCharacterTitle else {
            return nil
        }

        return characters.first { $0.title == defaultCharacterTitle }
    }
}
