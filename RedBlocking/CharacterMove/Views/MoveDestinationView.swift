//
//  MoveDestinationView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct MoveDestinationView: View {
    let destination: MoveDestination

    var body: some View {
        switch destination {
        case let .moveNode(node):
            MoveBrowserPageView(node: node)
        case let .motionPlayer(link):
            MotionPlayerView(
                title: link.title,
                characterCode: link.characterCode,
                skillCode: link.skillCode
            )
        }
    }
}

#Preview("Move Destination") {
    let preview = PreviewAppModel.moveBrowser()

    return NavigationStack {
        MoveDestinationView(destination: .moveNode(preview.node))
    }
    .environment(preview.appModel)
}
