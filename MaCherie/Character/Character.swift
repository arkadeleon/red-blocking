//
//  Character.swift
//  MaCherie
//
//  Created by Leon Li on 2018/6/19.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

struct Character: Decodable {
    let rowImage: String
    let rowTitle: String
    let next: String
    let nextBackgroundImage: String

    private enum CodingKeys: String, CodingKey {
        case rowImage = "RowImage"
        case rowTitle = "RowTitle"
        case next = "Next"
        case nextBackgroundImage = "NextBackgroundImage"
    }
}
