//
//  MoveBrowserRow.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/13.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

struct MoveBrowserRow: Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let detail: String?
    let kind: Kind
    let action: MoveBrowserAction

    static func next(id: String, title: String, node: MoveNode) -> MoveBrowserRow {
        MoveBrowserRow(
            id: id,
            title: title,
            subtitle: nil,
            detail: nil,
            kind: .next,
            action: .openNode(node)
        )
    }

    static func motionPlayer(
        id: String,
        title: String,
        subtitle: String?,
        characterCode: String,
        skillCode: String
    ) -> MoveBrowserRow {
        MoveBrowserRow(
            id: id,
            title: title,
            subtitle: subtitle,
            detail: nil,
            kind: .motionPlayer,
            action: .openMotionPlayer(
                .init(
                    title: title,
                    characterCode: characterCode,
                    skillCode: skillCode
                )
            )
        )
    }

    static func detail(id: String, title: String, value: String) -> MoveBrowserRow {
        MoveBrowserRow(
            id: id,
            title: title,
            subtitle: nil,
            detail: value,
            kind: .detail,
            action: .none
        )
    }

    static func supplementary(id: String, title: String) -> MoveBrowserRow {
        MoveBrowserRow(
            id: id,
            title: title,
            subtitle: nil,
            detail: nil,
            kind: .supplementary,
            action: .none
        )
    }
}

extension MoveBrowserRow {
    enum Kind: Hashable {
        case next
        case motionPlayer
        case detail
        case supplementary
    }
}
