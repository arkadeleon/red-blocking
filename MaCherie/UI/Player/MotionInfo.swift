//
//  MotionInfo.swift
//  MaCherie
//
//  Created by Leon Li on 2019/11/12.
//  Copyright © 2019 Leon & Vane. All rights reserved.
//

import UIKit

struct MotionInfo {
    var frames: [String : Frame]
    var sortedFrames: [Frame]
    
    init(data: Data) throws {
        frames = try JSONDecoder().decode([String : Frame].self, from: data)
        sortedFrames = frames.sorted { $0.key < $1.key }.map { $0.value }
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
        var pu_hb: [String]
        var v_hb: [String]
        var t_hb: [String]
        var a_hb: [String]
        var p_hb: [String]
        var ta_hb: [String]
        
        var p_hb_to_draw: [[Int]]
        var a_hb_to_draw: [[Int]]
        var v_hb_to_draw: [[Int]]
        var t_hb_to_draw: [[Int]]
        var ta_hb_to_draw: [[Int]]
        var pu_hb_to_draw: [[Int]]
    }
}
