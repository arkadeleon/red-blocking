//
//  MotionInfo.swift
//  MaCherie
//
//  Created by Leon Li on 2019/11/12.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit

struct MotionInfo {
    var frames: [Frame]

    init(data: Data) throws {
        let frames = try JSONDecoder().decode([String : Frame].self, from: data)
        self.frames = frames.sorted { $0.key < $1.key }.map { $0.value }
    }
}

extension MotionInfo {
    struct Frame: Decodable {
        var image: UIImage?
        var player1: Player
        var player2: Player

        enum CodingKeys: String, CodingKey {
            case player1 = "P1"
            case player2 = "P2"
        }
    }
}

extension MotionInfo {
    struct Player: Decodable {
        var hitboxes: Hitboxes
    }
}

extension MotionInfo.Player {
    struct Hitboxes: Decodable {
        var passive: [String]
        var otherVulnerability: [String]
        var active: [String]
        var `throw`: [String]
        var throwable: [String]
        var push: [String]

        var passiveToDraw: [[Int]]
        var otherVulnerabilityToDraw: [[Int]]
        var activeToDraw: [[Int]]
        var throwToDraw: [[Int]]
        var throwableToDraw: [[Int]]
        var pushToDraw: [[Int]]

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
