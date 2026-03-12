//
//  MoveBrowserView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveBrowserView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: MoveBrowserModel

    var body: some View {
        let rowBackground = Color(uiColor: .systemBackground).opacity(rowBackgroundOpacity)

        Group {
            if dynamicTypeSize.isAccessibilitySize {
                listContent(rowBackground: rowBackground)
                    .listStyle(.insetGrouped)
            } else {
                listContent(rowBackground: rowBackground)
                    .listStyle(.plain)
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 16, for: .scrollContent)
        .contentMargins(.horizontal, horizontalContentMargin, for: .scrollContent)
        .navigationTitle(model.node.title)
    }

    private func listContent(rowBackground: Color) -> some View {
        List {
            if let errorMessage = model.errorMessage {
                Section {
                    ContentUnavailableView(
                        "Moves Unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                    .listRowBackground(rowBackground)
                }
            } else if model.sections.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Moves",
                        systemImage: "list.bullet.rectangle",
                        description: Text("This move node does not contain any rows.")
                    )
                    .listRowBackground(rowBackground)
                }
            } else {
                ForEach(Array(model.sections.enumerated()), id: \.offset) { _, section in
                    Section {
                        ForEach(Array(section.rows.enumerated()), id: \.offset) { _, move in
                            if move.next != nil {
                                MoveNextRowView(
                                    title: model.title(for: move),
                                    subtitle: model.subtitle(for: move)
                                ) {
                                    model.open(move)
                                }
                                .listRowBackground(rowBackground)
                            } else if model.isMovePlayerEntry(move) {
                                MovePlayerEntryRowView(
                                    title: model.title(for: move),
                                    subtitle: model.playerSubtitle(for: move)
                                ) {
                                    model.open(move)
                                }
                                .listRowBackground(rowBackground)
                            } else if let detail = move.rowDetail {
                                MoveDetailRowView(
                                    title: model.title(for: move),
                                    detail: detail
                                )
                                .listRowBackground(rowBackground)
                            } else {
                                MoveSupplementaryRowView(
                                    title: model.title(for: move)
                                )
                                .listRowBackground(rowBackground)
                            }
                        }
                    } header: {
                        if let sectionTitle = section.sectionTitle, sectionTitle.isEmpty == false {
                            Text(sectionTitle)
                        }
                    }
                }
            }
        }
    }

    private var rowBackgroundOpacity: Double {
        horizontalSizeClass == .compact ? 0.9 : 0.76
    }

    private var horizontalContentMargin: CGFloat {
        horizontalSizeClass == .regular ? 24 : 0
    }
}
