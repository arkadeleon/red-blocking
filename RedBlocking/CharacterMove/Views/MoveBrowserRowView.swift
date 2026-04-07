//
//  MoveBrowserRowView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/19.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveBrowserRowView: View {
    let row: MoveBrowserRow
    let model: MoveBrowserModel

    var body: some View {
        switch row.kind {
        case .next:
            MoveNextRowView(title: row.title, subtitle: row.subtitle) {
                model.open(row)
            }
        case .motionPlayer:
            MovePlayerEntryRowView(title: row.title, subtitle: row.subtitle) {
                model.open(row)
            }
        case .detail:
            if let detail = row.detail {
                MoveDetailRowView(title: row.title, detail: detail)
            }
        case .supplementary:
            MoveSupplementaryRowView(title: row.title)
        }
    }
}

#Preview("Row Variants") {
    let preview = PreviewAppModel.moveBrowserModel()

    return VStack(alignment: .leading, spacing: 16) {
        MoveBrowserRowView(
            row: .motionPlayer(
                id: "shoryuken",
                title: "Shoryuken",
                subtitle: "623P",
                characterCode: "RYU",
                skillCode: "DP"
            ),
            model: preview.model
        )

        MoveBrowserRowView(
            row: .next(id: "specials", title: "Special Moves", node: preview.node),
            model: preview.model
        )

        MoveBrowserRowView(
            row: .detail(id: "startup", title: "Startup", value: "3"),
            model: preview.model
        )

        MoveBrowserRowView(
            row: .supplementary(
                id: "note",
                title: "Fully invulnerable through startup."
            ),
            model: preview.model
        )
    }
    .padding()
    .background(Color.rbCoal)
}
