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

    let page: MoveBrowserPage
    let errorMessage: String?

    init(page: MoveBrowserPage, errorMessage: String? = nil) {
        self.page = page
        self.errorMessage = errorMessage
    }

    var body: some View {
        ZStack {
            CharacterDetailBackgroundView(selection: appModel.navigation.selectedCharacter)

            MoveBrowserView(
                model: MoveBrowserModel(
                    page: page,
                    errorMessage: errorMessage,
                    navigation: appModel.navigation
                )
            )
        }
    }
}

#Preview("Move Browser") {
    let preview = PreviewAppModel.moveBrowser()

    return MoveBrowserPageView(page: preview.page)
        .environment(preview.appModel)
}
