//
//  MotionFrame.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

struct MotionFrame: Identifiable, Sendable {
    let index: Int
    let player1: MotionInfo.Player
    let player2: MotionInfo.Player
    let resource: MotionFrameResource

    var id: Int {
        index
    }
}
