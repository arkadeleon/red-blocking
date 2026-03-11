//
//  MoveDestinationView.swift
//  MaCherie
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
            MoveNodeView(node: node)
        case let .motionPlayer(title, characterCode, skillCode):
            MotionPlayerView(
                title: title,
                characterCode: characterCode,
                skillCode: skillCode
            )
        }
    }
}
