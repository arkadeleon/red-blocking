//
//  CharacterMove.swift
//  MaChérie
//
//  Created by Leon Li on 2018/6/19.
//  Copyright © 2018 Leon & Vane. All rights reserved.
//

struct CharacterMove: Decodable {
    let rowTitle: String?
    let rowDetail: String?
    let next: [Section]?
    let presented: Frames?
    
    private enum CodingKeys: String, CodingKey {
        case rowTitle = "RowTitle"
        case rowDetail = "RowDetail"
        case next = "Next"
        case presented = "Presented"
    }
}

extension CharacterMove {
    struct Section: Decodable {
        let sectionTitle: String?
        let rows: [CharacterMove]
        
        private enum CodingKeys: String, CodingKey {
            case sectionTitle = "SectionTitle"
            case rows = "Rows"
        }
    }
}

extension CharacterMove {
    struct Frames: Decodable {
        let viewController: String
        let characterCode: String
        let skillCode: String
        let skillName: String
        
        private enum CodingKeys: String, CodingKey {
            case viewController = "ViewController"
            case characterCode = "CharacterCode"
            case skillCode = "SkillCode"
            case skillName = "SkillName"
        }
    }
}
