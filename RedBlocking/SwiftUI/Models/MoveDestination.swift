//
//  MoveDestination.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

enum MoveDestination: Hashable {
    case moveNode(MoveNode)
    case motionPlayer(title: String, characterCode: String, skillCode: String)
}
