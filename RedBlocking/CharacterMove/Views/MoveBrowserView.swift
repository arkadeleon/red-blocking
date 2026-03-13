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

    let model: MoveBrowserModel

    var body: some View {
        let rowBackground = Color.rbPanel.opacity(rowBackgroundOpacity)

        listContent(rowBackground: rowBackground)
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .contentMargins(.top, 16, for: .scrollContent)
            .contentMargins(.horizontal, horizontalContentMargin, for: .scrollContent)
            .navigationTitle(model.page.navigationTitle)
    }

    private func listContent(rowBackground: Color) -> some View {
        List {
            if let errorMessage = model.errorMessage {
                Section {
                    ContentUnavailableView(
                        "Couldn't Load Moves",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                    .listRowBackground(rowBackground)
                }
            } else if model.page.sections.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Moves Here",
                        systemImage: "list.bullet.rectangle",
                        description: Text("This section doesn't contain any moves.")
                    )
                    .listRowBackground(rowBackground)
                }
            } else {
                ForEach(model.page.sections) { section in
                    Section {
                        ForEach(section.rows) { row in
                            switch row.kind {
                            case .next:
                                MoveNextRowView(
                                    title: row.title,
                                    subtitle: row.subtitle
                                ) {
                                    model.open(row)
                                }
                                .listRowBackground(rowBackground)
                            case .motionPlayer:
                                MovePlayerEntryRowView(
                                    title: row.title,
                                    subtitle: row.subtitle
                                ) {
                                    model.open(row)
                                }
                                .listRowBackground(rowBackground)
                            case .detail:
                                if let detail = row.detail {
                                    MoveDetailRowView(
                                        title: row.title,
                                        detail: detail
                                    )
                                    .listRowBackground(rowBackground)
                                }
                            case .supplementary:
                                MoveSupplementaryRowView(
                                    title: row.title
                                )
                                .listRowBackground(rowBackground)
                            }
                        }
                    } header: {
                        if let sectionTitle = section.title, sectionTitle.isEmpty == false {
                            Text(sectionTitle)
                        }
                    }
                }
            }
        }
        .listRowSeparatorTint(Color.rbPanelBorder.opacity(0.28))
    }

    private var rowBackgroundOpacity: Double {
        horizontalSizeClass == .compact ? 0.9 : 0.76
    }

    private var horizontalContentMargin: CGFloat {
        horizontalSizeClass == .regular ? 24 : 0
    }
}
