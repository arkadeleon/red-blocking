//
//  MoveNodeView.swift
//  MaCherie
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveNodeView: View {
    @Environment(AppModel.self) private var appModel

    let node: MoveNode

    var body: some View {
        let sections = appModel.navigation.sections(for: node)
        let errorMessage = appModel.navigation.errorMessage(for: node)

        List {
            Section {
                Text("Selection and route path are now driven by SwiftUI navigation state.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Section {
                    ContentUnavailableView(
                        "Moves Unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                }
            } else if sections.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Routes Yet",
                        systemImage: "list.bullet.rectangle",
                        description: Text("This node is ready for the full move browser implementation in the next phase.")
                    )
                }
            } else {
                ForEach(sections.indices, id: \.self) { sectionIndex in
                    let section = sections[sectionIndex]

                    Section(section.sectionTitle ?? "Section \(sectionIndex + 1)") {
                        ForEach(section.rows.indices, id: \.self) { rowIndex in
                            moveRow(section.rows[rowIndex])
                        }
                    }
                }
            }
        }
        .navigationTitle(node.title)
    }

    @ViewBuilder
    private func moveRow(_ move: CharacterMove) -> some View {
        if let next = move.next {
            Button {
                appModel.navigation.pushNextNode(
                    title: move.rowTitle ?? "Move Details",
                    sections: next
                )
            } label: {
                routeRow(
                    title: move.rowTitle ?? "Move Details",
                    subtitle: move.rowDetail,
                    systemImage: "chevron.right"
                )
            }
            .buttonStyle(.plain)
        } else if let presented = move.presented {
            Button {
                appModel.navigation.pushMotionPlayer(
                    title: move.rowTitle ?? presented.skillName,
                    characterCode: presented.characterCode,
                    skillCode: presented.skillCode
                )
            } label: {
                routeRow(
                    title: move.rowTitle ?? presented.skillName,
                    subtitle: presented.skillName,
                    systemImage: "play.rectangle"
                )
            }
            .buttonStyle(.plain)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text(move.rowTitle ?? "Untitled")
                if let rowDetail = move.rowDetail {
                    Text(rowDetail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func routeRow(title: String, subtitle: String?, systemImage: String) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}
