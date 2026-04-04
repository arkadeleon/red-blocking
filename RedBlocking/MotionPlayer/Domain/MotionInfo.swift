//
//  MotionInfo.swift
//  RedBlocking
//
//  Created by Leon Li on 2019/11/12.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import Foundation

struct MotionInfo {
    let frames: [Frame]

    init(data: Data) throws {
        let decodedFrames = try JSONDecoder().decode([String: Frame].self, from: data)
        frames = decodedFrames.sorted { $0.key < $1.key }.map(\.value)
    }
}

extension MotionInfo {
    struct Frame: Decodable, Sendable {
        let player1: Player
        let player2: Player

        enum CodingKeys: String, CodingKey {
            case player1 = "P1"
            case player2 = "P2"
        }
    }
}

extension MotionInfo {
    struct Player: Decodable, Sendable {
        let hitboxes: Hitboxes
    }
}

extension MotionInfo.Player {
    struct Hitboxes: Decodable, Sendable {
        let passive: [String]
        let otherVulnerability: [String]
        let active: [String]
        let `throw`: [String]
        let throwable: [String]
        let push: [String]

        let passiveToDraw: [[Int]]
        let otherVulnerabilityToDraw: [[Int]]
        let activeToDraw: [[Int]]
        let throwToDraw: [[Int]]
        let throwableToDraw: [[Int]]
        let pushToDraw: [[Int]]

        enum CodingKeys: String, CodingKey {
            case passive = "p_hb"
            case otherVulnerability = "v_hb"
            case active = "a_hb"
            case `throw` = "t_hb"
            case throwable = "ta_hb"
            case push = "pu_hb"

            case passiveToDraw = "p_hb_to_draw"
            case otherVulnerabilityToDraw = "v_hb_to_draw"
            case activeToDraw = "a_hb_to_draw"
            case throwToDraw = "t_hb_to_draw"
            case throwableToDraw = "ta_hb_to_draw"
            case pushToDraw = "pu_hb_to_draw"
        }
    }
}
