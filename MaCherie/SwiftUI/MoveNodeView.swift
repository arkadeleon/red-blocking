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
        ZStack {
            CharacterDetailBackgroundView(selection: appModel.navigation.selectedCharacter)

            MoveBrowserView(
                model: MoveBrowserModel(
                    node: node,
                    navigation: appModel.navigation
                )
            )
        }
    }
}
