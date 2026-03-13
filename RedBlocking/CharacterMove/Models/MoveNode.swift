//
//  MoveNode.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

enum MoveNode: Hashable, Identifiable {
    case profile(CharacterProfile)
    case entry(MoveEntry)

    var id: String {
        switch self {
        case let .profile(profile):
            return "profile:\(profile.id)"
        case let .entry(entry):
            return "entry:\(entry.id)"
        }
    }
}
