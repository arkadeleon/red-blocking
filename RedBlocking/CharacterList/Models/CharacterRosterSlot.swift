//
//  CharacterRosterSlot.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

enum CharacterRosterSlot: Hashable {
    case character(String)
    case gillPlaceholder

    var playableCharacterTitle: String? {
        guard case let .character(title) = self else {
            return nil
        }

        return title
    }
}
