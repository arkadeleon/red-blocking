//
//  MoveBrowserAction.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/13.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

indirect enum MoveBrowserAction: Hashable {
    case none
    case openNode(MoveNode)
    case openMotionPlayer(MotionPlayerLink)

    var node: MoveNode? {
        guard case let .openNode(node) = self else {
            return nil
        }

        return node
    }

    var motionPlayerLink: MotionPlayerLink? {
        guard case let .openMotionPlayer(link) = self else {
            return nil
        }

        return link
    }
}

extension MoveBrowserAction {
    struct MotionPlayerLink: Hashable {
        let title: String
        let characterCode: String
        let skillCode: String
    }
}
