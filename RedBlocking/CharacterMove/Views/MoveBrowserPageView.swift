//
//  MoveNodeView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveBrowserPageView: View {
    @Environment(AppModel.self) private var appModel

    let node: MoveNode
    let errorMessage: String?

    init(node: MoveNode, errorMessage: String? = nil) {
        self.node = node
        self.errorMessage = errorMessage
    }

    var body: some View {
        ZStack {
            CharacterDetailBackgroundView(selection: appModel.navigation.selectedCharacter)

            MoveBrowserView(
                model: MoveBrowserModel(
                    node: node,
                    errorMessage: errorMessage,
                    navigation: appModel.navigation
                )
            )
        }
    }
}

#Preview("Move Browser Page") {
    let preview = PreviewAppModel.moveBrowser()

    return MoveBrowserPageView(node: preview.node)
        .environment(preview.appModel)
}
